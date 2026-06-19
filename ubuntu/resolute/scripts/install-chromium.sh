#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Chromium (snap)"
  enable_service snapd
  snap_install chromium
  log_ok "Chromium installed."
}

main "$@"
