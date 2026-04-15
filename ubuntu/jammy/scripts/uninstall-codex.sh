#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Codex"
  npm_global_remove @openai/codex
  log_ok "Codex removed."
}

main "$@"
