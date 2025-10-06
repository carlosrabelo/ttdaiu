#!/usr/bin/env bash
set -euo pipefail

COMMAND=${1:-}
if [[ -z "${COMMAND}" ]]; then
  echo "Usage: $0 <up|provision|destroy|status|ssh|destroy-all|clean>" >&2
  exit 1
fi
shift || true

UBUNTU_VERSION=${UBUNTU_VERSION:-noble}
ANSIBLE_DIR=${ANSIBLE_DIR:-./${UBUNTU_VERSION}}

ensure_dir() {
  if [[ ! -d "${ANSIBLE_DIR}" ]]; then
    echo "Ansible directory not found: ${ANSIBLE_DIR}" >&2
    exit 1
  fi
}

run_vagrant() {
  ensure_dir
  pushd "${ANSIBLE_DIR}" >/dev/null
  vagrant "$@"
  popd >/dev/null
}

case "${COMMAND}" in
  up)
    echo "Starting Vagrant environment for ${UBUNTU_VERSION}..."
    run_vagrant up
    ;;
  provision)
    echo "Provisioning Vagrant environment for ${UBUNTU_VERSION}..."
    run_vagrant provision
    ;;
  destroy)
    echo "Destroying Vagrant environment for ${UBUNTU_VERSION}..."
    run_vagrant destroy -f
    ;;
  status)
    echo "Vagrant status for ${UBUNTU_VERSION}:"
    run_vagrant status
    ;;
  ssh)
    echo "SSH into ${UBUNTU_VERSION} Vagrant box..."
    run_vagrant ssh
    ;;
  destroy-all)
    echo "Destroying all Vagrant environments..."
    for version in noble jammy; do
      if [[ -d "./${version}" ]]; then
        (cd "./${version}" && vagrant destroy -f 2>/dev/null) || true
      fi
    done
    ;;
  clean)
    "$0" destroy-all
    echo "Removing Vagrant global status entries..."
    vagrant global-status --prune
    ;;
  *)
    echo "Unknown command: ${COMMAND}" >&2
    echo "Usage: $0 <up|provision|destroy|status|ssh|destroy-all|clean>" >&2
    exit 1
    ;;
esac
