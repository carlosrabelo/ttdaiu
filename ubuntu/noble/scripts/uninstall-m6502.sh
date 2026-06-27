#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing 6502 development tools"
  apt_remove cc65 xa65
  log_ok "6502 tools removed."
}

main "$@"
