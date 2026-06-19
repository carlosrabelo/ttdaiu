#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Visual Studio Code (snap)"
  enable_service snapd
  snap_install code --classic
  log_ok "VS Code installed."
}

main "$@"
