#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Qt 6 development packages"
  apt_remove qtcreator qt6-base-dev qt6-declarative-dev qt6-tools-dev
  log_ok "Qt 6 development packages removed."
}

main "$@"
