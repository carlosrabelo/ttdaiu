#!/usr/bin/env bash
set -euo pipefail

MODE=${1:-}

if [[ -z "${MODE}" ]]; then
  echo "Usage: $0 <run|dry-run|uninstall|dry-uninstall|list>" >&2
  exit 1
fi

UBUNTU_VERSION="${UBUNTU_VERSION:-}"
if [[ -z "${UBUNTU_VERSION}" ]]; then
  if [[ -z "${HOST:-}" ]]; then
    detected_codename=$(lsb_release -sc 2>/dev/null || true)
    if [[ "${detected_codename}" == "resolute" || "${detected_codename}" == "noble" || "${detected_codename}" == "jammy" ]]; then
      UBUNTU_VERSION="${detected_codename}"
    else
      UBUNTU_VERSION="noble"
    fi
  else
    UBUNTU_VERSION="noble"
  fi
fi
VERSION_DIR="${VERSION_DIR:-./ubuntu/${UBUNTU_VERSION}}"
# COMPONENT is an alias for SCRIPT (groups and/or component names)
SCRIPT="${SCRIPT:-${COMPONENT:-}}"
ENV="${ENV:-full}"
HOST="${HOST:-}"

if [[ ! -d "${VERSION_DIR}" ]]; then
  echo "Directory not found: ${VERSION_DIR}" >&2
  exit 1
fi

# Build arguments for setup.sh / uninstall.sh
setup_args=("--env=${ENV}")
[[ -n "${SCRIPT}" ]] && setup_args+=("--components=${SCRIPT}")
[[ "${MODE}" == "dry-run" || "${MODE}" == "dry-uninstall" ]] && setup_args+=("--dry-run")

# Determine which main script to run
if [[ "${MODE}" == "uninstall" || "${MODE}" == "dry-uninstall" ]]; then
  MAIN_SCRIPT="uninstall.sh"
else
  MAIN_SCRIPT="setup.sh"
fi

# =============================================================================
# List profiles / groups / components (no root required)
# =============================================================================

if [[ "${MODE}" == "list" ]]; then
  echo "TTDAIU catalog (${UBUNTU_VERSION}):"
  cd "${VERSION_DIR}"
  bash "${MAIN_SCRIPT}" --list
  exit 0
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
