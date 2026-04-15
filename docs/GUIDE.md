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
| `make install-deps` | Install `curl` and `rsync` |
| `make info` | Show current configuration |
| `make clean` | Clean temporary files |
| `make help` | Show usage summary |

---

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `UBUNTU_VERSION` | `noble` | `noble` (24.04) or `jammy` (22.04) |
| `ENV` | `full` | `base` (minimal) or `full` (complete) |
| `SCRIPT` | *(all)* | Comma-separated list of scripts to run |
| `HOST` | *(local)* | Remote target, e.g. `root@192.168.1.10` |

### Examples

```bash
make install                                         # Noble, full, local
make install ENV=base                                # Base profile only
make install SCRIPT=node                             # Only node
make install SCRIPT=docker,golang,node               # Multiple scripts
make install UBUNTU_VERSION=jammy HOST=root@server   # Jammy on remote host
make dry-install SCRIPT=node                         # Preview node only
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

### Base profile (`ENV=base`)

| Script | What it does |
|--------|-------------|
| `backup` | Backs up dotfiles to `~/.ttdaiu_backup/`; generates `restore.sh` |
| `packages` | Installs 100+ APT packages (dev libs, LaTeX, media, network, productivity) |
| `bash` | Copies `.bashrc`, `.bash_aliases`, `.bash_extras`, `.profile` |

### Full profile — additional scripts (`ENV=full`)

| Script | Method | What it installs |
|--------|--------|-----------------|
| `qemu` | APT | qemu-kvm, virt-manager, bridge-utils |
| `libvirt` | APT | libvirt-clients, libvirt-daemon-system, libvirt-dev |
| `nginx` | APT | nginx, php-fpm |
| `z80` | APT | sdcc, z80asm, z80dasm |
| `github` | APT | `gh` CLI with official GPG key and repository |
| `chromium` | Snap | Chromium browser |
| `code` | Snap | Visual Studio Code |
| `codium` | Snap | VSCodium |
| `golang` | Snap | Go + creates `~/go/{src,bin,pkg}` |
| `libreoffice` | Snap | LibreOffice |
| `docker` | APT | docker-ce + user group + service |
| `node` | APT | Node.js from NodeSource + Corepack + pnpm + yarn + npm prefix |
| `codex` | npm | `@openai/codex@latest` (installs to `~/.npm-global`) |
| `claude` | native | `curl -fsSL https://claude.ai/install.sh \| bash` |
| `gemini` | npm | `@google/gemini-cli@latest` (installs to `~/.npm-global`) |
| `opencode` | native | `curl -fsSL https://opencode.ai/install \| bash` |

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
1. `rsync` copies `ubuntu/noble/` (or `ubuntu/jammy/`) to `/tmp/ttdaiu/` on the remote
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

Each `setup.sh` validates the OS version before running. Use `UBUNTU_VERSION=jammy` for 22.04 machines:

```bash
make install UBUNTU_VERSION=jammy HOST=root@server
```

### Snap not available (WSL)

Scripts that install via Snap check for `snapd` availability. If unavailable, they log a warning and skip — no failure.

### npm global packages not found after install

The `node` script sets the npm prefix to `~/.npm-global` and adds it to `.bashrc`. You need to reload the shell:

```bash
source ~/.bashrc
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
