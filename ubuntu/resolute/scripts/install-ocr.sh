#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing Tesseract OCR"
  apt_install tesseract-ocr tesseract-ocr-por
  log_ok "Tesseract OCR installed."
}

main "$@"
