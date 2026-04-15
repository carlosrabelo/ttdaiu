#!/usr/bin/env bash
set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTS_DIR}/lib.sh"

main() {
  log_step "Installing system packages"

  # System upgrade
  if [[ "${DRY_RUN}" != "true" ]]; then
    log_info "Running dist-upgrade..."
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y -q
  else
    log_info "[DRY-RUN] apt-get dist-upgrade"
  fi

  log_info "Installing development packages..."
  apt_install \
    autoconf automake build-essential g++ make pkg-config \
    libcurl4-openssl-dev libgmp-dev libjansson-dev libssl-dev python3-dev zlib1g-dev \
    libsdl2-dev libsdl2-gfx-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev \
    git curl default-jdk default-jre gradle \
    python3-pip python3-virtualenv python-is-python3 \
    php-cli php-gd php-imagick php-mysql php-snmp \
    postgresql-client

  log_info "Installing network packages..."
  apt_install \
    arp-scan avahi-autoipd avahi-utils net-tools nmap \
    network-manager-l2tp network-manager-l2tp-gnome \
    network-manager-openconnect network-manager-openconnect-gnome \
    openssh-server ssh-askpass sshpass \
    gufw tor rclone

  log_info "Installing media packages..."
  apt_install vlc audacity lmms ffmpeg libspeechd2

  log_info "Installing graphics packages..."
  apt_install gimp inkscape mypaint imagemagick xfonts-75dpi xfonts-100dpi

  log_info "Installing productivity packages..."
  apt_install \
    meld bleachbit mc evince \
    gnome-tweaks remmina filezilla \
    wkhtmltopdf qrencode yadm

  log_info "Installing LaTeX packages..."
  apt_install \
    texlive texlive-lang-portuguese texlive-latex-extra texlive-publishers \
    texstudio texstudio-doc texstudio-l10n

  log_info "Installing system utilities..."
  apt_install btop htop preload neovim screen tree supervisor love

  # Cleanup
  if [[ "${DRY_RUN}" != "true" ]]; then
    log_info "Cleaning APT cache..."
    apt-get autoremove -y -q
    apt-get clean -q
  else
    log_info "[DRY-RUN] apt-get autoremove && apt-get clean"
  fi

  log_ok "System packages installed."
}

main "$@"
