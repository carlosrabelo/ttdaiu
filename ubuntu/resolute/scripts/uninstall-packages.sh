#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Uninstalling system packages"
  log_warn "Mass uninstall of 100+ system packages is not supported."
  log_warn "Removing them automatically could break the system."
  log_warn "To remove a specific package: apt-get remove <package>"
}

main "$@"
