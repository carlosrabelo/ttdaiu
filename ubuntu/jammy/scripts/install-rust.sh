#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

_rust_installed() {
  [[ -x "${MAIN_HOME}/.cargo/bin/rustc" ]] || [[ -x "${MAIN_HOME}/.cargo/bin/rustup" ]]
}

_run_as_user() {
  if [[ $EUID -eq 0 ]]; then
    sudo -u "${MAIN_USER}" "$@"
  else
    "$@"
  fi
}

main() {
  log_step "Installing Rust (rustup)"

  apt_install curl ca-certificates

  if [[ "${DRY_RUN}" != "true" ]] && _rust_installed; then
    log_info "Rust already installed — ensuring shell RC stays clean."
    strip_ad_hoc_tool_path_rc
    log_ok "Rust already installed — skipping."
    return 0
  fi

  if [[ "${DRY_RUN}" != "true" ]]; then
    # -y: unattended; --no-modify-path: PATH lives in bash .profile instead.
    _run_as_user bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path"
    strip_ad_hoc_tool_path_rc
    if [[ -x "${MAIN_HOME}/.cargo/bin/rustc" ]]; then
      log_ok "Rust installed: $("${MAIN_HOME}/.cargo/bin/rustc" --version)"
    else
      log_ok "Rust installed."
    fi
  else
    log_info "[DRY-RUN] curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path"
    strip_ad_hoc_tool_path_rc
    log_ok "Rust installed."
  fi
}

main "$@"
