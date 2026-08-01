#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Updating and upgrading system packages"

  if [[ "${DRY_RUN}" != "true" ]]; then
    log_info "Running dist-upgrade..."
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y -q
    log_info "Cleaning APT cache..."
    apt-get autoremove -y -q
    apt-get clean -q
  else
    log_info "[DRY-RUN] apt-get dist-upgrade"
    log_info "[DRY-RUN] apt-get autoremove && apt-get clean"
  fi

  log_ok "System packages upgraded."
}

main "$@"
