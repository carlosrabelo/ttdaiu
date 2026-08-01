#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing apt-upgrade component"
  log_warn "apt-upgrade only runs dist-upgrade/cleanup — nothing to uninstall."
  log_ok "Nothing to remove."
}

main "$@"
