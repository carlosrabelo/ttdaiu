#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing basic network packages"
  apt_install \
    net-tools nmap openssh-server rclone
  log_ok "basic network packages installed."
}

main "$@"
