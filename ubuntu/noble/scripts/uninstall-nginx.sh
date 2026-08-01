#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing nginx + php-fpm"
  disable_service nginx
  disable_service php-fpm
  apt_remove nginx php-fpm
  log_ok "nginx removed."
}

main "$@"
