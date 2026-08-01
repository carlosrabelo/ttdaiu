#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Desktop utility packages"
  apt_install meld bleachbit mc evince gnome-tweaks wkhtmltopdf qrencode yadm
  log_ok "Desktop utility packages installed."
}

main "$@"
