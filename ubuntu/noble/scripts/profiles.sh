#!/usr/bin/env bash
# profiles.sh — ENV profiles and named component groups for TTDAIU
# Sourced by setup.sh and uninstall.sh (do not execute directly).

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && { echo "This is a library. Use: source profiles.sh"; exit 1; }

# =============================================================================
# Base components (always included in ENV profiles)
# =============================================================================

BASE_SCRIPTS=(
  backup
  apt-upgrade
  build-tools
  network-base
  sysutils
  bash
  sysctl
  sudoers
)

# =============================================================================
# Named groups — usable in --scripts= / --components= / SCRIPT=
# =============================================================================

# Prints space-separated members for a group name. Returns 1 if unknown.
group_members() {
  case "$1" in
    devtools)  echo java php postgres github golang rust node docker distrobox ;;
    editors)   echo code codium qt ;;
    ai)        echo codex claude gemini opencode ;;
    virt)      echo qemu libvirt ;;
    embedded)  echo sdcc z80 m6502 arm ;;
    desktop)   echo graphics media desktop-utils flatpak ocr remote chromium libreoffice ;;
    network)   echo network-extra nginx ansible ;;
    gamedev)   echo godot sdl ;;
    *)         return 1 ;;
  esac
}

ALL_GROUPS=(devtools editors ai virt embedded desktop network gamedev)

# =============================================================================
# Full component list (canonical order for ENV=full)
# =============================================================================

FULL_SCRIPTS=(
  java
  php
  postgres
  sdl
  qt
  network-extra
  graphics
  media
  desktop-utils
  flatpak
  ocr
  remote
  latex
  qemu
  libvirt
  nginx
  sdcc
  z80
  m6502
  arm
  ansible
  godot
  github
  chromium
  code
  codium
  docker
  distrobox
  golang
  rust
  libreoffice
  node
  codex
  claude
  gemini
  opencode
)

# =============================================================================
# Profiles — ENV=base|desktop|devops|embedded|full
# =============================================================================

profile_extras() {
  case "$1" in
    base)
      ;;
    desktop)
      group_members desktop
      group_members editors
      echo latex
      ;;
    devops)
      group_members devtools
      group_members virt
      group_members network
      ;;
    embedded)
      group_members embedded
      group_members gamedev
      ;;
    full)
      printf "%s\n" "${FULL_SCRIPTS[@]}"
      ;;
    *)
      return 1
      ;;
  esac
}

ALL_PROFILES=(base desktop devops embedded full)

# =============================================================================
# Resolution
# =============================================================================

_append_unique() {
  local token existing
  for token in "$@"; do
    [[ -z "${token}" ]] && continue
    for existing in "${all_scripts[@]+"${all_scripts[@]}"}"; do
      [[ "${existing}" == "${token}" ]] && continue 2
    done
    all_scripts+=("${token}")
  done
}

_expand_token() {
  local token="$1"
  local -a members=()

  # Prefer reading group members into an array (safe word-splitting).
  case "$token" in
    devtools|editors|ai|virt|embedded|desktop|network|gamedev)
      # shellcheck disable=SC2207
      members=( $(group_members "${token}") )
      _append_unique "${members[@]}"
      ;;
    *)
      _append_unique "${token}"
      ;;
  esac
}

# resolve_scripts ENV FILTER
# Sets global all_scripts=() from profile and/or comma-separated filter.
# When FILTER is set, it replaces the profile list (groups expanded).
resolve_scripts() {
  local env_name="$1"
  local filter="${2:-}"
  local token extras
  local -a requested=()

  all_scripts=()

  if [[ -n "${filter}" ]]; then
    # Keep default IFS for later expansion; only split filter on commas here.
    IFS=',' read -ra requested <<< "${filter}"
    for token in "${requested[@]}"; do
      token="${token// /}"
      [[ -z "${token}" ]] && continue
      _expand_token "${token}"
    done
    return 0
  fi

  if ! extras="$(profile_extras "${env_name}")"; then
    log_error "Unknown ENV profile: ${env_name}"
    log_error "Valid profiles: ${ALL_PROFILES[*]}"
    return 1
  fi

  _append_unique "${BASE_SCRIPTS[@]}"
  # shellcheck disable=SC2086
  _append_unique ${extras}
}

list_profiles_and_groups() {
  local g members
  echo "Profiles (ENV):"
  for g in "${ALL_PROFILES[@]}"; do
    all_scripts=()
    resolve_scripts "${g}" ""
    echo "  ${g}: ${all_scripts[*]}"
  done
  echo
  echo "Groups (SCRIPT / COMPONENT):"
  for g in "${ALL_GROUPS[@]}"; do
    members="$(group_members "${g}")"
    echo "  ${g}: ${members}"
  done
  echo
  echo "Components (install-*.sh):"
  local f name dir
  dir="${SCRIPTS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
  for f in "${dir}"/install-*.sh; do
    [[ -f "${f}" ]] || continue
    name="$(basename "${f}")"
    name="${name#install-}"
    name="${name%.sh}"
    echo "  ${name}"
  done | sort
}
