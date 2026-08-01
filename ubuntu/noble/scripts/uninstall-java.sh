#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Java development packages"
  apt_remove default-jdk default-jre gradle
  log_ok "Java development packages removed."
}

main "$@"
