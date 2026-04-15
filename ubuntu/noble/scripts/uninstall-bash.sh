#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Restoring bash dotfiles from backup"

  local backup_configs="${MAIN_HOME}/.ttdaiu_backup/configs"
  local dotfiles=(.bashrc .bash_aliases .bash_extras .profile)

  if [[ ! -d "${backup_configs}" ]]; then
    log_warn "No backup found at ${backup_configs} — cannot restore dotfiles."
    log_warn "Restore manually or reinstall with: make install SCRIPT=bash"
    return 0
  fi

  for file in "${dotfiles[@]}"; do
    local backup="${backup_configs}/${file}.bak"
    local dest="${MAIN_HOME}/${file}"

    if [[ ! -f "${backup}" ]]; then
      log_info "No backup for ${file} — skipping."
      continue
    fi

    if [[ "${DRY_RUN}" != "true" ]]; then
      cp "${backup}" "${dest}"
      chown "${MAIN_USER}:${MAIN_USER}" "${dest}"
      log_info "Restored: ${file}"
    else
      log_info "[DRY-RUN] cp ${backup} → ${dest}"
    fi
  done

  log_ok "Bash dotfiles restored."
}

main "$@"
