#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Go (snap)"

  enable_service snapd
  snap_install go --classic

  # Create GOPATH workspace
  local gopath="${MAIN_HOME}/go"
  for dir in src bin pkg; do
    run_cmd mkdir -p "${gopath}/${dir}"
    run_cmd chown "${MAIN_USER}:${MAIN_USER}" "${gopath}/${dir}"
  done

  if [[ "${DRY_RUN}" != "true" ]] && command -v go &>/dev/null; then
    log_ok "Go installed: $(go version)"
  else
    log_ok "Go installed."
  fi
}

main "$@"
