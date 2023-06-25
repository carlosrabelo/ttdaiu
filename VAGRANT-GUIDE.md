# Vagrant Development Guide

This guide explains how to use Vagrant for development and testing of TTDAIU Ansible playbooks.

## Overview

The project offers two main options for testing:

1. **Vagrant (Development)** - Local VMs with VirtualBox for rapid development
2. **Proxmox (Production)** - VMs on Proxmox VE for tests closer to production

### When to use each one:
- **Vagrant**: Rapid development, individual role testing, local debugging
- **Proxmox**: Integration tests, validation in production-like environment

For Proxmox usage, see [PROXMOX-GUIDE.md](PROXMOX-GUIDE.md).

## Vagrant - Local Configuration

The project offers simple ways to use Vagrant:

1. **Separate environments** - One Vagrantfile per Ubuntu version
2. **Sequential testing** - Script to test both versions in sequence

## File Structure

```
ttdaiu/
├── noble/
│   └── Vagrantfile           # Ubuntu 24.04 specific
├── jammy/
│   └── Vagrantfile           # Ubuntu 22.04 specific
└── scripts/
    └── vagrant-test.sh       # Automated test script
```

## Basic Commands

### Individual Environment

```bash
# Ubuntu 24.04 (Noble)
make vagrant-up UBUNTU_VERSION=noble
make vagrant-ssh UBUNTU_VERSION=noble
make vagrant-destroy UBUNTU_VERSION=noble

# Ubuntu 22.04 (Jammy)
make vagrant-up UBUNTU_VERSION=jammy
make vagrant-ssh UBUNTU_VERSION=jammy
make vagrant-destroy UBUNTU_VERSION=jammy

# Using specific commands
make vagrant-noble-up
make vagrant-jammy-up
```

### Environment Cleanup

```bash
# Destroy all environments
make vagrant-destroy-all

# Clean completely
make vagrant-clean
```

## Tests with Tags

### Using Environment Variables

```bash
# Test only APT packages
ANSIBLE_TAGS=apt make vagrant-up UBUNTU_VERSION=noble

# Test only snap packages
ANSIBLE_TAGS=snap make vagrant-provision UBUNTU_VERSION=jammy

# Multiple tags
ANSIBLE_TAGS=apt,bash make vagrant-provision UBUNTU_VERSION=noble
```

### Ansible Verbosity

```bash
# Detailed output
ANSIBLE_VERBOSE=vv make vagrant-provision UBUNTU_VERSION=jammy

# Minimal output
ANSIBLE_VERBOSE='' make vagrant-provision UBUNTU_VERSION=noble
```

## Development Workflow

### 1. Role Development

```bash
# Start a box for development
make vagrant-up UBUNTU_VERSION=noble

# SSH into the box
make vagrant-ssh UBUNTU_VERSION=noble

# Manual role testing
ansible-playbook site.yml --tags=my-role --check
```

### 2. Version-Specific Testing

```bash
# Test on Noble
make vagrant-up UBUNTU_VERSION=noble
make vagrant-ssh UBUNTU_VERSION=noble

# Test on Jammy
make vagrant-up UBUNTU_VERSION=jammy
make vagrant-ssh UBUNTU_VERSION=jammy
```

### 3. Complete Testing

```bash
# Automated script for one version
./scripts/vagrant-test.sh noble all false
./scripts/vagrant-test.sh jammy all false
```

### 4. Testing with Provisioners

```bash
# Re-run provisioning
make vagrant-provision UBUNTU_VERSION=noble

# Run quick setup
cd noble && vagrant provision --provision-with quick-setup

# Run only Ansible
cd jammy && vagrant provision --provision-with ansible
```

## Advanced Configurations

### Modify VM Resources

Edit the Vagrantfiles to adjust resources:

```ruby
# More memory for development
lv.memory = 8192
lv.cpus = 4

# Minimal resources for CI
lv.memory = 2048
lv.cpus = 1
```

