#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

FILES_DIR="${SCRIPTS_DIR}/../files/bash"

main() {
  log_step "Installing bash dotfiles"

  if [[ ! -d "${FILES_DIR}" ]]; then
    log_error "Dotfiles directory not found: ${FILES_DIR}"
    exit 1
  fi

  local dotfiles=(.bashrc .bash_aliases .bash_extras .profile)

  for file in "${dotfiles[@]}"; do
    local src="${FILES_DIR}/${file}"
    local dest="${MAIN_HOME}/${file}"

    if [[ ! -f "${src}" ]]; then
      log_warn "Dotfile not found: ${src} — skipping"
      continue
    fi

    if [[ "${DRY_RUN}" != "true" ]]; then
      cp "${src}" "${dest}"
      chown "${MAIN_USER}:${MAIN_USER}" "${dest}"
      log_info "Copied: ${file}"
    else
      log_info "[DRY-RUN] cp ${src} → ${dest}"
    fi
  done

  log_ok "Bash dotfiles installed."
}

main "$@"
