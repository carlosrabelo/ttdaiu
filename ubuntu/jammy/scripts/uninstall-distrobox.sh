#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

DISTROBOX_UNINSTALL_URL="https://raw.githubusercontent.com/89luca89/distrobox/main/uninstall"

main() {
  log_step "Removing Distrobox"

  # Prefer APT remove if a package was installed somehow; else upstream uninstall.
  if dpkg -s distrobox &>/dev/null; then
    apt_remove distrobox
  elif [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] curl -sL ${DISTROBOX_UNINSTALL_URL} | sh -s -- --prefix /usr/local"
  elif command -v distrobox &>/dev/null || [[ -x /usr/local/bin/distrobox ]]; then
    curl -sL "${DISTROBOX_UNINSTALL_URL}" | sh -s -- --prefix /usr/local
  else
    log_info "Distrobox not found — nothing to remove."
  fi

  log_ok "Distrobox removed."
}

main "$@"
