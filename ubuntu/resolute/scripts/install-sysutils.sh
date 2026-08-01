#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing system utility packages"
  apt_install \
    btop cpu-x htop lm-sensors \
    neovim preload screen smartmontools \
    supervisor tree
  log_ok "system utility packages installed."
}

main "$@"
