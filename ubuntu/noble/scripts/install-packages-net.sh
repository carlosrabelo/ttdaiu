#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing network extra packages"

  apt_install \
    arp-scan avahi-autoipd avahi-utils \
    network-manager-l2tp network-manager-l2tp-gnome \
    network-manager-openconnect network-manager-openconnect-gnome \
    ssh-askpass sshpass gufw tor

  log_ok "Network extra packages installed."
}

main "$@"
