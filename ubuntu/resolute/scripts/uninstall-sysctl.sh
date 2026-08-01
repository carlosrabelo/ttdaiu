#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

DEST="/etc/sysctl.d/99-ttdaiu-swappiness.conf"

main() {
  log_step "Removing sysctl configuration"

  if [[ "${DRY_RUN}" != "true" ]]; then
    if [[ -f "${DEST}" ]]; then
      rm -f "${DEST}"
      log_info "Removed ${DEST}"
      sysctl --system >/dev/null 2>&1 || true
    else
      log_info "No TTDAIU sysctl config found — nothing to remove."
    fi
  else
    log_info "[DRY-RUN] rm -f ${DEST}"
  fi

  log_ok "sysctl configuration removed."
}

main "$@"
