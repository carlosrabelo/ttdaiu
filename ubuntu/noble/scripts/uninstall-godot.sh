#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Godot Engine"

  if [[ -f /usr/local/bin/godot ]]; then
    run_cmd rm -f /usr/local/bin/godot
    log_ok "Godot removed."
  else
    log_info "Godot is not installed — nothing to do."
  fi
}

main "$@"
