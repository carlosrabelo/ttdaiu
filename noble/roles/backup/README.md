# backup Role

Backup and restore configuration files This role helps preserve important user configurations

## Overview

This Ansible role automates the installation and configuration of Backup on Ubuntu systems.

## Requirements

- Ubuntu 20.04+ (Focal Fossa and later)
- Ansible 2.9+
- Sudo/root privileges
- Internet connection for package downloads


### Available Variables

- `main_user`: Main user for configuration


## Usage

### Basic Usage
```bash
# Run this role specifically
ansible-playbook site.yml --tags backup

# Run with custom variables
ansible-playbook site.yml -e "variable_name=value" --tags backup
```

### Example Playbook
```yaml
- name: Configure backup
  hosts: all
  become: true
  roles:
    - backup
```


### Usage Examples

Run this role:
```bash
ansible-playbook site.yml --tags backup
```


## Tasks

This role performs the following main tasks:

- Check if backup is enabled
- Create backup directory
- Create backup subdirectories
- Backup existing configuration files
- Create backup manifest
- Create restore script
- Display backup summary

## Templates

This role provides the following templates:
- `templates/backup_manifest.yml.j2`
- `templates/restore.sh.j2`

## Role-Specific Information

This role manages the installation and configuration of Backup.

### Verification
```bash
# Check if the role was applied successfully
ansible-playbook site.yml --tags backup --check
```


## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure running with sudo or as root
   - Check file permissions in target directories

2. **Package Installation Failures**
   - Verify internet connectivity
   - Check package repository availability
   - Run `sudo apt update` manually

3. **Service Failures**
   - Check system logs: `journalctl -u <service-name>`
   - Verify configuration syntax
   - Check resource availability

### Debug Mode
Run with increased verbosity for debugging:
```bash
ansible-playbook site.yml --tags $role -vvv
```

### Dry Run
Test changes without applying:
```bash
ansible-playbook site.yml --tags $role --check
```

## Contributing

To contribute to this role:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This role is part of the TTDAIU project and follows the same license terms.

---

*Generated automatically on $(date +%Y-%m-%d)*
