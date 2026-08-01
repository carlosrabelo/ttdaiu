#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Uninstalling bash dotfiles (clean block removal)"

  remove_injected_block "bashrc_extras" "${MAIN_HOME}/.bashrc"
  remove_injected_block "profile_paths" "${MAIN_HOME}/.profile"
  remove_injected_block "aliases" "${MAIN_HOME}/.bash_aliases"
  remove_injected_block "extras" "${MAIN_HOME}/.bash_extras"

  # Clean up empty files if we created them and they are now empty/only whitespace
  local dotfiles=(.bash_aliases .bash_extras)
  for file in "${dotfiles[@]}"; do
    local path="${MAIN_HOME}/${file}"
    if [[ -f "${path}" ]]; then
      # If file only has newlines or is empty, delete it
      if ! grep -q '[^[:space:]]' "${path}"; then
        if [[ "${DRY_RUN}" == "true" ]]; then
          printf "${_YELLOW}[DRY-RUN]${_RESET} Would remove empty file %s\n" "${path}"
        else
          log_info "Removing empty file: ${file}"
          rm -f "${path}"
        fi
      fi
    fi
  done

  log_ok "Bash dotfiles uninstalled."
}

main "$@"
