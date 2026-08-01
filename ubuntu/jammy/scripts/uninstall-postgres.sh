#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing PostgreSQL"
  apt_remove postgresql-client
  log_ok "PostgreSQL removed."
}

main "$@"
