#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing development extra packages"

  log_info "Installing Java development packages..."
  apt_install default-jdk default-jre gradle

  log_info "Installing PHP development packages..."
  apt_install php-cli php-gd php-imagick php-mysql php-snmp

  log_info "Installing Database client packages..."
  apt_install postgresql-client

  log_info "Installing SDL and game development libraries..."
  apt_install \
    libsdl2-dev libsdl2-gfx-dev libsdl2-image-dev libsdl2-mixer-dev \
    libsdl2-net-dev libsdl2-ttf-dev love

  log_ok "Development extra packages installed."
}

main "$@"
