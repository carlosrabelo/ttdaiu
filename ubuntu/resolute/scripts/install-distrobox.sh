#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Distrobox"

  # Package from Ubuntu universe for this release (pulls podman|docker.io + uidmap).
  apt_install distrobox

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
