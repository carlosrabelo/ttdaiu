#!/usr/bin/env bash
set -euo pipefail

# Suppress all cryptography and paramiko warnings
export PYTHONWARNINGS="ignore::DeprecationWarning:paramiko.*,ignore::DeprecationWarning:cryptography.*"



MODE=${1:-}

if [[ -z "${MODE}" ]]; then
  echo "Usage: $0 <run|dry-run|full>" >&2
  exit 1
fi

UBUNTU_VERSION=${UBUNTU_VERSION:-noble}
ANSIBLE_DIR=${ANSIBLE_DIR:-./${UBUNTU_VERSION}}
PLAYBOOK=${PLAYBOOK:-site.yml}
INVENTORY=${INVENTORY:-inventory/base.ini}
FULL_INVENTORY=${FULL_INVENTORY:-inventory/full.ini}
TAGS=${TAGS:-all}
ENVIRONMENT=${ENV:-base}

if [[ ! -d "${ANSIBLE_DIR}" ]]; then
  echo "Ansible directory not found: ${ANSIBLE_DIR}" >&2
  exit 1
fi

inventory_path=""
extra_args=()

case "${MODE}" in
  run)
    echo "Running TTDAIU setup (${ENVIRONMENT} environment)..."
    if [[ "${ENVIRONMENT}" == "full" ]]; then
      inventory_path="${FULL_INVENTORY}"
    else
      inventory_path="${INVENTORY}"
    fi
    ;;
  dry-run)
    echo "Running TTDAIU setup in check mode (${ENVIRONMENT} environment)..."
    if [[ "${ENVIRONMENT}" == "full" ]]; then
      inventory_path="${FULL_INVENTORY}"
    else
      inventory_path="${INVENTORY}"
    fi
    extra_args+=(--check --diff)
    ;;
  full)
    echo "Running TTDAIU setup in full environment..."
    inventory_path="${FULL_INVENTORY}"
    ;;
  *)
    echo "Invalid mode: ${MODE}" >&2
    echo "Usage: $0 <run|dry-run|full>" >&2
    exit 1
    ;;
esac

if [[ -z "${inventory_path}" ]]; then
  echo "Inventory path not resolved" >&2
  exit 1
fi

pushd "${ANSIBLE_DIR}" >/dev/null

args=("${PLAYBOOK}" "-i" "${inventory_path}")

if [[ -n "${TAGS}" ]]; then
  args+=(--tags "${TAGS}")
fi

args+=(--become-method=sudo)

ansible-playbook "${args[@]}" "${extra_args[@]}"

popd >/dev/null
