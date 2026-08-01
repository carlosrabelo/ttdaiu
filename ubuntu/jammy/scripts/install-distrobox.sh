#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

# Distrobox is not packaged for Ubuntu 22.04 Jammy — install from upstream.
DISTROBOX_INSTALL_URL="https://raw.githubusercontent.com/89luca89/distrobox/main/install"

main() {
  log_step "Installing Distrobox"

  if command -v distrobox &>/dev/null; then
    log_ok "Distrobox already installed — skipping."
    return 0
  fi

  log_info "Ubuntu 22.04 has no distrobox APT package — using upstream installer."

  apt_install curl uidmap

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] curl -sL ${DISTROBOX_INSTALL_URL} | sh -s -- --prefix /usr/local"
  else
    curl -sL "${DISTROBOX_INSTALL_URL}" | sh -s -- --prefix /usr/local
  fi

  if command -v docker &>/dev/null; then
    log_info "Docker detected — Distrobox can use it as container runtime."
  elif command -v podman &>/dev/null; then
    log_info "Podman detected — Distrobox can use it as container runtime."
  else
    log_warn "No container runtime found. Install the 'docker' component or ensure podman is available."
  fi

  log_ok "Distrobox installed."
}

main "$@"
