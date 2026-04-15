#!/usr/bin/env bash
# uninstall.sh — TTDAIU uninstaller for Ubuntu 24.04 Noble Numbat
# Usage: sudo bash uninstall.sh [--env=base|full] [--scripts=node,docker,...] [--dry-run]
set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SETUP_DIR}/scripts"

source "${SCRIPTS_DIR}/lib.sh"

# =============================================================================
# Argument parsing
# =============================================================================

ENV="full"
FILTER_SCRIPTS=""
export DRY_RUN=false

for arg in "$@"; do
  case "${arg}" in
    --env=*)      ENV="${arg#--env=}" ;;
    --scripts=*)  FILTER_SCRIPTS="${arg#--scripts=}" ;;
    --dry-run)    export DRY_RUN=true ;;
    *)            log_error "Unknown argument: ${arg}"; exit 1 ;;
  esac
done

# =============================================================================
# Pre-checks
# =============================================================================

require_root

get_main_user
detect_wsl
detect_systemd
get_os_version

log_step "TTDAIU — Uninstall"
log_info "OS version  : ${OS_VERSION}"
log_info "User        : ${MAIN_USER} (${MAIN_HOME})"
log_info "WSL         : ${IS_WSL}"
log_info "Systemd     : ${HAS_SYSTEMD}"
log_info "Environment : ${ENV}"
log_info "Scripts     : ${FILTER_SCRIPTS:-all}"
log_info "Dry-run     : ${DRY_RUN}"

if [[ "${OS_VERSION}" != "24.04" ]]; then
  log_error "This uninstaller targets Ubuntu 24.04 Noble. Detected: ${OS_VERSION}"
  exit 1
fi

# =============================================================================
# Script map by environment (mirrors setup.sh)
# =============================================================================

BASE_SCRIPTS=(
  backup
  packages
  bash
)

FULL_SCRIPTS=(
  qemu
  libvirt
  nginx
  z80
  github
  chromium
  code
  codium
  docker
  golang
  libreoffice
  node
  codex
  claude
  gemini
  opencode
)

# =============================================================================
# Build list of scripts to run
# =============================================================================

all_scripts=("${BASE_SCRIPTS[@]}")
if [[ "${ENV}" == "full" ]]; then
  all_scripts+=("${FULL_SCRIPTS[@]}")
fi

if [[ -n "${FILTER_SCRIPTS}" ]]; then
  IFS=',' read -ra requested <<< "${FILTER_SCRIPTS}"
  all_scripts=("${requested[@]}")
fi

# =============================================================================
# Run uninstall scripts
# =============================================================================

for script in "${all_scripts[@]}"; do
  script_path="${SCRIPTS_DIR}/uninstall-${script}.sh"
  if [[ ! -f "${script_path}" ]]; then
    log_warn "Uninstall script not found: ${script_path} — skipping"
    continue
  fi
  log_step "Running: uninstall-${script}.sh"
  bash "${script_path}"
done

log_step "Done!"
log_ok "TTDAIU uninstall complete."
if [[ "${DRY_RUN}" == "true" ]]; then
  log_warn "Dry-run mode: no changes were made."
fi
