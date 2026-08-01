#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Java development packages"
  apt_install default-jdk default-jre gradle
  log_ok "Java development packages installed."
}

main "$@"
