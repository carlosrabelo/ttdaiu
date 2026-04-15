#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Gemini CLI (npm global)"

  if [[ "${DRY_RUN}" != "true" ]] && npm_global_installed "@google/gemini-cli"; then
    log_ok "Gemini CLI already installed — skipping."
    return 0
  fi

  npm_global @google/gemini-cli@latest
  log_ok "Gemini CLI installed."
}

main "$@"
