# TTDAIU - Things to Do After Installing Ubuntu

**TTDAIU** is a shell script automation tool that configures Ubuntu systems after installation. It supports Ubuntu 22.04 (Jammy) and 24.04 (Noble) with two execution profiles — `base` for essential setup and `full` for a complete development workstation.

## What TTDAIU Installs

### Base Profile (`ENV=base`)
- **System packages**: Build tools, network utilities, development libraries
- **Shell configuration**: Enhanced bash with aliases and profile settings
- **Backup system**: Dotfile backup and restore script

### Full Profile (`ENV=full`)
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
- **Nginx**, **QEMU**, **libvirt**, **Z80** toolchain: Via APT

#### System Packages (100+)
Development libraries, LaTeX, networking tools, graphics, productivity apps, system monitors.

## Quick Start

```bash
# Install dependencies (curl, rsync)
make install-deps

# Run full setup on the local machine (Noble/24.04)
make install

# Run only specific scripts
make install SCRIPT=node
make install SCRIPT=docker,golang,github

# Base profile only (packages + bash + backup)
make install ENV=base

# Preview without making changes
make dry-install
make dry-install SCRIPT=node

# Run on a remote machine via SSH
make install HOST=root@server
make install HOST=root@server UBUNTU_VERSION=jammy SCRIPT=z80
```

## Project Structure

```
ttdaiu/
├── ubuntu/noble/                  # Ubuntu 24.04 (Noble)
│   ├── setup.sh            # Orchestrator
│   ├── files/bash/         # Dotfiles (.bashrc, .bash_aliases, .bash_extras, .profile)
│   └── scripts/
│       ├── lib.sh          # Shared functions (log, retry, apt_install, snap_install…)
│       ├── install-backup.sh
│       ├── install-bash.sh
│       ├── install-packages.sh
│       ├── install-docker.sh
│       ├── install-node.sh
│       └── …               # One script per component (19 total)
├── ubuntu/jammy/                  # Ubuntu 22.04 (Jammy) — same structure
├── make/
│   ├── run-shell.sh        # Local and remote execution logic
│   ├── install-deps.sh     # Installs curl and rsync
│   └── cleanup.sh
├── docs/                   # GUIDE.md, GUIDE-PT.md
├── Makefile
└── LICENSE
```

## Documentation

- **English guide**: [docs/GUIDE.md](docs/GUIDE.md)
- **Guia em português**: [docs/GUIDE-PT.md](docs/GUIDE-PT.md)

## License

MIT — see [LICENSE](LICENSE).
