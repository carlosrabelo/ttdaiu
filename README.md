# TTDAIU - Things to do after installing Ubuntu

Automated post-installation setup for Ubuntu using Ansible. This project helps you quickly configure a fresh Ubuntu installation with essential software, development tools, and personal preferences.

## Features

- **Automated software installation** via APT and Snap packages
- **Development environment setup** (Go, Node.js, Docker, VS Code)
- **Productivity tools** (LibreOffice, GIMP, VLC, etc.)
- **System optimization** and configuration
- **Multiple testing environments** (Vagrant and Proxmox VE)
- **Flexible execution** with tag-based filtering
- **Optional AI coding CLIs** (Codex, Claude, Gemini) controlled by feature flags

## Supported Versions

- **Ubuntu 24.04 LTS (Noble Numbat)** - Primary support
- **Ubuntu 22.04 LTS (Jammy Jellyfish)** - Full compatibility

For detailed compatibility information, see [COMPATIBILITY.md](docs/COMPATIBILITY.md)

## Quick Start

### Prerequisites

Install required dependencies:

```bash
sudo apt update && sudo apt install -y ansible git sshpass
```

Or use the convenient installer:

```bash
make install-deps
```

### Basic Usage

Run the complete setup:

```bash
make run                           # Ubuntu 24.04 (Noble) - Default
make run UBUNTU_VERSION=jammy     # Ubuntu 22.04 (Jammy)
```

Or run specific tests:

```bash
make test                          # Run in testing environment
make dry-run                       # Preview changes
```

Run specific components only:

```bash
make run TAGS=packages                     # Install APT packages only
make run TAGS=snap                          # Install Snap packages only
make run TAGS=golang UBUNTU_VERSION=jammy  # Install Go on Ubuntu 22.04
make run TAGS=docker UBUNTU_VERSION=noble  # Install Docker on Ubuntu 24.04
```

Preview changes without applying them:

```bash
make dry-run                       # Default version
make dry-run UBUNTU_VERSION=jammy  # Jammy version
```

## Available Software

### APT Packages (Basic System)
- System updates and essential packages
- Network management tools (OpenConnect, L2TP)
- System utilities (meld, gnome-tweaks, bleachbit)

### APT Packages (Applications)
- **Media**: VLC, Audacity, LMMS
- **Graphics**: GIMP, Inkscape, MyPaint
- **Productivity**: LibreOffice suite
- **LaTeX**: TeXLive with Portuguese language support
- **Development**: Basic build tools
- **Networking**: FileZilla, Remmina

### Snap Packages
- **Development**: Go, Node.js
- **Editors**: Visual Studio Code, VSCodium
- **Browsers**: Chromium
- **Office**: LibreOffice (if not installed via APT)
- **Container runtime (optional)**: Docker, when `docker_install_method=snap`

### Configuration Files
- Enhanced bash configuration with aliases and extras
- Custom profile and bashrc settings

## Advanced Usage

### Testing Environments

The project supports two testing environments for comprehensive playbook validation:

#### Vagrant (Development Testing)

Local virtual machine testing using VirtualBox:

```bash
# Default version (Noble/24.04)
make vagrant-up                          # Start VM
make vagrant-ssh                         # SSH into VM
make vagrant-provision                   # Re-run provisioning

# Specific version using UBUNTU_VERSION
make vagrant-up UBUNTU_VERSION=jammy     # Start Jammy VM
make vagrant-ssh UBUNTU_VERSION=jammy    # SSH into Jammy VM
make vagrant-provision UBUNTU_VERSION=noble  # Re-run Noble provisioning
```

#### Proxmox (Production-like Testing)

Enterprise virtualization testing using Proxmox VE:

```bash
# Default version (Noble/24.04)
make proxmox-create VM_ID=9000            # Create VM from template
make proxmox-status VM_ID=9000            # Check VM status
make proxmox-provision VM_ID=9000         # Run Ansible on VM
make proxmox-ssh VM_ID=9000               # SSH into VM
make proxmox-destroy VM_ID=9000           # Destroy VM

# Specific version using UBUNTU_VERSION
make proxmox-create UBUNTU_VERSION=jammy VM_ID=9001  # Create Jammy VM
make proxmox-provision UBUNTU_VERSION=jammy VM_ID=9001

# Batch management
make proxmox-list                         # List all test VMs
make proxmox-clean                        # Destroy all test VMs
```

#### Advanced Testing Usage
```bash
# Test specific tags
ANSIBLE_TAGS=packages make vagrant-provision UBUNTU_VERSION=jammy
make proxmox-provision VM_ID=9000 TAGS=docker

# Verbose output
ANSIBLE_VERBOSE=vv make vagrant-up UBUNTU_VERSION=noble

# Automated testing script
./scripts/vagrant-test.sh both all false
```

