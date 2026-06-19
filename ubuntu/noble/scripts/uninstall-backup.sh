#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing TTDAIU backup directory"

  local backup_dir="${MAIN_HOME}/.ttdaiu_backup"

  if [[ ! -d "${backup_dir}" ]]; then
    log_info "Backup directory not found: ${backup_dir} — nothing to remove."
    return 0
  fi

  if [[ "${DRY_RUN}" != "true" ]]; then
    rm -rf "${backup_dir}"
    log_ok "Removed: ${backup_dir}"
  else
    log_info "[DRY-RUN] rm -rf ${backup_dir}"
    log_ok "Would remove: ${backup_dir}"
  fi
}

main "$@"
