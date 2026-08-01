#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

FILES_DIR="${SCRIPTS_DIR}/../files/sysctl"
CONF_NAME="99-ttdaiu-swappiness.conf"
DEST="/etc/sysctl.d/${CONF_NAME}"

main() {
  log_step "Configuring sysctl (vm.swappiness=10)"

  local src="${FILES_DIR}/${CONF_NAME}"
  if [[ ! -f "${src}" ]]; then
    log_error "Sysctl config not found: ${src}"
    exit 1
  fi

  run_cmd mkdir -p /etc/sysctl.d

  if [[ "${DRY_RUN}" != "true" ]]; then
    install -m 644 "${src}" "${DEST}"
    log_info "Installed ${DEST}"
    sysctl -p "${DEST}"
  else
    log_info "[DRY-RUN] install -m 644 ${src} ${DEST}"
    log_info "[DRY-RUN] sysctl -p ${DEST}"
  fi

  log_ok "sysctl configured (vm.swappiness=10)."
}

main "$@"
