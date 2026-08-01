# TTDAIU - Detailed Guide

## Table of Contents

1. [Make Targets](#make-targets)
2. [Variables](#variables)
3. [Available Scripts](#available-scripts)
4. [Remote Execution via SSH](#remote-execution-via-ssh)
5. [How It Works](#how-it-works)
6. [Troubleshooting](#troubleshooting)

---

## Make Targets

| Target | Description |
|--------|-------------|
| `make install` | Run setup (local by default) |
| `make dry-install` | Preview what would run, no changes made |
| `make list` | List profiles, groups, and components |
| `make install-deps` | Install `curl` and `rsync` |
| `make info` | Show current configuration |
| `make clean` | Clean temporary files |
| `make help` | Show usage summary |

---

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `UBUNTU_VERSION` | `noble` | `resolute` (26.04), `noble` (24.04) or `jammy` (22.04) |
| `ENV` | `full` | Profile: `base`, `desktop`, `devops`, `embedded`, or `full` |
| `SCRIPT` / `COMPONENT` | *(all)* | Comma-separated components and/or named groups (replaces `ENV` list) |
| `HOST` | *(local)* | Remote target, e.g. `root@192.168.1.10` |

### Examples

```bash
make install                                         # Noble, full, local
make install ENV=base                                # Base profile only
make install ENV=desktop                             # Desktop profile
make install ENV=devops                              # DevOps profile
make install ENV=embedded                            # Embedded / retro profile
make install SCRIPT=ai,docker                        # Named group + component
make install COMPONENT=qt,ocr                        # Alias of SCRIPT
make install SCRIPT=devtools,virt                    # Named groups only
make install SCRIPT=java                             # Single focused component
make list                                            # Catalog of profiles/groups/components
make install UBUNTU_VERSION=jammy HOST=root@server   # Jammy on remote host
make install UBUNTU_VERSION=resolute                 # Resolute/26.04 local
make dry-install SCRIPT=ai                           # Preview AI group only
```

### Persistent configuration with `.env`

```bash
cat > .env << EOF
UBUNTU_VERSION=jammy
ENV=full
EOF

make install SCRIPT=docker   # picks up UBUNTU_VERSION and ENV from .env
```

---

## Available Scripts

Profiles and groups are defined in `ubuntu/*/scripts/profiles.sh`.

### Profiles (`ENV`)

| Profile | What it runs |
|---------|--------------|
| `base` | `backup`, `apt-upgrade`, `build-tools`, `network-base`, `sysutils`, `bash`, `sysctl`, `sudoers` |
| `desktop` | base + `desktop` + `editors` + `latex` |
| `devops` | base + `devtools` + `virt` + `network` groups |
| `embedded` | base + `embedded` + `gamedev` groups |
| `full` | base + every component script |

### Named groups (`SCRIPT`)

| Group | Expands to |
|-------|------------|
| `devtools` | java, php, postgres, github, golang, rust, node, docker, distrobox |
| `editors` | code, codium, qt |
| `ai` | codex, claude, gemini, opencode |
| `virt` | qemu, libvirt |
| `embedded` | sdcc, z80, m6502, arm |
| `desktop` | graphics, media, desktop-utils, flatpak, ocr, remote, chromium, libreoffice |
| `network` | network-extra, nginx, ansible |
| `gamedev` | godot, sdl |

When `SCRIPT` / `COMPONENT` is set, it **replaces** the profile list. Mix groups and components freely (`SCRIPT=ai,docker,java`).

Use `make list` to print the full catalog.

### Base profile components (`ENV=base`)

| Component | What it does |
|-----------|-------------|
| `backup` | Backs up dotfiles to `~/.ttdaiu_backup/`; generates `restore.sh` |
| `apt-upgrade` | Runs `apt-get dist-upgrade` and cleans the APT cache |
| `build-tools` | Build toolchain (cmake, build-essential, git, jq, shellcheck, …) |
| `network-base` | net-tools, nmap, openssh-server, rclone |
| `sysutils` | btop, htop, neovim, smartmontools, tree, … |
| `bash` | Injects dotfiles; organizes PATH in `.profile`; strips ad-hoc installer PATH lines |
| `sysctl` | Sets `vm.swappiness=10` via `/etc/sysctl.d/99-ttdaiu-swappiness.conf` |
| `sudoers` | Passwordless sudo for `MAIN_USER` via `/etc/sudoers.d/99-ttdaiu-nopasswd` |

### Component scripts (also used by `ENV=full`)

| Script | Method | What it installs |
|--------|--------|-----------------|
| `java` | APT | default-jdk, default-jre, gradle |
| `php` | APT | php-cli, php-gd, php-imagick, php-mysql, php-snmp |
| `postgres` | APT | postgresql-client |
| `sdl` | APT | libsdl2-*-dev, love |
| `qt` | APT | qtcreator, qt6-*-dev |
| `desktop-utils` | APT | meld, bleachbit, mc, evince, gnome-tweaks, wkhtmltopdf, qrencode, yadm |
| `flatpak` | APT | flatpak |
| `ocr` | APT | tesseract-ocr, tesseract-ocr-por |
| `remote` | APT | remmina, filezilla |
| `qemu` | APT | qemu-kvm, virt-manager, bridge-utils, cpu-checker |
| `libvirt` | APT | libvirt-clients, libvirt-daemon-system, libvirt-dev |
| `nginx` | APT | nginx, php-fpm |
| `arm` | APT | gcc-arm-none-eabi |
| `ansible` | APT | ansible |
| `z80` | APT | z80asm, z80dasm |
| `github` | APT | `gh` CLI with official GPG key and repository |
| `chromium` | Snap | Chromium browser |
| `code` | Snap | Visual Studio Code |
| `codium` | Snap | VSCodium |
| `golang` | Snap | Go + creates `~/go/{src,bin,pkg}` |
| `rust` | rustup | `curl … \| sh -s -- -y --no-modify-path`; PATH via bash `.profile` |
| `libreoffice` | Snap | LibreOffice |
| `docker` | APT | docker-ce + user group + service |
| `distrobox` | APT / upstream | Distrobox (APT on Noble/Resolute; upstream installer on Jammy) |
| `node` | APT | Node.js from NodeSource + Corepack + pnpm + yarn + npm prefix |
| `codex` | npm | `@openai/codex@latest` (installs to `~/.npm-global`) |
| `claude` | native | `curl -fsSL https://claude.ai/install.sh \| bash` |
| `gemini` | npm | `@google/gemini-cli@latest` (installs to `~/.npm-global`) |
| `opencode` | native | `curl … \| bash -s -- --no-modify-path`; PATH via bash `.profile` |

### Run individual scripts directly

Each script is self-contained and can be run independently (must be run as root):

```bash
sudo bash ubuntu/noble/scripts/install-docker.sh
sudo bash ubuntu/noble/scripts/install-node.sh
```

Environment variables respected by individual scripts:

```bash
DRY_RUN=true sudo bash ubuntu/noble/scripts/install-node.sh
NODE_VERSION=20.x sudo bash ubuntu/noble/scripts/install-node.sh
```

---

## Remote Execution via SSH

When `HOST` is set, `make` uses `rsync` to copy scripts to the remote machine and executes `setup.sh` over SSH.

```bash
# Noble remote (default)
make install HOST=root@192.168.1.50

# Resolute remote
make install UBUNTU_VERSION=resolute HOST=root@192.168.1.50

# Jammy remote
make install UBUNTU_VERSION=jammy HOST=root@192.168.1.50

# Specific scripts on remote
make install HOST=root@x042 SCRIPT=z80,docker
```

**Requirements:**
- SSH key-based authentication (passwordless)
- `rsync` installed locally
- Remote user must be `root` or have passwordless `sudo`

**How it works:**
1. `rsync` copies `ubuntu/noble/` (or `ubuntu/resolute/`, `ubuntu/jammy/`) to `/tmp/ttdaiu/` on the remote
2. SSH executes `bash /tmp/ttdaiu/setup.sh` with the given arguments

---

## How It Works

### Execution flow

```
make install SCRIPT=node
  └── make/run-shell.sh
       └── cd ubuntu/noble/ && sudo bash setup.sh --env=full --scripts=node
            └── ubuntu/noble/scripts/install-node.sh
```

### setup.sh

- Detects OS version (aborts if wrong version for the directory)
- Detects WSL and systemd availability
- Determines `MAIN_USER` and `MAIN_HOME` from `SUDO_USER`
- Runs `apt-get update` (skipped when `--scripts=` is set)
- Executes each requested script in order

### lib.sh functions

All scripts source `lib.sh` which provides:

| Function | Description |
|----------|-------------|
| `log_info / log_ok / log_warn / log_error / log_step` | Colored output |
| `run_cmd` | Executes or prints (if `DRY_RUN=true`) |
| `apt_install` | `apt-get install -y` with 3 retries |
| `snap_install` | `snap install` with 3 retries |
| `npm_global` | `npm install -g` as `MAIN_USER` |
| `enable_service` | `systemctl enable --now` (if systemd available) |
| `detect_wsl / detect_systemd / get_main_user / get_os_version` | Environment detection |

### Dry-run mode

Pass `--dry-run` (via `make dry-install`) to print what would be executed without making changes:

```bash
make dry-install SCRIPT=docker
```

Output example:
```
==> Instalando Docker (apt)
[DRY-RUN] apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
[DRY-RUN] Baixaria chave GPG e adicionaria repositório Docker
...
```

---

## Troubleshooting

### Wrong Ubuntu version

Each `setup.sh` validates the OS version before running. Match `UBUNTU_VERSION` to your OS:

```bash
make install UBUNTU_VERSION=resolute HOST=root@server   # 26.04
make install UBUNTU_VERSION=noble    HOST=root@server   # 24.04
make install UBUNTU_VERSION=jammy    HOST=root@server   # 22.04
```

### Snap not available (WSL)

Scripts that install via Snap check for `snapd` availability. If unavailable, they log a warning and skip — no failure.

### npm global packages not found after install

The `node` script sets the npm prefix to `~/.npm-global`; PATH comes from the bash `.profile` block. Reload the shell (or open a new login shell):

```bash
source ~/.profile
```

`npm -g list` reflects packages installed in the configured prefix (`~/.npm-global`). If it shows an empty list, ensure the prefix is set:

```bash
npm config get prefix   # should return /home/<user>/.npm-global
```

### Docker: permission denied after install

The `docker` script adds your user to the `docker` group, but the change takes effect only after re-login:

```bash
newgrp docker   # apply immediately in current session
```

### SSH remote: rsync or connection fails

Verify:
1. SSH key auth is set up: `ssh-copy-id root@server`
2. `rsync` is installed locally: `apt-get install rsync`
3. The remote host is reachable: `ssh root@server echo ok`
