#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing productivity packages"

  apt_install \
    meld bleachbit mc evince gnome-tweaks remmina filezilla wkhtmltopdf qrencode yadm

  log_ok "Productivity packages installed."
}

main "$@"
