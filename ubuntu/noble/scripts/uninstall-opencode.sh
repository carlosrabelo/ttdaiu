#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing OpenCode"

  local opencode_dir="${MAIN_HOME}/.opencode"
  local opencode_bin
  opencode_bin=$(sudo -u "${MAIN_USER}" which opencode 2>/dev/null || true)
  [[ -z "${opencode_bin}" && -x "${opencode_dir}/bin/opencode" ]] && opencode_bin="${opencode_dir}/bin/opencode"

  if [[ "${DRY_RUN}" != "true" ]]; then
    if [[ -n "${opencode_bin}" && -e "${opencode_bin}" ]]; then
      rm -f "${opencode_bin}"
      log_info "Removed: ${opencode_bin}"
    fi
    if [[ -d "${opencode_dir}" ]]; then
      rm -rf "${opencode_dir}"
      log_info "Removed: ${opencode_dir}"
    elif [[ -z "${opencode_bin}" ]]; then
      log_info "OpenCode not found — nothing to remove."
    fi
  else
    log_info "[DRY-RUN] rm -f ${opencode_bin:-<opencode>} ; rm -rf ${opencode_dir}"
  fi

  strip_ad_hoc_tool_path_rc
  log_ok "OpenCode removed."
}

main "$@"
