#!/usr/bin/env bash
set -euo pipefail

MODE=${1:-}

if [[ -z "${MODE}" ]]; then
  echo "Usage: $0 <run|dry-run|uninstall|dry-uninstall>" >&2
  exit 1
fi

UBUNTU_VERSION="${UBUNTU_VERSION:-noble}"
VERSION_DIR="${VERSION_DIR:-./ubuntu/${UBUNTU_VERSION}}"
SCRIPT="${SCRIPT:-}"
ENV="${ENV:-full}"
HOST="${HOST:-}"

if [[ ! -d "${VERSION_DIR}" ]]; then
  echo "Directory not found: ${VERSION_DIR}" >&2
  exit 1
fi

# Build arguments for setup.sh / uninstall.sh
setup_args=("--env=${ENV}")
[[ -n "${SCRIPT}" ]] && setup_args+=("--scripts=${SCRIPT}")
[[ "${MODE}" == "dry-run" || "${MODE}" == "dry-uninstall" ]] && setup_args+=("--dry-run")

# Determine which main script to run
if [[ "${MODE}" == "uninstall" || "${MODE}" == "dry-uninstall" ]]; then
  MAIN_SCRIPT="uninstall.sh"
else
  MAIN_SCRIPT="setup.sh"
fi

# =============================================================================
# Local vs remote execution
# =============================================================================

if [[ -z "${HOST}" ]]; then
  # Local execution — use sudo since make is normally run without root
  echo "Running TTDAIU ${MODE} (local, ${UBUNTU_VERSION}, env=${ENV})..."
  cd "${VERSION_DIR}"
  sudo bash "${MAIN_SCRIPT}" "${setup_args[@]}"
else
  # Remote execution via SSH
  # Extract user from HOST (e.g. root@x042 → remote_user=root)
  remote_user="${HOST%%@*}"
  if [[ "${remote_user}" == "${HOST}" ]]; then
    remote_user="${USER}"  # no @ in HOST, use local user
  fi

  echo "Sending scripts to ${HOST} (${UBUNTU_VERSION})..."
  rsync -avz --delete "${VERSION_DIR}/" "${HOST}:/tmp/ttdaiu/"

  echo "Running ${MAIN_SCRIPT} on ${HOST}..."
  if [[ "${remote_user}" == "root" ]]; then
    # Already root — no sudo needed
    # shellcheck disable=SC2029
    ssh "${HOST}" "bash /tmp/ttdaiu/${MAIN_SCRIPT} ${setup_args[*]}"
  else
    # Regular user — use sudo (requires passwordless sudo on remote)
    # shellcheck disable=SC2029
    ssh "${HOST}" "sudo bash /tmp/ttdaiu/${MAIN_SCRIPT} ${setup_args[*]}"
  fi
fi
