#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing SDCC (Small Device C Compiler) suite"
  apt_remove sdcc sdcc-doc gputils
  log_ok "SDCC suite removed."
}

main "$@"
