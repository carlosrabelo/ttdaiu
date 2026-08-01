#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Removing Tesseract OCR"
  apt_remove tesseract-ocr tesseract-ocr-por
  log_ok "Tesseract OCR removed."
}

main "$@"
