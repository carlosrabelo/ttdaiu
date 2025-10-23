# TTDAIU - Things to Do After Installing Ubuntu

**TTDAIU** is an Ansible-based automation tool that configures and optimizes Ubuntu systems after installation. It installs essential applications, development tools, and system utilities automatically.

## Purpose

Automate the post-installation setup process for Ubuntu systems, ensuring consistent configuration across machines with minimal manual intervention.

## Quick Start

### Prerequisites
- Ubuntu 22.04 (Jammy) or 24.04 (Noble)
- Ansible installed (or run `make install-deps`)
- Sudo access

### Basic Usage

```bash
# Install dependencies
make install-deps

# Run full setup (Ubuntu 24.04)
make run

# Run specific components
make run TAGS=packages

# Run for Ubuntu 22.04
make run UBUNTU_VERSION=jammy

# Preview changes without applying
make dry-run
```

## Documentation

- **Guide**: [docs/GUIDE.md](docs/GUIDE.md) - Complete usage guide with all targets and variables

## Notice

This project is intended for personal use. Feel free to fork and customize it for your own needs.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
