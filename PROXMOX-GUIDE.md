# Proxmox Setup Guide for TTDAIU

This guide explains how to configure and use Proxmox for testing TTDAIU playbooks using direct API calls.

## Prerequisites

### 1. Proxmox Templates
You need to have Ubuntu templates already created in Proxmox:

- **Template ID 8000**: Ubuntu 24.04 (Noble)
- **Template ID 8001**: Ubuntu 22.04 (Jammy)

### 2. API Token
Create an API token in Proxmox with the following permissions:

```
VM.Allocate, VM.Audit, VM.Clone, VM.Config.CDROM, VM.Config.CPU,
VM.Config.Cloudinit, VM.Config.Disk, VM.Config.HWType, VM.Config.Memory,
VM.Config.Network, VM.Config.Options, VM.Migrate, VM.PowerMgmt
```

### 3. Dependencies
Install curl (usually pre-installed):

```bash
sudo apt install curl
```

## Configuration

### 1. Environment Setup
Copy the example environment file and configure your credentials:

```bash
cp .env.example .env
vim .env
```

### 2. Required Configuration
Edit `.env` with your Proxmox details:

```bash
# Proxmox API Settings
PROXMOX_API_HOST=192.168.1.100
PROXMOX_API_USER=root@pam
PROXMOX_API_TOKEN_ID=ttdaiu
PROXMOX_API_TOKEN_SECRET=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
PROXMOX_NODE=pve

# VM Template Settings
TEMPLATE_ID_NOBLE=8000
TEMPLATE_ID_JAMMY=8001
```

### 3. Optional Configuration
Customize VM settings in `.env`:

```bash
# VM Configuration
VM_CORES=2
VM_MEMORY=4096
VM_DISK_SIZE=20G
VM_STORAGE=local-lvm
VM_NETWORK_BRIDGE=vmbr0
VM_USER=ubuntu
```

## Available Commands

### Basic VM Management

```bash
# Create test VM
make proxmox-create VM_ID=9000 VM_NAME=ttdaiu-noble-test

# Check status
make proxmox-status VM_ID=9000

# Provision with TTDAIU
make proxmox-provision VM_ID=9000

# SSH into VM
make proxmox-ssh VM_ID=9000

# Destroy VM
make proxmox-destroy VM_ID=9000
```

### Version-specific Commands

```bash
# Ubuntu 24.04 (Noble) - default
make proxmox-create

# Ubuntu 22.04 (Jammy)
make proxmox-create UBUNTU_VERSION=jammy VM_ID=9001 VM_NAME=ttdaiu-jammy-test
```

### Batch Management

```bash
# List all test VMs
make proxmox-list

# Clean all test VMs (with confirmation)
make proxmox-clean
```

### Testing with Specific Tags

```bash
# Test only APT packages
make proxmox-provision VM_ID=9000 TAGS=apt

# Test only Snap packages
make proxmox-provision VM_ID=9000 TAGS=snap
```

## Recommended Workflow

### 1. Role Development

```bash
# Create VM for testing
make proxmox-create VM_ID=9000

# Check if VM is ready
make proxmox-status VM_ID=9000

# Test specific role
make proxmox-provision VM_ID=9000 TAGS=my-role

# SSH to verify result
make proxmox-ssh VM_ID=9000

# Destroy when finished
make proxmox-destroy VM_ID=9000
```

### 2. Complete Testing

```bash
# Create VMs for both versions
make proxmox-create VM_ID=9000 VM_NAME=ttdaiu-noble-test
make proxmox-create UBUNTU_VERSION=jammy VM_ID=9001 VM_NAME=ttdaiu-jammy-test

# Provision both
make proxmox-provision VM_ID=9000
make proxmox-provision UBUNTU_VERSION=jammy VM_ID=9001

# Clean up when finished
make proxmox-clean
```

## Advanced Configuration

### Templates with Cloud-Init

Your templates should have:

