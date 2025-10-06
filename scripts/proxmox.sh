#!/usr/bin/env bash
set -euo pipefail

COMMAND=${1:-}
if [[ -z "${COMMAND}" ]]; then
  echo "Usage: $0 <create|provision|destroy|ssh|status|list|clean>" >&2
  exit 1
fi
shift || true

UBUNTU_VERSION=${UBUNTU_VERSION:-noble}
PROXMOX_API_HOST=${PROXMOX_API_HOST:-192.168.1.100}
PROXMOX_API_USER=${PROXMOX_API_USER:-root@pam}
PROXMOX_API_TOKEN_ID=${PROXMOX_API_TOKEN_ID:-ttdaiu}
PROXMOX_API_TOKEN_SECRET=${PROXMOX_API_TOKEN_SECRET:-}
PROXMOX_NODE=${PROXMOX_NODE:-pve}
TEMPLATE_ID_NOBLE=${TEMPLATE_ID_NOBLE:-8000}
TEMPLATE_ID_JAMMY=${TEMPLATE_ID_JAMMY:-8001}
VM_CORES=${VM_CORES:-2}
VM_MEMORY=${VM_MEMORY:-4096}
VM_DISK_SIZE=${VM_DISK_SIZE:-20G}
VM_STORAGE=${VM_STORAGE:-local-lvm}
VM_NETWORK_BRIDGE=${VM_NETWORK_BRIDGE:-vmbr0}
VM_USER=${VM_USER:-ubuntu}
VM_ID=${VM_ID:-9000}
VM_NAME=${VM_NAME:-ttdaiu-${UBUNTU_VERSION}-test}

PLAYBOOK=${PLAYBOOK:-site.yml}
ANSIBLE_DIR=${ANSIBLE_DIR:-./${UBUNTU_VERSION}}
TAGS=${TAGS:-all}

case "${UBUNTU_VERSION}" in
  jammy)
    TEMPLATE_ID=${TEMPLATE_ID_JAMMY}
    ;;
  *)
    TEMPLATE_ID=${TEMPLATE_ID_NOBLE}
    ;;
esac

PROXMOX_AUTH="PVEAPIToken=${PROXMOX_API_USER}!${PROXMOX_API_TOKEN_ID}=${PROXMOX_API_TOKEN_SECRET}"
PROXMOX_API_URL="https://${PROXMOX_API_HOST}:8006/api2/json"

require_token() {
  if [[ -z "${PROXMOX_API_TOKEN_SECRET}" ]]; then
    echo "Error: PROXMOX_API_TOKEN_SECRET not set. Please configure your .env." >&2
    exit 1
  fi
}

curl_json() {
  local method=$1
  local path=$2
  shift 2
  curl -k -sS -X "${method}" "${PROXMOX_API_URL}${path}" -H "Authorization: ${PROXMOX_AUTH}" "$@"
}

curl_with_status() {
  local method=$1
  local path=$2
  shift 2
  local tmp
  tmp=$(mktemp)
  local http_status
  http_status=$(curl -k -sS -o "${tmp}" -w '%{http_code}' -X "${method}" "${PROXMOX_API_URL}${path}" -H "Authorization: ${PROXMOX_AUTH}" "$@")
  local response
  response=$(cat "${tmp}")
  rm -f "${tmp}"
  if [[ "${http_status}" == "000" ]]; then
    echo "HTTP request failed" >&2
    echo "${response}" >&2
    return 1
  fi
  printf '%s\n' "${http_status}" "${response}"
}

get_vm_ip() {
  require_token
  local result
  result=$(curl_json GET "/nodes/${PROXMOX_NODE}/qemu/${VM_ID}/agent/network-get-interfaces" || true)
  echo "${result}" | grep -o '"ip-address":"[^"]*' | grep -v '127.0.0.1' | head -1 | cut -d'"' -f4
}

