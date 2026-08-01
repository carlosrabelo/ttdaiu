#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing OpenCode (native installer)"

  if [[ "${DRY_RUN}" != "true" ]] && { command -v opencode &>/dev/null || [[ -x "${MAIN_HOME}/.opencode/bin/opencode" ]]; }; then
    log_info "OpenCode already installed — ensuring shell RC stays clean."
    strip_ad_hoc_tool_path_rc
    log_ok "OpenCode already installed — skipping."
    return 0
  fi

  if [[ "${DRY_RUN}" != "true" ]]; then
    # PATH for ~/.opencode/bin lives in bash .profile (not shell RC snippets).
    if [[ $EUID -eq 0 ]]; then
      sudo -u "${MAIN_USER}" bash -c 'curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path'
    else
      bash -c 'curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path'
    fi
  else
    log_info "[DRY-RUN] curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path"
  fi

  strip_ad_hoc_tool_path_rc
  log_ok "OpenCode installed."
}

main "$@"
