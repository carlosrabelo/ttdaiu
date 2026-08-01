#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing build and development toolchain"
  apt_remove \
    autoconf automake build-essential cmake \
    g++ make pkg-config libcurl4-openssl-dev \
    libgmp-dev libjansson-dev libssl-dev python3-dev \
    zlib1g-dev git curl jq \
    python3-pip python3-virtualenv python-is-python3 shellcheck
  log_ok "build and development toolchain removed."
}

main "$@"
