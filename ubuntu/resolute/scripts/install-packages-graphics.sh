#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing graphics packages"

  apt_install \
    gimp inkscape mypaint imagemagick xfonts-75dpi xfonts-100dpi

  log_ok "Graphics packages installed."
}

main "$@"
