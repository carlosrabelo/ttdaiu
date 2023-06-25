# Ubuntu Version Compatibility Guide

This document outlines the compatibility and differences between supported Ubuntu versions in the TTDAIU project.

## Supported Versions

- **Ubuntu 24.04 LTS (Noble Numbat)** - Primary support
- **Ubuntu 22.04 LTS (Jammy Jellyfish)** - Full compatibility

## Version Selection

### Using the Makefile

```bash
# Run on Ubuntu 24.04 (Noble) - Default
make run

# Run on Ubuntu 22.04 (Jammy)
make run UBUNTU_VERSION=jammy

# Test environments
make test                     # Testing environment
make dry-run                  # Preview changes
```

### Directory Structure

```
ttdaiu/
├── noble/                    # Ubuntu 24.04 configuration
│   ├── site.yml
│   ├── ansible.cfg
│   ├── group_vars/
│   ├── inventory/
│   └── roles/
├── jammy/                    # Ubuntu 22.04 configuration
│   ├── site.yml
│   ├── ansible.cfg
│   ├── group_vars/
│   ├── inventory/
│   └── roles/
└── Makefile                  # Multi-version support
```

## Package Compatibility

### APT Packages

All APT packages used in Noble are compatible with Jammy:

✅ **Fully Compatible**
- Development tools (build-essential, git, curl)
- Media packages (vlc, audacity, gimp)
- Productivity tools (meld, gnome-tweaks, remmina)
- LaTeX packages (texlive, texstudio)
- Network tools (openssh-server, network-manager plugins)

⚠️ **Version Differences**
- Python 3.12 (Noble) vs Python 3.10 (Jammy)
- GCC 14 (Noble) vs GCC 11 (Jammy)
- OpenJDK 21 (Noble) vs OpenJDK 11/17 (Jammy)

### Snap Packages

All snap packages are compatible across versions:

✅ **Fully Compatible**
- Docker
- Go
- Node.js
- Visual Studio Code
- Chromium
- LibreOffice

### Package Management Changes

#### Ubuntu 24.04 (Noble) Changes
- New deb822-formatted .sources files
- Enhanced security with 1:1 key-repository relationship
- Updated APT priority system for "proposed" packages

#### Ubuntu 22.04 (Jammy) Behavior
- Traditional sources.list format
- Existing APT security model
- Standard package priorities

## Known Issues and Workarounds

### Snap in Docker Containers
**Issue**: Snap packages may fail in Docker containers on both versions
**Workaround**: Use traditional package installation or Docker-specific alternatives

### Chromium Installation
**Noble**: Available via snap (default) or alternative repositories
**Jammy**: Chromium-browser package redirects to snap by default

### Python Version Dependencies
**Noble**: Some Python packages may require Python 3.12
**Jammy**: Python 3.10 may require backports for newer features

## Version-Specific Features

### Ubuntu 24.04 (Noble) Specific
- Enhanced package security
- Updated software versions
- Improved performance optimizations
- New repository format

### Ubuntu 22.04 (Jammy) Specific
- LTS stability focus
- Conservative package versions
- Proven compatibility
- Extended support timeline

## Migration Guidelines

### From Jammy to Noble
1. Backup configuration files
2. Review package version changes
3. Test in virtual environment first
4. Update any custom scripts for new Python version

### From Noble to Jammy
1. Consider package downgrades
2. Review Python 3.12 dependencies
3. Test snap compatibility
4. Verify all features work with older packages

## Testing Recommendations

### For Development
```bash
# Test on both versions
make test UBUNTU_VERSION=noble
make test UBUNTU_VERSION=jammy

# Verify package compatibility
make syntax UBUNTU_VERSION=jammy
make syntax UBUNTU_VERSION=noble
```

### For Production
- Use Noble for new deployments
- Keep Jammy for stability-critical systems
- Plan migration timeline for LTS support overlap

## Configuration Differences

### Environment Variables
- `ubuntu_version`: "24.04" vs "22.04"
- `ubuntu_codename`: "noble" vs "jammy"
- `log_path`: Different log files per version

### Feature Flags
Both versions support the same feature flags:
- `install_development_tools`
- `install_media_tools`
- `install_productivity_tools`
- `install_latex_tools`
- `configure_bash`
- `setup_networking`
- `enable_backups`

### Inventory Structure
Both versions use identical inventory structure:
- `production.ini` / `testing.ini`
- `group_vars/` for environment-specific settings
- Host-specific variables in `host_vars/`

## Performance Considerations

### Ubuntu 24.04 (Noble)
- Faster boot times
- Improved memory management
- Enhanced security overhead (minimal)

### Ubuntu 22.04 (Jammy)
- Proven performance baseline
- Lower resource requirements
- Mature optimization settings

## Support Lifecycle

### Ubuntu 24.04 LTS (Noble)
- Support until: April 2029
- Extended Security Maintenance until: April 2034

### Ubuntu 22.04 LTS (Jammy)
- Support until: April 2027
- Extended Security Maintenance until: April 2032

## Troubleshooting

### Common Issues

1. **Package not found**
   - Check version-specific package names
   - Verify repository configuration

2. **Snap installation fails**
   - Ensure snapd service is running
   - Check network connectivity

3. **Python version conflicts**
   - Use version-specific virtual environments
   - Install compatibility packages

### Debug Commands
```bash
# Check current Ubuntu version
lsb_release -a

# Verify package availability
apt-cache policy <package-name>

# Check snap status
snap list
snap changes
```

## Best Practices

1. **Always specify Ubuntu version** when deploying
2. **Test on target version** before production
3. **Use version-specific variables** in configurations
4. **Monitor LTS support timelines** for planning
5. **Keep configurations synchronized** between versions where possible