#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Z80 development tools"
  apt_install sdcc z80asm z80dasm
  log_ok "Z80 tools installed."
}

main "$@"
