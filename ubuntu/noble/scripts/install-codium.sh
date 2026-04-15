#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing VSCodium (snap)"
  enable_service snapd
  snap_install codium --classic
  log_ok "VSCodium installed."
}

main "$@"
