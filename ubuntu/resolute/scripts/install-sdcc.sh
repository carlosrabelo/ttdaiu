#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing SDCC (Small Device C Compiler) suite"
  apt_install sdcc sdcc-doc gputils
  log_ok "SDCC suite installed."
}

main "$@"
