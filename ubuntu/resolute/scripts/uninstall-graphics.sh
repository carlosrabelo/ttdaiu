#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Uninstalling graphics packages"

  apt_remove \
    gimp inkscape mypaint imagemagick xfonts-75dpi xfonts-100dpi

  log_ok "Graphics packages uninstalled."
}

main "$@"
