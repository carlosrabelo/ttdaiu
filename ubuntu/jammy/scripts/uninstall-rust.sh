#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

_run_as_user() {
  if [[ $EUID -eq 0 ]]; then
    sudo -u "${MAIN_USER}" "$@"
  else
    "$@"
  fi
}

main() {
  log_step "Removing Rust (rustup)"

  local rustup_bin="${MAIN_HOME}/.cargo/bin/rustup"
  local cargo_dir="${MAIN_HOME}/.cargo"
  local rustup_dir="${MAIN_HOME}/.rustup"

  if [[ "${DRY_RUN}" != "true" ]]; then
    if [[ -x "${rustup_bin}" ]]; then
      _run_as_user "${rustup_bin}" self uninstall -y
      log_info "Ran: rustup self uninstall -y"
    elif [[ -d "${cargo_dir}" ]] || [[ -d "${rustup_dir}" ]]; then
      rm -rf "${cargo_dir}" "${rustup_dir}"
      log_info "Removed ${cargo_dir} and/or ${rustup_dir}"
    else
      log_info "Rust not found — nothing to remove."
    fi
  else
    log_info "[DRY-RUN] rustup self uninstall -y (or rm -rf ${cargo_dir} ${rustup_dir})"
  fi

  strip_ad_hoc_tool_path_rc

  log_ok "Rust removed."
}

main "$@"