### Specific Provider

```bash
# Force VirtualBox
VAGRANT_DEFAULT_PROVIDER=virtualbox make vagrant-up

# Force Libvirt
VAGRANT_DEFAULT_PROVIDER=libvirt make vagrant-up
```

### Custom Network

For advanced development, you can configure custom networking:

```ruby
# Fixed IP for testing
config.vm.network "private_network", ip: "192.168.56.10"

# Port forwarding
config.vm.network "forwarded_port", guest: 80, host: 8080
```

## Debug and Troubleshooting

### Check Status

```bash
# Status of all boxes
vagrant global-status

# Status by version
make vagrant-status UBUNTU_VERSION=noble
make vagrant-status UBUNTU_VERSION=jammy
```

### Logs and Debug

```bash
# Detailed Vagrant logs
VAGRANT_LOG=info make vagrant-up

# Ansible debug
ANSIBLE_VERBOSE=vvv make vagrant-provision

# Provisioning logs
cd noble && vagrant up --debug
```

### Common Issues

#### Box not found
```bash
# Update boxes
vagrant box update

# List available boxes
vagrant box list
```

#### SSH failure
```bash
# Reload SSH configuration
vagrant reload

# Regenerate SSH keys
vagrant ssh-config
```

#### Network issues
```bash
# Recreate network interface
vagrant halt && vagrant up

# Check network configuration
vagrant ssh -c "ip addr show"
```

## Performance Optimizations

### Package Cache

Configure cache to speed up repeated installations:

```bash
# Install vagrant-cachier plugin
vagrant plugin install vagrant-cachier
```

### Snapshots

Use snapshots for quick restore points:

```bash
# Create snapshot
vagrant snapshot save snapshot-name

# Restore snapshot
vagrant snapshot restore snapshot-name

# List snapshots
vagrant snapshot list
```

### Synced Folders

For active development, enable synced folders:

```ruby
# In Vagrantfile
config.vm.synced_folder ".", "/vagrant", type: "rsync"
```

## CI/CD Workflow

### Automated Testing

```bash
# Complete test script
./scripts/vagrant-test.sh both all true

# Test only one version
./scripts/vagrant-test.sh noble apt false

# Automatic cleanup
make vagrant-clean
```

### Pipeline Example

```yaml
# .github/workflows/vagrant-test.yml
test-ubuntu:
  strategy:
    matrix:
      ubuntu: [noble, jammy]
  steps:
    - name: Test Ubuntu ${{ matrix.ubuntu }}
      run: |
        make vagrant-up UBUNTU_VERSION=${{ matrix.ubuntu }}
        make vagrant-provision UBUNTU_VERSION=${{ matrix.ubuntu }}
        make vagrant-destroy UBUNTU_VERSION=${{ matrix.ubuntu }}
```

## Cleanup Commands

### Quick Cleanup

```bash
# Destroy all VMs
make vagrant-destroy-all

# Complete cleanup
make vagrant-clean
```

### Manual Cleanup

```bash
# Remove orphaned boxes
vagrant box prune

# Clean global cache
vagrant global-status --prune

# Remove all VirtualBox VMs
VBoxManage list vms | grep ttdaiu | awk '{print $1}' | xargs -I {} VBoxManage unregistervm {} --delete
```

## Productivity Tips

1. **Use aliases** for frequent commands
2. **Configure SSH keys** for quick access
3. **Use snapshots** before major changes
4. **Monitor resources** of host system
5. **Keep boxes updated** regularly

## IDE Integration

### VS Code

Install the "Remote - SSH" extension and connect directly to VMs:

```bash
# Get SSH configuration
vagrant ssh-config >> ~/.ssh/config
```

### Ansible

Configure ansible.cfg for development:

```ini
[defaults]
host_key_checking = False
pipelining = True
```

This guide should cover most development scenarios with Vagrant in the TTDAIU project.