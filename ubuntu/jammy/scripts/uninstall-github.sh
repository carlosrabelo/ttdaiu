#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing GitHub CLI"

  apt_remove gh

  if [[ "${DRY_RUN}" != "true" ]]; then
    rm -f /etc/apt/sources.list.d/github-cli.list
    rm -f /etc/apt/keyrings/githubcli-archive-keyring.gpg
    log_info "Removed GitHub CLI repository and GPG key."
  else
    log_info "[DRY-RUN] rm -f /etc/apt/sources.list.d/github-cli.list /etc/apt/keyrings/githubcli-archive-keyring.gpg"
  fi

  log_ok "GitHub CLI removed."
}

main "$@"
