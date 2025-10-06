#!/usr/bin/env bash
set -euo pipefail

MODE=${1:-}

if [[ -z "${MODE}" ]]; then
  echo "Usage: $0 <run|dry-run|test>" >&2
  exit 1
fi

UBUNTU_VERSION=${UBUNTU_VERSION:-noble}
ANSIBLE_DIR=${ANSIBLE_DIR:-./${UBUNTU_VERSION}}
PLAYBOOK=${PLAYBOOK:-site.yml}
INVENTORY=${INVENTORY:-inventory/production.ini}
TESTING_INVENTORY=${TESTING_INVENTORY:-inventory/testing.ini}
TAGS=${TAGS:-all}
ENVIRONMENT=${ENV:-production}

if [[ ! -d "${ANSIBLE_DIR}" ]]; then
  echo "Ansible directory not found: ${ANSIBLE_DIR}" >&2
  exit 1
fi

inventory_path=""
extra_args=()

case "${MODE}" in
  run)
    echo "Running TTDAIU setup (${ENVIRONMENT} environment)..."
    if [[ "${ENVIRONMENT}" == "testing" ]]; then
      inventory_path="${TESTING_INVENTORY}"
    else
      inventory_path="${INVENTORY}"
    fi
    ;;
  dry-run)
    echo "Running TTDAIU setup in check mode (${ENVIRONMENT} environment)..."
    if [[ "${ENVIRONMENT}" == "testing" ]]; then
      inventory_path="${TESTING_INVENTORY}"
    else
      inventory_path="${INVENTORY}"
    fi
    extra_args+=(--check --diff)
    ;;
  test)
    echo "Running TTDAIU setup in testing environment..."
    inventory_path="${TESTING_INVENTORY}"
    ;;
  *)
    echo "Invalid mode: ${MODE}" >&2
    echo "Usage: $0 <run|dry-run|test>" >&2
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

args+=(--ask-become-pass)

ansible-playbook "${args[@]}" "${extra_args[@]}"

popd >/dev/null
