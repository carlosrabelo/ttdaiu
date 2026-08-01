# TTDAIU - Things to Do After Installing Ubuntu

**TTDAIU** is a shell script automation tool that configures Ubuntu systems after installation. It supports Ubuntu 22.04 (Jammy), 24.04 (Noble), and 26.04 (Resolute) with two execution profiles — `base` for essential setup and `full` for a complete development workstation.

## What TTDAIU Installs

### Profiles (`ENV`)
| Profile | Includes |
|---------|----------|
| `base` | backup, apt-upgrade, build-tools, network-base, sysutils, bash, sysctl, sudoers |
| `desktop` | base + graphics/media/productivity, Chromium, LibreOffice, editors, LaTeX |
| `devops` | base + devtools, virt, network (Docker, Node, Go, Rust, QEMU, Ansible, …) |
| `embedded` | base + SDCC/Z80/m6502/ARM + Godot |
| `full` | base + every component |

### Named groups (`SCRIPT` / `COMPONENT`)
Compose installs without listing every component: `devtools`, `editors`, `ai`, `virt`, `embedded`, `desktop`, `network`, `gamedev`.  
`SCRIPT` (alias `COMPONENT`) replaces the profile list. See `make list` for the full catalog.

### Full Profile contents (`ENV=full`)
Includes all base components plus:

#### Development Tools
- **Docker**: Container platform via APT (with GPG key and official repository)
- **Go**: Go language via Snap
- **Node.js**: Runtime from NodeSource with Corepack, pnpm, and yarn
- **GitHub CLI**: `gh` via official APT repository

#### Editors & IDEs
- **Visual Studio Code**: Via Snap
- **VSCodium**: Open-source VS Code alternative via Snap
- **Neovim**: Terminal editor via APT

#### Productivity
- **Chromium**: Browser via Snap
- **LibreOffice**: Office suite via Snap
- **GIMP**, **Inkscape**, **Audacity**, **VLC**: Via APT

#### AI / CLI Tools
- **Claude Code**: Via native installer (`claude.ai/install.sh`)
- **OpenCode**: Via native installer (`opencode.ai/install`)
- **Codex**: `@openai/codex` via npm
- **Gemini**: `@google/gemini-cli` via npm

#### Specialized Tools
- **Nginx**, **QEMU**, **libvirt**, **Ansible**, **ARM** / **Z80** toolchains: Via APT

#### System Packages (100+)
Development libraries, LaTeX, networking tools, graphics, productivity apps, system monitors.

## Quick Start

```bash
# Install dependencies (curl, rsync)
make install-deps

# Run full setup on the local machine (Noble/24.04)
make install

# Intermediate profiles
make install ENV=desktop
make install ENV=devops
make install ENV=embedded

# Named groups and/or focused components (replaces ENV selection)
make install SCRIPT=ai,docker
make install COMPONENT=qt,ocr
make install SCRIPT=devtools,virt
make install SCRIPT=java

# Catalog of profiles, groups, and components
make list

# Base profile only
make install ENV=base

# Preview without making changes
make dry-install
make dry-install SCRIPT=node

# Run on a remote machine via SSH
make install HOST=root@server
make install HOST=root@server UBUNTU_VERSION=resolute SCRIPT=z80
make install HOST=root@server UBUNTU_VERSION=jammy SCRIPT=z80
```

## Project Structure

```
ttdaiu/
├── ubuntu/noble/                  # Ubuntu 24.04 (Noble)
│   ├── setup.sh                   # Orchestrator
│   ├── files/bash/                # Dotfiles (.bashrc, .bash_aliases, .bash_extras, .profile)
│   ├── files/sysctl/              # Kernel tunables (vm.swappiness)
│   └── scripts/
│       ├── lib.sh                 # Shared functions (log, retry, apt_install, snap_install…)
│       ├── profiles.sh            # ENV profiles + named SCRIPT groups
│       ├── install-backup.sh
│       ├── install-bash.sh
│       ├── install-build-tools.sh
│       ├── install-sysctl.sh
│       ├── install-docker.sh
│       ├── install-node.sh
│       └── …                      # One script per component
├── ubuntu/jammy/                  # Ubuntu 22.04 (Jammy) — same structure
├── ubuntu/resolute/               # Ubuntu 26.04 (Resolute) — same structure
├── make/
│   ├── run-shell.sh               # Local and remote execution logic
│   ├── install-deps.sh            # Installs curl and rsync
│   └── cleanup.sh
├── docs/                          # GUIDE.md, GUIDE-PT.md
├── Makefile
└── LICENSE
```

## Documentation

- **English guide**: [docs/GUIDE.md](docs/GUIDE.md)
- **Guia em português**: [docs/GUIDE-PT.md](docs/GUIDE-PT.md)

## License

MIT — see [LICENSE](LICENSE).
