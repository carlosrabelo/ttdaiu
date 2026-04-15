#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing LibreOffice (snap)"
  enable_service snapd
  snap_install libreoffice
  log_ok "LibreOffice installed."
}

main "$@"