For detailed testing workflows, see:
- [VAGRANT-GUIDE.md](docs/VAGRANT-GUIDE.md) - Complete Vagrant usage guide
- [PROXMOX-GUIDE.md](docs/PROXMOX-GUIDE.md) - Complete Proxmox usage guide

### Project Maintenance

Check syntax and validate configurations:

```bash
make check               # Syntax check
make lint               # Ansible linting (requires ansible-lint)
make clean              # Clean temporary files
make info               # Show project information
```

## Project Structure

```
ttdaiu/
├── Makefile                    # Main automation commands
├── README.md                   # This file
├── docs/
│   ├── COMPATIBILITY.md       # Ubuntu version compatibility guide
│   ├── PROXMOX-GUIDE.md       # Proxmox usage guide
│   └── VAGRANT-GUIDE.md       # Vagrant usage guide
├── scripts/
│   └── vagrant-test.sh        # Automated testing script
├── noble/                     # Ubuntu 24.04 (Noble) configuration
│   ├── site.yml              # Main playbook for Noble
│   ├── ansible.cfg           # Ansible configuration
│   ├── Vagrantfile           # Vagrant configuration for Noble
│   ├── group_vars/           # Global variables
│   ├── inventory/            # Inventory files with multi-environment support
│   │   ├── production.ini    # Production inventory
│   │   ├── testing.ini       # Testing inventory
│   │   └── group_vars/       # Environment-specific variables
│   └── roles/                # Ansible roles
│       ├── packages/         # Consolidated package management
│       ├── backup/          # Backup and restore functionality
│       ├── bash/            # Shell configuration
│       ├── github/          # GitHub CLI repository setup
│       ├── docker/          # Docker installation with validation
│       ├── golang/          # Go development environment
│       └── ...              # Other specialized roles
└── jammy/                    # Ubuntu 22.04 (Jammy) configuration
    ├── site.yml             # Main playbook for Jammy
    ├── ansible.cfg          # Ansible configuration
    ├── Vagrantfile          # Vagrant configuration for Jammy
    ├── group_vars/          # Global variables
    ├── inventory/           # Inventory files with multi-environment support
    └── roles/               # Ansible roles (copied from noble)
```

## Customization

### Adding Software

1. **APT packages**: Edit `noble/roles/packages/defaults/main.yml` (and `jammy/roles/packages/defaults/main.yml` if needed) and add to appropriate category
2. **Snap packages**: Create or edit relevant role in `noble/roles/`
3. **Custom configurations**: Add files to role `files/` directories

### Selective Installation

Use tags to install only what you need:

- `packages` - All APT-based installations
- `snap` - All Snap-based installations (Chromium, VS Code, VSCodium, Go, Node.js, LibreOffice)
- Individual role names (e.g., `golang`, `docker`, `nginx`)

### Feature Flags

Toggle groups of tasks globally by adjusting the `features` dictionary in the relevant inventory or `group_vars/all.yml` file. Available flags:

- `install_development_tools`
- `install_media_tools`
- `install_productivity_tools`
- `install_latex_tools`
- `configure_bash`
- `setup_networking`
- `enable_backups`
- `install_ai_cli_tools`

Override temporarily by running the playbook directly:

```bash
cd noble
ansible-playbook site.yml -i inventory/production.ini \
  -e '{"features": {"install_ai_cli_tools": false}}' \
  --ask-become-pass
```

> Substitua `noble` por `jammy` para trabalhar com o playbook de Ubuntu 22.04.

### Docker Installation Method

Docker defaults to the official APT repository. Switch to the Snap build by setting:

```bash
cd noble
ansible-playbook site.yml -i inventory/production.ini \
  -e '{"docker_install_method": "snap"}' \
  --tags docker --ask-become-pass
```

> Substitua `noble` por `jammy` para trabalhar com o playbook de Ubuntu 22.04.

Set this permanently by editing `group_vars/all.yml` or the inventory group vars for your environment.

### Environment Variables

Common customizations can be made by editing variables in:
- `noble/site.yml` (global variables)
- Individual role files

## Troubleshooting

### Common Issues

**Permission denied errors**: Ensure you run with `--ask-become-pass` or use `sudo`

**Snap installation fails**: Check if snapd service is running:
```bash
sudo systemctl status snapd
```

**Ansible not found**: Install using:
```bash
sudo apt install ansible
```

**Virtual environment issues**: Ensure virtualization is enabled in BIOS/UEFI

### Getting Help

1. Check the syntax: `make check`
2. Run in dry-run mode: `make dry-run`
3. View detailed output by adding `-v` flag manually to ansible commands
4. Check individual role documentation in `noble/roles/*/README.md` (if available)

## Contributing

Feel free to:
- Add new software packages to existing roles
- Create new roles for additional software categories
- Improve documentation and error handling
- Submit issues and feature requests

## License

This project is provided as-is for educational and productivity purposes. Individual software packages installed have their own licenses.
