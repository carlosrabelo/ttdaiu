# TTDAIU - Detailed Manual

## Table of Contents

1. [Make Targets](#make-targets)
2. [Environment Variables](#environment-variables)
3. [Available Tags](#available-tags)
4. [Configuration Options](#configuration-options)
5. [Advanced Usage](#advanced-usage)

## Make Targets

### Primary Targets

#### `make run`
**Purpose**: Execute the complete Ansible playbook
**Default**: Ubuntu 24.04 (Noble), base environment

```bash
make run                                    # Default: noble, base
make run UBUNTU_VERSION=jammy              # Ubuntu 22.04
make run ENV=full                          # Full environment
make run TAGS=packages                     # Specific tags only
```

#### `make dry-run`
**Purpose**: Preview changes without applying them
**Usage**: Same options as `make run` but with `--check --diff` flags

```bash
make dry-run                               # Preview all changes
make dry-run TAGS=docker                   # Preview Docker installation
```

#### `make install-deps`
**Purpose**: Install required system dependencies
**Installs**: ansible, git, sshpass, python3-pip

```bash
make install-deps
```

### Maintenance Targets

#### `make check` / `make syntax`
**Purpose**: Validate Ansible playbook syntax
**Checks**: YAML syntax, playbook structure

```bash
make check
```

#### `make lint`
**Purpose**: Run ansible-lint for code quality
**Requires**: ansible-lint package

```bash
make lint
```

#### `make clean`
**Purpose**: Clean temporary files and artifacts
**Removes**: Ansible temp files, logs, cache

```bash
make clean
```

#### `make info`
**Purpose**: Display project configuration information
**Shows**: Current settings, paths, versions

```bash
make info
```

#### `make secure-creds`
**Purpose**: Setup secure credential management
**Creates**: Encrypted vault files for production use

```bash
make secure-creds
```

## Environment Variables

### Core Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `UBUNTU_VERSION` | `noble` | Ubuntu version: `noble` (24.04) or `jammy` (22.04) |
| `ENV` | `base` | Environment: `base` (minimal) or `full` (complete) |
| `TAGS` | *(auto)* | Comma-separated list of tags to execute; defaults to `base` (ENV=base) or `base,full` (ENV=full) |
| `ANSIBLE_DIR` | `./noble` | Path to Ansible configuration directory |
| `PLAYBOOK` | `site.yml` | Main playbook filename |
| `INVENTORY` | `inventory/base.ini` | Base environment inventory file |
| `FULL_INVENTORY` | `inventory/full.ini` | Full environment inventory file |

### Usage Examples

```bash
# Override Ubuntu version
UBUNTU_VERSION=jammy make run

# Use full environment
ENV=full make run

# Run specific tags only
TAGS=packages,docker make run

# Combine multiple variables
UBUNTU_VERSION=jammy ENV=full TAGS=docker,golang make run
```

## Available Tags

### System Tags

| Tag | Description | Components |
|-----|-------------|------------|
| `packages` | Essential system packages | System updates, utilities, networking tools |
| `bash` | Shell configuration | Enhanced bashrc, aliases, profile settings |
| `backup` | Backup system setup | Backup scripts, restore functionality |

### Development Tags

| Tag | Description | Components |
|-----|-------------|------------|
| `docker` | Docker container platform | Docker CE/EE, docker-compose |
| `golang` | Go development environment | Go language tools, GOPATH setup |
| `node` | Node.js development | Node.js runtime, npm, npx |
| `github` | GitHub CLI tools | gh CLI, repository management |

### Application Tags

| Tag | Description | Components |
|-----|-------------|------------|
| `code` | Visual Studio Code | VS Code editor, extensions |
| `codium` | VSCodium (open-source VS Code) | VSCodium editor |
| `chromium` | Web browser | Chromium browser via Snap |
| `libreoffice` | Office suite | LibreOffice productivity tools |

### AI/CLI Tags

| Tag | Description | Components |
|-----|-------------|------------|
| `claude` | Claude AI CLI | Anthropic Claude command-line tool |
| `codex` | OpenAI Codex CLI | OpenAI coding assistant |
| `gemini` | Google Gemini CLI | Google AI assistant |
| `opencode` | OpenCode AI CLI | AI-powered development assistant |

### Specialized Tags

| Tag | Description | Components |
|-----|-------------|------------|
| `nginx` | Web server | Nginx HTTP server |
| `libvirt` | Virtualization | KVM/QEMU virtualization tools |
| `z80` | Z80 development | Z80 assembly development tools |

### Meta Tags

| Tag | Description | Components |
|-----|-------------|------------|
| `base` | Core roles for minimal provisioning | `packages`, `bash`, `backup` |
| `full` | Extended roles for complete workstations | All `base` roles plus development, productivity, and AI tooling |

## Configuration Options

### Role Profiles

Roles are grouped with meta tags so you can quickly target the right set of tasks:

- `base`: core roles such as `packages`, `bash`, and `backup`
- `full`: extended roles covering development, productivity, and AI tooling

The `ENV` variable controls the default tag profile:

- `ENV=base` → runs Ansible with `--tags base`
- `ENV=full` → runs Ansible with `--tags base,full`

Override the selection at any time with the `TAGS` variable:

```bash
# Run only the core roles
make run TAGS=base

# Combine specific roles regardless of ENV
make run TAGS=packages,github

# Execute every role
make run TAGS=all
```

### Docker Configuration

```yaml
docker_install_method: "apt"    # Options: "apt", "snap"
docker_users: ["ubuntu"]        # Users to add to docker group
```

### Package Categories

Configure package groups in `roles/packages/vars/main.yml`. Override them per environment (set to `[]` to skip) in inventory or host vars:

```yaml
development_packages:
  - build-essential
  - python3-dev

media_packages:
  - vlc
  - audacity

latex_packages: []
```

## Advanced Usage

### Custom Inventory Files

Create custom inventory files for specific environments:

```bash
# Create custom inventory
cp noble/inventory/base.ini noble/inventory/custom.ini

# Use custom inventory
INVENTORY=inventory/custom.ini make run
```

### Variable Override

Override variables temporarily:

```bash
cd noble
ansible-playbook site.yml -i inventory/base.ini \
  -e '{"golang_install_method": "apt"}' \
  --tags golang
```

### Environment-Specific Configuration

Use `.env` file for persistent configuration:

```bash
# Create .env file
cat > .env << EOF
UBUNTU_VERSION=jammy
ENV=full
TAGS=packages,docker,golang
EOF

# Make will automatically load .env
make run
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Method 1: Direct Ansible execution
cd noble
ansible-playbook -v site.yml -i inventory/base.ini

# Method 2: Modify run-ansible.sh temporarily
# Add -v flag to ansible-playbook command
```

### Selective Role Execution

Execute specific roles without tags:

```bash
cd noble
ansible-playbook site.yml -i inventory/base.ini \
  --start-at-task="Install Docker packages"
```

### Conditional Execution

Use `when` conditions in playbooks for advanced logic:

```yaml
- name: Install development tools
  ansible.builtin.apt:
    name: "{{ development_packages }}"
    state: present
  when: development_packages | length > 0
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Ensure sudo access
   sudo -v
   make run
   ```

2. **Ansible Not Found**
   ```bash
   make install-deps
   ```

3. **Snap Issues**
   ```bash
   sudo systemctl status snapd
   sudo systemctl restart snapd
   ```

4. **Network Issues**
   ```bash
   # Check connectivity
   ping -c 4 archive.ubuntu.com
   ping -c 4 api.snapcraft.io
   ```

### Log Files

Ansible logs are stored in:
- `~/.ansible/log/` - Default Ansible logs
- `/tmp/ansible-*` - Temporary execution logs

### Recovery

Rollback specific changes:

```bash
# Remove specific packages
sudo apt remove package-name

# Reset configuration files
git checkout noble/roles/role_name/files/
```

## Best Practices

1. **Always use dry-run first**: `make dry-run`
2. **Check syntax**: `make check` before execution
3. **Use tags for selective installation**: Avoid unnecessary changes
4. **Backup important data**: Before major changes
5. **Test in virtual environment**: Before production use
6. **Keep documentation updated**: Document custom changes

## Performance Tips

1. **Sequential installs**: Package roles run sequentially to avoid async issues
2. **Local connections**: Use `connection: local` for single-machine setup
3. **Package caching**: APT cache speeds up repeated installations
4. **Snap preloading**: Snap packages are cached locally

## Security Considerations

1. **Review package lists**: Ensure only needed packages are installed
2. **Use secure credentials**: `make secure-creds` for production
3. **Audit roles**: Review custom roles for security issues
4. **Network isolation**: Run in isolated network when possible
5. **Regular updates**: Keep Ansible and system packages updated
