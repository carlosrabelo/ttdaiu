#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

BACKUP_ENABLED="${BACKUP_ENABLED:-false}"
BACKUP_DIR="${MAIN_HOME}/.ttdaiu_backup"

BACKUP_FILES=(
  "${MAIN_HOME}/.bashrc"
  "${MAIN_HOME}/.bash_aliases"
  "${MAIN_HOME}/.bash_profile"
  "${MAIN_HOME}/.profile"
  "${MAIN_HOME}/.gitconfig"
  "${MAIN_HOME}/.vimrc"
  "${MAIN_HOME}/.tmux.conf"
  "${MAIN_HOME}/.ssh/config"
  "/etc/hosts"
)

_generate_restore_script() {
  local restore_script="${BACKUP_DIR}/restore.sh"
  cat > "${restore_script}" << 'RESTORE_EOF'
#!/usr/bin/env bash
# TTDAIU Configuration Restore Script
set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${BACKUP_DIR}/configs"
USER_HOME="${HOME}"

echo "TTDAIU Configuration Restore Script"
echo "==================================="
echo "Backup directory: ${BACKUP_DIR}"
echo ""

if [[ ! -d "${CONFIG_DIR}" ]]; then
  echo "Error: ${CONFIG_DIR} not found."
  exit 1
fi

restore_file() {
  local backup_file="$1"
  local target="$2"

  if [[ ! -f "${backup_file}" ]]; then
    echo "  No backup found for: ${target}"
    return
  fi
  echo -n "Restore ${target}? (y/N): "
  read -r resp
  if [[ "${resp}" =~ ^[Yy]$ ]]; then
    [[ -f "${target}" ]] && cp "${target}" "${target}.pre-restore-$(date +%Y%m%d_%H%M%S)"
    cp "${backup_file}" "${target}"
    echo "  Restored: ${target}"
  else
    echo "  Skipped: ${target}"
  fi
}

echo "Available backups:"
ls -la "${CONFIG_DIR}"
echo ""
echo -n "Continue with restore? (y/N): "
read -r cont
[[ "${cont}" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }
echo ""

for bak in "${CONFIG_DIR}"/*.bak; do
  [[ -f "${bak}" ]] || continue
  basename_no_bak="${bak%.bak}"
  filename="$(basename "${basename_no_bak}")"
  restore_file "${bak}" "${USER_HOME}/${filename}"
done

echo ""
echo "Restore complete. Log out and back in to apply shell changes."
RESTORE_EOF
  chmod +x "${restore_script}"
  chown "${MAIN_USER}:${MAIN_USER}" "${restore_script}"
}

main() {
  log_step "Backing up configuration files"

  if [[ "${BACKUP_ENABLED}" != "true" ]]; then
    log_info "Backup disabled (BACKUP_ENABLED=${BACKUP_ENABLED}). Skipping."
    log_info "To enable: BACKUP_ENABLED=true sudo bash setup.sh --scripts=backup"
    return 0
  fi

  if [[ "${DRY_RUN}" != "true" ]]; then
    mkdir -p "${BACKUP_DIR}/configs" "${BACKUP_DIR}/dotfiles" "${BACKUP_DIR}/scripts"
    chown -R "${MAIN_USER}:${MAIN_USER}" "${BACKUP_DIR}"
  else
    log_info "[DRY-RUN] Would create ${BACKUP_DIR}/{configs,dotfiles,scripts}/"
  fi

  local backed_up=0
  for file in "${BACKUP_FILES[@]}"; do
    if [[ ! -f "${file}" ]]; then
      log_info "Not found (skipping): ${file}"
      continue
    fi
    local dest="${BACKUP_DIR}/configs/$(basename "${file}").bak"
    if [[ -f "${dest}" ]]; then
      log_info "Already backed up: $(basename "${file}")"
      continue
    fi
    if [[ "${DRY_RUN}" != "true" ]]; then
      cp "${file}" "${dest}"
      chown "${MAIN_USER}:${MAIN_USER}" "${dest}"
      log_info "Backed up: ${file}"
    else
      log_info "[DRY-RUN] cp ${file} → ${dest}"
    fi
    backed_up=$((backed_up + 1))
  done

  if [[ "${DRY_RUN}" != "true" ]]; then
    _generate_restore_script
    log_info "Restore script generated: ${BACKUP_DIR}/restore.sh"
  fi

  log_ok "Backup complete (${backed_up} file(s))."
}

main "$@"