1. **QEMU Guest Agent** installed
2. **Cloud-init** configured
3. **SSH keys** accepted
4. **Ubuntu user** created

### Template Creation Example

```bash
# Download Ubuntu ISO
wget https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso

# Create base VM
qm create 8000 --name ubuntu-24.04-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0

# Attach ISO
qm importdisk 8000 ubuntu-24.04-live-server-amd64.iso local-lvm

# Configure Cloud-init
qm set 8000 --cloudinit-device ide2
qm set 8000 --scsihw virtio-scsi-pci
qm set 8000 --scsi0 local-lvm:vm-8000-disk-0

# Convert to template
qm template 8000
```

## Security

### Environment File Protection
The `.env` file contains sensitive credentials and is automatically excluded from git:

```bash
# Never commit these files
.env
.env.local
.env.production
proxmox.conf
```

### API Token Security
- Use dedicated API tokens instead of root passwords
- Limit token permissions to only required VM operations
- Rotate tokens regularly
- Never share tokens in documentation or commits

## Troubleshooting

### Common Issues

#### 1. API Token Error
```
Error: PROXMOX_API_TOKEN_SECRET not set
```

**Solution**: Create `.env` file from `.env.example` and set your credentials

#### 2. Template not found
```
curl: (22) The requested URL returned error: 500
```

**Solution**: Check template IDs in `.env` file match your Proxmox templates

#### 3. VM does not respond to SSH
```
Could not get VM IP address
```

**Solution**: Wait for cloud-init to complete or check if QEMU Guest Agent is installed

#### 4. Network connectivity issues
```
curl: (7) Failed to connect to proxmox host
```

**Solution**: Check `PROXMOX_API_HOST` and network connectivity

### Debug Commands

```bash
# Test API connectivity
curl -k https://$PROXMOX_API_HOST:8006/api2/json/version

# List all VMs
curl -k -H "Authorization: PVEAPIToken=$PROXMOX_API_USER!$PROXMOX_API_TOKEN_ID=$PROXMOX_API_TOKEN_SECRET" \
  https://$PROXMOX_API_HOST:8006/api2/json/nodes/$PROXMOX_NODE/qemu

# Check VM status manually
curl -k -H "Authorization: PVEAPIToken=$PROXMOX_API_USER!$PROXMOX_API_TOKEN_ID=$PROXMOX_API_TOKEN_SECRET" \
  https://$PROXMOX_API_HOST:8006/api2/json/nodes/$PROXMOX_NODE/qemu/$VM_ID/status/current
```

## Comparison: Vagrant vs Proxmox

### Vagrant
- ✅ Fast for development
- ✅ Simple configuration
- ✅ Local isolation
- ❌ Limited to local host
- ❌ Limited performance

### Proxmox
- ✅ Environment closer to production
- ✅ Better performance
- ✅ Advanced network features
- ✅ Snapshots and backup
- ❌ More complex configuration
- ❌ Requires dedicated infrastructure

Use **Vagrant** for rapid development and **Proxmox** for testing closer to production!

## Integration with CI/CD

### Environment Variables in CI
Set these as secure environment variables in your CI system:

```bash
PROXMOX_API_HOST
PROXMOX_API_USER
PROXMOX_API_TOKEN_ID
PROXMOX_API_TOKEN_SECRET
PROXMOX_NODE
```

### Pipeline Example
```yaml
# .github/workflows/proxmox-test.yml
test-proxmox:
  runs-on: self-hosted
  steps:
    - name: Test on Proxmox
      env:
        PROXMOX_API_HOST: ${{ secrets.PROXMOX_API_HOST }}
        PROXMOX_API_TOKEN_SECRET: ${{ secrets.PROXMOX_API_TOKEN_SECRET }}
      run: |
        make proxmox-create VM_ID=${{ github.run_number }}
        make proxmox-provision VM_ID=${{ github.run_number }}
        make proxmox-destroy VM_ID=${{ github.run_number }}
```