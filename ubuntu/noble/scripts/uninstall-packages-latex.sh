#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Uninstalling LaTeX packages"

  apt_remove \
    texlive texlive-lang-portuguese texlive-latex-extra texlive-publishers \
    texstudio texstudio-doc texstudio-l10n

  log_ok "LaTeX packages uninstalled."
}

main "$@"
