#!/usr/bin/env bash
# setup.sh — TTDAIU orchestrator for Ubuntu 22.04 Jammy Jellyfish
# Usage: sudo bash setup.sh [--env=base|desktop|devops|embedded|full] [--scripts=|--components=] [--list] [--dry-run]
set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SETUP_DIR}/scripts"

source "${SCRIPTS_DIR}/lib.sh"

# =============================================================================
# Argument parsing
# =============================================================================

ENV="full"
FILTER_SCRIPTS=""
LIST_ONLY=false
export DRY_RUN=false

for arg in "$@"; do
  case "${arg}" in
    --env=*)           ENV="${arg#--env=}" ;;
    --scripts=*)       FILTER_SCRIPTS="${arg#--scripts=}" ;;
    --components=*)    FILTER_SCRIPTS="${arg#--components=}" ;;
    --list)            LIST_ONLY=true ;;
    --dry-run)         export DRY_RUN=true ;;
    *)                 log_error "Unknown argument: ${arg}"; exit 1 ;;
  esac
done

# List profiles/groups/components without requiring root
if [[ "${LIST_ONLY}" == "true" ]]; then
  source "${SCRIPTS_DIR}/profiles.sh"
  list_profiles_and_groups
  exit 0
fi

# =============================================================================
# Pre-checks
# =============================================================================

require_root

get_main_user
detect_wsl
detect_systemd
get_os_version

log_step "TTDAIU — Things to do after installing Ubuntu"
log_info "OS version  : ${OS_VERSION}"
log_info "User        : ${MAIN_USER} (${MAIN_HOME})"
log_info "WSL         : ${IS_WSL}"
log_info "Systemd     : ${HAS_SYSTEMD}"
log_info "Environment : ${ENV}"
log_info "Components : ${FILTER_SCRIPTS:-all}"
log_info "Dry-run     : ${DRY_RUN}"

if [[ "${OS_VERSION}" != "22.04" ]]; then
  log_error "This setup is for Ubuntu 22.04 Jammy. Detected version: ${OS_VERSION}"
  exit 1
fi

# =============================================================================
# Script map (profiles + groups) — see scripts/profiles.sh
# =============================================================================

source "${SCRIPTS_DIR}/profiles.sh"

# =============================================================================
# Build list of scripts to run
# =============================================================================

if ! resolve_scripts "${ENV}" "${FILTER_SCRIPTS}"; then
  exit 1
fi

log_info "Resolved components: ${all_scripts[*]}"


# =============================================================================
# Update APT cache
# =============================================================================

if [[ -z "${FILTER_SCRIPTS}" ]]; then
  log_step "Updating APT cache"
  apt_update
fi

# =============================================================================
# Run scripts
# =============================================================================

for script in "${all_scripts[@]}"; do
  script_path="${SCRIPTS_DIR}/install-${script}.sh"
  if [[ ! -f "${script_path}" ]]; then
    log_warn "Script not found: ${script_path} — skipping"
    continue
  fi
  log_step "Running: install-${script}.sh"
  bash "${script_path}"
done

log_step "Done!"
log_ok "TTDAIU setup complete."
if [[ "${DRY_RUN}" == "true" ]]; then
  log_warn "Dry-run mode: no changes were made."
fi
