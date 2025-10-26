# TTDAIU - Things to Do After Installing Ubuntu

**TTDAIU** is a comprehensive Ansible-based automation tool that configures Ubuntu systems after installation. It provides two execution profiles - `base` for essential system setup and `full` for complete development workstation provisioning.

## What TTDAIU Installs

### Base Profile (`ENV=base`)
- **System Essentials**: System updates, build tools, networking utilities
- **Shell Configuration**: Enhanced bash with aliases, profile settings
- **Backup System**: Automated backup scripts and restore functionality

### Full Profile (`ENV=full`)
Includes all base components plus:

#### Development Tools
- **Docker**: Container platform (APT or Snap installation)
- **Go**: Go language development environment with workspace setup
- **Node.js**: Runtime v22.x with npm, pnpm, and yarn support
- **GitHub CLI**: Command-line GitHub interface

#### Editors & IDEs
- **Visual Studio Code**: Via Snap
- **VSCodium**: Open-source VS Code alternative
- **Neovim**: Enhanced terminal editor

#### Productivity Applications
- **Chromium**: Web browser via Snap
- **LibreOffice**: Complete office suite
- **GIMP**: Image editor
- **Inkscape**: Vector graphics editor
- **Audacity**: Audio editor
- **VLC**: Media player

#### AI/CLI Tools
- **Claude Code**: Anthropic's AI coding assistant
- **OpenCode**: AI-powered development assistant
- **Codex**: OpenAI coding assistant
- **Gemini**: Google AI assistant

#### Specialized Tools
- **Nginx**: Web server
- **Libvirt**: KVM/QEMU virtualization
- **Z80 Tools**: Z80 assembly development environment

#### Additional Packages
- **Development**: Java, Python, PHP, PostgreSQL client, Hugo, Jekyll
- **Network**: VPN tools, SSH utilities, network analysis
- **Graphics**: Font support, image manipulation tools
- **Productivity**: File comparison, remote desktop, document viewers
- **LaTeX**: Complete TeX Live installation with TeXstudio
- **System**: Monitoring tools, process management, gaming engine

## Quick Start

### Prerequisites
- Ubuntu 22.04 (Jammy) or 24.04 (Noble)
- Sudo access without password interaction
- Internet connectivity for package downloads

### Basic Usage

```bash
# Install Ansible and dependencies
make install-deps

# Run base setup (minimal essential packages)
make run

# Run full setup (complete workstation)
make run ENV=full

# Run for Ubuntu 22.04
make run UBUNTU_VERSION=jammy

# Preview changes without applying
make dry-run

# Run specific components only
make run TAGS=docker,golang
```

### Environment Profiles

```bash
# Base profile - essential system tools
make run ENV=base                    # Default: packages, bash, backup

# Full profile - complete development environment  
make run ENV=full                    # All base roles + development, productivity, AI tools
```

### Tag-Based Execution

```bash
# Development tools only
make run TAGS=docker,golang,node,github

# Productivity applications
make run TAGS=chromium,libreoffice,code

# AI/CLI tools
make run TAGS=claude,opencode,codex,gemini

# System utilities
make run TAGS=packages,bash,backup
```

## Documentation

- **Complete Guide**: [docs/GUIDE.md](docs/GUIDE.md) - Detailed usage with all targets, variables, and configuration options
- **Português**: [docs/GUIDE-PT.md](docs/GUIDE-PT.md) - Guia completo em português

## Project Structure

```
ttdaiu/
├── noble/          # Ubuntu 24.04 (Noble) playbooks
├── jammy/          # Ubuntu 22.04 (Jammy) playbooks  
├── scripts/        # Helper scripts
├── docs/          # Documentation
└── Makefile       # Command interface
```

Each version directory contains identical roles organized by function:
- `roles/packages/` - System package installation
- `roles/docker/`, `roles/golang/`, `roles/node/` - Development tools
- `roles/code/`, `roles/codium/`, `roles/chromium/` - Applications
- `roles/claude/`, `roles/opencode/` - AI assistants

## Notice

This project is intended for personal use and development workstation setup. Feel free to fork and customize the package lists and configurations for your specific needs.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
