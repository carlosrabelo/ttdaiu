#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing QEMU / KVM"
  apt_install qemu-kvm virt-manager bridge-utils
  log_ok "QEMU installed."
}

main "$@"
