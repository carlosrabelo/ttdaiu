#!/usr/bin/env bash
# lib.sh — shared functions for all TTDAIU scripts
# Source this file at the top of each install-*.sh

# Prevent direct execution
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && { echo "This is a library. Use: source lib.sh"; exit 1; }

# =============================================================================
# Colors and logging
# =============================================================================

_RED='\033[0;31m'
_GREEN='\033[0;32m'
_YELLOW='\033[1;33m'
_BLUE='\033[0;34m'
_BOLD='\033[1m'
_RESET='\033[0m'

log_info()  { printf "${_BLUE}[INFO]${_RESET}  %s\n" "$*"; }
log_ok()    { printf "${_GREEN}[OK]${_RESET}    %s\n" "$*"; }
log_warn()  { printf "${_YELLOW}[WARN]${_RESET}  %s\n" "$*"; }
log_error() { printf "${_RED}[ERROR]${_RESET} %s\n" "$*" >&2; }
log_step()  { printf "\n${_BOLD}==> %s${_RESET}\n" "$*"; }

# =============================================================================
# Dry-run
# =============================================================================

# Exported by setup.sh: DRY_RUN=true|false
DRY_RUN="${DRY_RUN:-false}"

# run_cmd — execute a command, or print it in dry-run mode
run_cmd() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf "${_YELLOW}[DRY-RUN]${_RESET} %s\n" "$*"
    return 0
  fi
  "$@"
}

# =============================================================================
# Environment detection
# =============================================================================

# Detect WSL — sets IS_WSL=true/false
detect_wsl() {
  IS_WSL=false
  if grep -qiE "microsoft|wsl" /proc/version 2>/dev/null; then
    IS_WSL=true
  elif [[ -f /usr/bin/wslpath ]]; then
    IS_WSL=true
  fi
  export IS_WSL
}

# Detect systemd — sets HAS_SYSTEMD=true/false
detect_systemd() {
  HAS_SYSTEMD=false
  if [[ -d /run/systemd/system ]]; then
    HAS_SYSTEMD=true
  fi
  export HAS_SYSTEMD
}

# Determine user and home — sets MAIN_USER and MAIN_HOME
# Works both when running as root (via sudo) and as a regular user
get_main_user() {
  if [[ $EUID -eq 0 ]]; then
    # Running as root: use whoever invoked sudo, or root if none
    MAIN_USER="${SUDO_USER:-root}"
  else
    # Running as regular user
    MAIN_USER="${USER:-$(whoami)}"
  fi
  if [[ "${MAIN_USER}" == "root" ]]; then
    MAIN_HOME="/root"
  else
    MAIN_HOME="/home/${MAIN_USER}"
  fi
  export MAIN_USER MAIN_HOME
}

# Get OS version — sets OS_VERSION (e.g. "24.04")
get_os_version() {
  OS_VERSION=$(lsb_release -sr 2>/dev/null || echo "unknown")
  export OS_VERSION
}

# =============================================================================
# Retry
# =============================================================================

# retry <attempts> <delay_seconds> <command...>
retry() {
  local attempts=$1 delay=$2
  shift 2
  local i=0
  until "$@"; do
    i=$((i + 1))
    if [[ $i -ge $attempts ]]; then
      log_error "Command failed after $attempts attempts: $*"
      return 1
    fi
    log_warn "Attempt $i/$attempts failed. Retrying in ${delay}s..."
    sleep "$delay"
  done
}

# =============================================================================
# APT
# =============================================================================

apt_install() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf "${_YELLOW}[DRY-RUN]${_RESET} apt-get install -y %s\n" "$*"
    return 0
  fi
  retry 3 5 apt-get install -y "$@"
}

apt_update() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf "${_YELLOW}[DRY-RUN]${_RESET} apt-get update\n"
    return 0
  fi
  retry 3 5 apt-get update -q
}

apt_remove() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf "${_YELLOW}[DRY-RUN]${_RESET} apt-get remove -y %s\n" "$*"
    return 0
  fi
  apt-get remove -y "$@" || true
  apt-get autoremove -y || true
}

# =============================================================================
# Snap
# =============================================================================

snap_install() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf "${_YELLOW}[DRY-RUN]${_RESET} snap install %s\n" "$*"
    return 0
  fi
  if ! command -v snap &>/dev/null; then
    log_warn "snapd not found — skipping snap install $*"
    return 0
  fi
  retry 3 10 snap install "$@"
}

snap_remove() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf "${_YELLOW}[DRY-RUN]${_RESET} snap remove %s\n" "$*"
    return 0
  fi
  if ! command -v snap &>/dev/null; then
    log_warn "snapd not found — skipping snap remove $*"
    return 0
  fi
  snap remove "$@" || true
}

# =============================================================================
# npm global (as MAIN_USER)
# =============================================================================

_npm_as_user() {
  if [[ $EUID -eq 0 ]]; then
    sudo -u "${MAIN_USER}" "$@"
  else
    "$@"
  fi
}

npm_global() {
  local prefix="${MAIN_HOME}/.npm-global"
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf "${_YELLOW}[DRY-RUN]${_RESET} npm install -g %s\n" "$*"
    return 0
  fi
  mkdir -p "${prefix}/bin" "${prefix}/lib/node_modules"
  [[ $EUID -eq 0 ]] && chown -R "${MAIN_USER}:${MAIN_USER}" "${prefix}"
  # Ensure the prefix is configured before installing
  _npm_as_user npm config set prefix "${prefix}"
  _npm_as_user npm install -g "$@"
}

# Check if an npm global package is already installed
npm_global_installed() {
  local pkg="$1"
  _npm_as_user npm list -g --depth=0 "${pkg}" &>/dev/null
}

npm_global_remove() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    printf "${_YELLOW}[DRY-RUN]${_RESET} npm uninstall -g %s\n" "$*"
    return 0
  fi
  _npm_as_user npm uninstall -g "$@" || true
}

# =============================================================================
# Systemd
# =============================================================================

enable_service() {
  local svc="$1"
  if [[ "${HAS_SYSTEMD:-false}" == "true" ]]; then
    run_cmd systemctl enable --now "${svc}"
  else
    log_warn "systemd not available — service '${svc}' not enabled"
  fi
}

disable_service() {
  local svc="$1"
  if [[ "${HAS_SYSTEMD:-false}" == "true" ]]; then
    run_cmd systemctl disable --now "${svc}" || true
  else
    log_warn "systemd not available — cannot disable service '${svc}'"
  fi
}

# =============================================================================
# Checks
# =============================================================================

require_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)."
    exit 1
  fi
}