case "${COMMAND}" in
  create)
    require_token
    echo "Creating Proxmox VM ${VM_NAME} (ID: ${VM_ID}) for ${UBUNTU_VERSION}..."
    result=$(curl_with_status POST "/nodes/${PROXMOX_NODE}/qemu/${TEMPLATE_ID}/clone" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      --data "newid=${VM_ID}" \
      --data "name=${VM_NAME}" \
      --data "target=${PROXMOX_NODE}" \
      --data "full=1") || exit 1
    status=$(printf '%s\n' "${result}" | sed -n '1p')
    response=$(printf '%s\n' "${result}" | sed -n '2,$p')
    if [[ "${status}" -ge 400 ]]; then
      echo "Error creating VM (HTTP ${status}): ${response}" >&2
      exit 1
    fi
    if grep -q '"message"' <<<"${response}"; then
      echo "Error creating VM: ${response}" >&2
      exit 1
    fi
    echo "${response}"
    echo "VM ${VM_NAME} created successfully"
    ;;
  provision)
    require_token
    echo "Waiting for VM ${VM_NAME} to be ready..."
    sleep 10
    echo "Getting VM IP address..."
    vm_ip=$(get_vm_ip || true)
    if [[ -z "${vm_ip}" ]]; then
      echo "Could not get VM IP address. VM may not be ready yet." >&2
      exit 1
    fi
    echo "VM IP: ${vm_ip}"
    if [[ ! -d "${ANSIBLE_DIR}" ]]; then
      echo "Ansible directory not found: ${ANSIBLE_DIR}" >&2
      exit 1
    fi
    echo "Provisioning VM with TTDAIU..."
    pushd "${ANSIBLE_DIR}" >/dev/null
    cmd=(ansible-playbook "${PLAYBOOK}" -i "${vm_ip}," -u "${VM_USER}")
    if [[ -n "${TAGS}" ]]; then
      cmd+=(--tags "${TAGS}")
    fi
    cmd+=(--ask-become-pass)
    "${cmd[@]}"
    popd >/dev/null
    ;;
  destroy)
    require_token
    echo "Destroying Proxmox VM ${VM_NAME} (ID: ${VM_ID})..."
    result=$(curl_with_status DELETE "/nodes/${PROXMOX_NODE}/qemu/${VM_ID}" ) || exit 1
    status=$(printf '%s\n' "${result}" | sed -n '1p')
    response=$(printf '%s\n' "${result}" | sed -n '2,$p')
    if [[ "${status}" -ge 400 ]]; then
      echo "Error destroying VM (HTTP ${status}): ${response}" >&2
      exit 1
    fi
    echo "${response}"
    echo "VM ${VM_NAME} destroyed successfully"
    ;;
  ssh)
    require_token
    echo "Getting VM IP for SSH connection..."
    vm_ip=$(get_vm_ip || true)
    if [[ -z "${vm_ip}" ]]; then
      echo "Could not get VM IP address" >&2
      exit 1
    fi
    echo "Connecting to ${VM_NAME} at ${vm_ip}..."
    exec ssh -o StrictHostKeyChecking=no "${VM_USER}@${vm_ip}"
    ;;
  status)
    require_token
    echo "Proxmox VM status for ${VM_NAME} (ID: ${VM_ID}):"
    response=$(curl_json GET "/nodes/${PROXMOX_NODE}/qemu/${VM_ID}/status/current" || true)
    status_value=$(echo "${response}" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
    if [[ -n "${status_value}" ]]; then
      echo "${status_value}"
    else
      echo "VM not found"
    fi
    ;;
  list)
    require_token
    echo "Listing all TTDAIU test VMs in Proxmox..."
    response=$(curl_json GET "/nodes/${PROXMOX_NODE}/qemu" || true)
    names=$(echo "${response}" | grep -o '"name":"ttdaiu-[^"]*' | cut -d'"' -f4)
    if [[ -n "${names}" ]]; then
      printf '%s\n' "${names}"
    else
      echo "No TTDAIU VMs found"
    fi
    ;;
  clean)
    require_token
    echo "Finding all TTDAIU test VMs..."
    response=$(curl_json GET "/nodes/${PROXMOX_NODE}/qemu" || true)
    vm_list=$(echo "${response}" | grep -B2 -A2 '"name":"ttdaiu-' | grep '"vmid"' | grep -o '[0-9]*' | sort -u)
    if [[ -z "${vm_list}" ]]; then
      echo "No TTDAIU test VMs found"
      exit 0
    fi
    echo "Found VMs: ${vm_list}"
    read -rp "This will destroy all TTDAIU test VMs. Continue? (y/N) " confirm
    if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
      echo "Operation cancelled"
      exit 0
    fi
    while read -r vmid; do
      [[ -z "${vmid}" ]] && continue
      echo "Destroying VM ${vmid}..."
      result=$(curl_with_status DELETE "/nodes/${PROXMOX_NODE}/qemu/${vmid}" ) || continue
      status=$(printf '%s\n' "${result}" | sed -n '1p')
      response=$(printf '%s\n' "${result}" | sed -n '2,$p')
      if [[ "${status}" -ge 400 ]]; then
        echo "Failed to destroy VM ${vmid} (HTTP ${status}): ${response}" >&2
      fi
    done <<<"${vm_list}"
    echo "All TTDAIU VMs destroyed"
    ;;
  *)
    echo "Unknown command: ${COMMAND}" >&2
    echo "Usage: $0 <create|provision|destroy|ssh|status|list|clean>" >&2
    exit 1
    ;;
esac
