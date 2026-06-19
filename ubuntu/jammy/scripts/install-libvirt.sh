#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing libvirt"
  apt_install libvirt-clients libvirt-daemon-system libvirt-dev
  log_ok "libvirt installed."
}

main "$@"
