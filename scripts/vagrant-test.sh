#!/bin/bash
# TTDAIU Vagrant Testing Workflow
# Script to automate testing across Ubuntu versions with Vagrant

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse command line arguments
UBUNTU_VERSION=${1:-"both"}
TAGS=${2:-"all"}
CLEAN=${3:-"false"}

log_info "TTDAIU Vagrant Testing Workflow"
log_info "Ubuntu Version: $UBUNTU_VERSION"
log_info "Tags: $TAGS"
log_info "Clean: $CLEAN"
echo ""

# Clean existing environments if requested
if [[ "$CLEAN" == "true" ]]; then
    log_info "Cleaning existing Vagrant environments..."
    make vagrant-destroy-all
fi

# Test function
test_version() {
    local version=$1
    local dir="./$version"

    log_info "Testing Ubuntu $version..."

    if [[ ! -d "$dir" ]]; then
        log_error "Directory $dir does not exist!"
        return 1
    fi

    cd "$dir"

    # Check Vagrantfile syntax
    log_info "Checking Vagrantfile syntax for $version..."
    vagrant validate || {
        log_error "Vagrantfile validation failed for $version"
        cd ..
        return 1
    }

    # Start VM
    log_info "Starting VM for $version..."
    vagrant up || {
        log_error "Failed to start VM for $version"
        cd ..
        return 1
    }

    # Run syntax check
    log_info "Checking Ansible syntax for $version..."
    ansible-playbook site.yml --syntax-check || {
        log_error "Ansible syntax check failed for $version"
        cd ..
        return 1
    }

    # Run dry-run
    log_info "Running Ansible dry-run for $version..."
    if [[ "$TAGS" == "all" ]]; then
        vagrant provision --provision-with ansible || {
            log_warning "Provisioning failed for $version"
        }
    else
        # For specific tags, we need to run ansible directly
        ansible-playbook site.yml -i inventory/testing.ini --check --tags "$TAGS" || {
            log_warning "Ansible dry-run with tags failed for $version"
        }
    fi

    # Show VM status
    log_info "VM Status for $version:"
    vagrant status

    cd ..
    log_success "Testing completed for Ubuntu $version"
}

# Main execution
case "$UBUNTU_VERSION" in
    "noble")
        test_version "noble"
        ;;
    "jammy")
        test_version "jammy"
        ;;
    "both")
        test_version "noble"
        echo ""
        test_version "jammy"
        ;;
    *)
        log_error "Invalid Ubuntu version: $UBUNTU_VERSION"
        echo "Usage: $0 [noble|jammy|both] [tags] [clean]"
        echo "Examples:"
        echo "  $0 noble packages false"
        echo "  $0 both all true"
        echo "  $0 jammy snap false"
        exit 1
        ;;
esac

log_success "Vagrant testing workflow completed!"

# Summary
echo ""
log_info "Summary of available commands:"
echo "  make vagrant-up UBUNTU_VERSION=noble    # Start Noble VM"
echo "  make vagrant-up UBUNTU_VERSION=jammy    # Start Jammy VM"
echo "  make vagrant-ssh UBUNTU_VERSION=noble   # SSH into Noble VM"
echo "  make vagrant-provision UBUNTU_VERSION=jammy  # Re-run provisioning"
echo "  make vagrant-destroy-all                # Clean all VMs"
