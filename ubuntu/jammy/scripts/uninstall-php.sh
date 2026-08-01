#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing PHP development packages"
  apt_remove php-cli php-gd php-imagick php-mysql php-snmp
  log_ok "PHP development packages removed."
}

main "$@"
