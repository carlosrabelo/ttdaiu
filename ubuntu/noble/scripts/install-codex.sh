#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Codex (npm global)"

  if [[ "${DRY_RUN}" != "true" ]] && npm_global_installed "@openai/codex"; then
    log_ok "Codex already installed — skipping."
    return 0
  fi

  npm_global @openai/codex@latest
  log_ok "Codex installed."
}

main "$@"
