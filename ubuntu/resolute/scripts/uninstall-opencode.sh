#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing OpenCode"

  local opencode_bin
  opencode_bin=$(sudo -u "${MAIN_USER}" which opencode 2>/dev/null || true)

  if [[ -z "${opencode_bin}" ]]; then
    log_info "OpenCode binary not found — nothing to remove."
    return 0
  fi

  if [[ "${DRY_RUN}" != "true" ]]; then
    rm -f "${opencode_bin}"
    log_info "Removed: ${opencode_bin}"
  else
    log_info "[DRY-RUN] rm -f ${opencode_bin}"
  fi

  log_ok "OpenCode removed."
}

main "$@"
