#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Claude Code (native installer)"

  if [[ "${DRY_RUN}" != "true" ]] && sudo -u "${MAIN_USER}" command -v claude &>/dev/null; then
    log_ok "Claude already installed — skipping."
    return 0
  fi

  if [[ "${DRY_RUN}" != "true" ]]; then
    if [[ $EUID -eq 0 ]]; then
      sudo -u "${MAIN_USER}" bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
    else
      bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
    fi
  else
    log_info "[DRY-RUN] curl -fsSL https://claude.ai/install.sh | bash"
  fi

  log_ok "Claude Code installed."
}

main "$@"
