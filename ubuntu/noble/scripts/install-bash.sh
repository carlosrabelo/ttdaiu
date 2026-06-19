#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

FILES_DIR="${SCRIPTS_DIR}/../files/bash"

main() {
  log_step "Installing bash dotfiles (non-destructive injection)"

  if [[ ! -d "${FILES_DIR}" ]]; then
    log_error "Dotfiles directory not found: ${FILES_DIR}"
    exit 1
  fi

  local dotfiles=(.bashrc .profile .bash_aliases .bash_extras)

  for file in "${dotfiles[@]}"; do
    local src="${FILES_DIR}/${file}"
    local dest="${MAIN_HOME}/${file}"

    if [[ ! -f "${src}" ]]; then
      log_warn "Dotfile template not found: ${src} — skipping"
      continue
    fi

    local marker search_str
    case "${file}" in
      .bashrc)
        marker="bashrc_extras"
        search_str="bash_extras"
        ;;
      .profile)
        marker="profile_paths"
        search_str="export GOROOT=/snap/go/current"
        ;;
      .bash_aliases)
        marker="aliases"
        search_str="alias set-git-config-home="
        ;;
      .bash_extras)
        marker="extras"
        search_str="__git_ps1"
        ;;
      *)
        log_error "Unknown dotfile type: ${file}"
        exit 1
        ;;
    esac

    inject_block_if_missing "${marker}" "${dest}" "${src}" "${search_str}"
  done

  log_ok "Bash dotfiles installed/injected successfully."
}

main "$@"
