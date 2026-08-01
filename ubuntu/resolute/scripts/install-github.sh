#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing GitHub CLI (gh)"

  apt_install wget

  run_cmd mkdir -p /etc/apt/keyrings
  run_cmd mkdir -p /etc/apt/sources.list.d

  log_info "Downloading GitHub CLI GPG key..."
  if [[ "${DRY_RUN}" != "true" ]]; then
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  else
    log_info "[DRY-RUN] Would download GPG key and add GitHub CLI repository"
  fi

  apt_update
  apt_install gh

  log_ok "GitHub CLI installed."
}

main "$@"
