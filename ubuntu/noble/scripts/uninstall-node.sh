#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Node.js"

  apt_remove nodejs build-essential

  # Remove repository and GPG key
  if [[ "${DRY_RUN}" != "true" ]]; then
    rm -f /etc/apt/sources.list.d/nodesource.list
    rm -f /usr/share/keyrings/nodesource.gpg
    log_info "Removed NodeSource repository and GPG key."
  else
    log_info "[DRY-RUN] rm -f /etc/apt/sources.list.d/nodesource.list /usr/share/keyrings/nodesource.gpg"
  fi

  # Remove npm global directory
  local npm_global="${MAIN_HOME}/.npm-global"
  if [[ "${DRY_RUN}" != "true" ]]; then
    if [[ -d "${npm_global}" ]]; then
      rm -rf "${npm_global}"
      log_info "Removed: ${npm_global}"
    fi
  else
    log_info "[DRY-RUN] rm -rf ${npm_global}"
  fi

  # Remove PATH line from .bashrc
  local bashrc="${MAIN_HOME}/.bashrc"
  if [[ "${DRY_RUN}" != "true" ]]; then
    if [[ -f "${bashrc}" ]] && grep -q '\.npm-global/bin' "${bashrc}"; then
      sed -i '/\.npm-global\/bin/d' "${bashrc}"
      log_info "Removed npm-global PATH from .bashrc"
    fi
  else
    log_info "[DRY-RUN] Would remove npm-global PATH line from .bashrc"
  fi

  log_ok "Node.js removed."
}

main "$@"
