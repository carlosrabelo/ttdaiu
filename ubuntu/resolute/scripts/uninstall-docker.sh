#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Docker"

  # Remove user from docker group
  if getent group docker &>/dev/null; then
    if id -nG "${MAIN_USER}" | grep -qw docker; then
      run_cmd gpasswd -d "${MAIN_USER}" docker || true
      log_info "User '${MAIN_USER}' removed from docker group."
    fi
  fi

  # Disable service
  disable_service docker

  # Remove packages
  apt_remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Remove repository and GPG key
  if [[ "${DRY_RUN}" != "true" ]]; then
    rm -f /etc/apt/sources.list.d/docker.list
    rm -f /etc/apt/keyrings/docker.asc
    log_info "Removed Docker repository and GPG key."
  else
    log_info "[DRY-RUN] rm -f /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.asc"
  fi

  log_ok "Docker removed."
}

main "$@"
