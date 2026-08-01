#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Godot Engine"

  if ! command -v curl &>/dev/null; then
    apt_install curl
  fi

  if ! command -v unzip &>/dev/null; then
    apt_install unzip
  fi

  log_info "Fetching latest Godot release…"
  local tag
  tag=$(curl -sSfL "https://api.github.com/repos/godotengine/godot/releases/latest" \
    | grep '"tag_name":' \
    | sed 's/.*"tag_name": "\(.*\)",.*/\1/')

  if [[ -z "${tag}" ]]; then
    log_error "Could not determine latest Godot version from GitHub API"
    exit 1
  fi

  local version="${tag%-stable}"
  local filename="Godot_v${version}-stable_linux.x86_64.zip"
  local url="https://github.com/godotengine/godot/releases/download/${tag}/${filename}"

  local tmpdir
  tmpdir=$(mktemp -d)
  local zip_path="${tmpdir}/${filename}"

  log_info "Downloading Godot ${version}…"
  run_cmd curl -#fL "${url}" -o "${zip_path}"

  log_info "Extracting…"
  run_cmd unzip -q "${zip_path}" -d "${tmpdir}"

  local binary_path="${tmpdir}/Godot_v${version}-stable_linux.x86_64"
  if [[ ! -f "${binary_path}" ]]; then
    log_error "Binary not found after extraction"
    exit 1
  fi

  run_cmd install -m 0755 "${binary_path}" /usr/local/bin/godot
  run_cmd rm -rf "${tmpdir}"

  if [[ "${DRY_RUN}" != "true" ]] && command -v godot &>/dev/null; then
    log_ok "Godot installed: $(godot --version)"
  else
    log_ok "Godot installed."
  fi
}

main "$@"
