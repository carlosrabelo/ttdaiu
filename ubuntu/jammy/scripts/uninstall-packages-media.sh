#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Uninstalling media packages"

  apt_remove \
    vlc audacity lmms ffmpeg libspeechd2

  log_ok "Media packages uninstalled."
}

main "$@"
