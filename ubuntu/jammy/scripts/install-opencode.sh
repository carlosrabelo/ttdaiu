#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing OpenCode (native installer)"

  if [[ "${DRY_RUN}" != "true" ]] && command -v opencode &>/dev/null; then
    log_ok "OpenCode already installed — skipping."
    return 0
  fi

  if [[ "${DRY_RUN}" != "true" ]]; then
    if [[ $EUID -eq 0 ]]; then
      sudo -u "${MAIN_USER}" bash -c 'curl -fsSL https://opencode.ai/install | bash'
    else
      bash -c 'curl -fsSL https://opencode.ai/install | bash'
    fi
  else
    log_info "[DRY-RUN] curl -fsSL https://opencode.ai/install | bash"
  fi

  log_ok "OpenCode installed."
}

main "$@"
