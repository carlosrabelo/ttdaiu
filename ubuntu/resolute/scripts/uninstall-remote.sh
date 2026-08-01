#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Remote desktop and file transfer tools"
  apt_remove remmina filezilla
  log_ok "Remote desktop and file transfer tools removed."
}

main "$@"
