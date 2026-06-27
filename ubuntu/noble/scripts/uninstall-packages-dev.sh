#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Uninstalling development extra packages"

  apt_remove \
    default-jdk default-jre gradle \
    php-cli php-gd php-imagick php-mysql php-snmp \
    postgresql-client \
    libsdl2-dev libsdl2-gfx-dev libsdl2-image-dev libsdl2-mixer-dev \
    libsdl2-net-dev libsdl2-ttf-dev love

  log_ok "Development extra packages uninstalled."
}

main "$@"
