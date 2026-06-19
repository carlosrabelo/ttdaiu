#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Gemini CLI"
  npm_global_remove @google/gemini-cli
  log_ok "Gemini CLI removed."
}

main "$@"
