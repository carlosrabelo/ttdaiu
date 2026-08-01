#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

DEST="/etc/sudoers.d/99-ttdaiu-nopasswd"

main() {
  log_step "Removing TTDAIU sudoers drop-in"

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] rm -f ${DEST}"
    log_ok "sudoers dry-run complete."
    return 0
  fi

  if [[ -f "${DEST}" ]]; then
    rm -f "${DEST}"
    log_info "Removed ${DEST}"
  else
    log_info "No TTDAIU sudoers drop-in found — nothing to remove."
  fi

  log_ok "TTDAIU sudoers configuration removed."
}

main "$@"
