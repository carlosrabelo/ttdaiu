#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Go"

  snap_remove go

  local gopath="${MAIN_HOME}/go"
  if [[ "${DRY_RUN}" != "true" ]]; then
    if [[ -d "${gopath}" ]]; then
      rm -rf "${gopath}"
      log_info "Removed GOPATH: ${gopath}"
    fi
  else
    log_info "[DRY-RUN] rm -rf ${gopath}"
  fi

  log_ok "Go removed."
}

main "$@"
