#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Claude Code"

  local claude_bin
  claude_bin=$(sudo -u "${MAIN_USER}" which claude 2>/dev/null || true)

  if [[ -z "${claude_bin}" ]]; then
    log_info "Claude binary not found — nothing to remove."
    return 0
  fi

  if [[ "${DRY_RUN}" != "true" ]]; then
    rm -f "${claude_bin}"
    log_info "Removed: ${claude_bin}"
  else
    log_info "[DRY-RUN] rm -f ${claude_bin}"
  fi

  log_ok "Claude Code removed."
}

main "$@"
