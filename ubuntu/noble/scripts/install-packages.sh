#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing system packages (Base)"

  # System upgrade
  if [[ "${DRY_RUN}" != "true" ]]; then
    log_info "Running dist-upgrade..."
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y -q
  else
    log_info "[DRY-RUN] apt-get dist-upgrade"
  fi

  log_info "Installing basic development packages..."
  apt_install \
    autoconf automake build-essential g++ make pkg-config \
    libcurl4-openssl-dev libgmp-dev libjansson-dev libssl-dev python3-dev zlib1g-dev \
    git curl python3-pip python3-virtualenv python-is-python3

  log_info "Installing basic network packages..."
  apt_install \
    net-tools nmap openssh-server rclone

  log_info "Installing basic system utilities..."
  apt_install \
    btop htop preload neovim screen tree supervisor

  # Cleanup
  if [[ "${DRY_RUN}" != "true" ]]; then
    log_info "Cleaning APT cache..."
    apt-get autoremove -y -q
    apt-get clean -q
  else
    log_info "[DRY-RUN] apt-get autoremove && apt-get clean"
  fi

  log_ok "Base system packages installed."
}

main "$@"
