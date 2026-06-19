#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing nginx + php-fpm"
  apt_install nginx php-fpm
  log_ok "nginx installed."
}

main "$@"
