#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing GCC ARM embedded toolchain"
  apt_install gcc-arm-none-eabi
  log_ok "GCC ARM embedded toolchain installed."
}

main "$@"
