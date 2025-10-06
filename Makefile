# TTDAIU - Things to do after installing Ubuntu
# Ansible automation for Ubuntu post-installation setup

# Load environment variables if .env exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Variables
UBUNTU_VERSION	?= noble
ANSIBLE_DIR	= ./$(UBUNTU_VERSION)
PLAYBOOK	= site.yml
INVENTORY	= inventory/production.ini
TESTING_INVENTORY = inventory/testing.ini
TAGS		?= all
ENV		?= production

# Proxmox settings (can be overridden by .env)
PROXMOX_API_HOST	?= 192.168.1.100
PROXMOX_API_USER	?= root@pam
PROXMOX_API_TOKEN_ID	?= ttdaiu
PROXMOX_API_TOKEN_SECRET	?=
PROXMOX_NODE		?= pve
TEMPLATE_ID_NOBLE	?= 8000
TEMPLATE_ID_JAMMY	?= 8001
VM_CORES		?= 2
VM_MEMORY		?= 4096
VM_DISK_SIZE		?= 20G
VM_STORAGE		?= local-lvm
VM_NETWORK_BRIDGE	?= vmbr0
VM_USER			?= ubuntu
VM_ID			?= 9000
VM_NAME			?= ttdaiu-$(UBUNTU_VERSION)-test

# Internal variables
TEMPLATE_ID = $(if $(filter jammy,$(UBUNTU_VERSION)),$(TEMPLATE_ID_JAMMY),$(TEMPLATE_ID_NOBLE))
PROXMOX_AUTH = PVEAPIToken=$(PROXMOX_API_USER)!$(PROXMOX_API_TOKEN_ID)=$(PROXMOX_API_TOKEN_SECRET)
PROXMOX_API_URL = https://$(PROXMOX_API_HOST):8006/api2/json

# Default target - show help
.DEFAULT_GOAL := help

.PHONY: help run check syntax lint deps install-deps vagrant-up vagrant-provision vagrant-destroy vagrant-status vagrant-ssh vagrant-destroy-all vagrant-clean proxmox-create proxmox-provision proxmox-destroy proxmox-ssh proxmox-status proxmox-list proxmox-clean dry-run test

help:	## Show this help
	@echo "TTDAIU - Things to do after installing Ubuntu"
	@echo ""
	@echo "Main targets:"
	@grep -h -E '^(run|dry-run|test|check|syntax|lint|deps|install-deps|info|clean):.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Vagrant targets:"
	@grep -h -E '^vagrant-.*:.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Proxmox targets:"
	@grep -h -E '^proxmox-.*:.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Usage examples:"
	@printf "  %-32s # Run full setup (Noble/24.04)\n" "make run"
	@printf "  %-32s # Run setup for Jammy/22.04\n" "make run UBUNTU_VERSION=jammy"
	@printf "  %-32s # Run only package-role tasks\n" "make run TAGS=packages"
	@printf "  %-32s # Run only snap-related tasks\n" "make run TAGS=snap"
	@printf "  %-32s # Run in testing environment\n" "make test"
	@printf "  %-32s # Run with testing inventory\n" "make run ENV=testing"
	@printf "  %-32s # Check what would be executed\n" "make dry-run"
	@printf "  %-32s # Start Vagrant environment\n" "make vagrant-up"

run:	## Run Ansible playbook
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		PLAYBOOK=$(PLAYBOOK) \
		INVENTORY=$(INVENTORY) \
		TESTING_INVENTORY=$(TESTING_INVENTORY) \
		TAGS=$(TAGS) \
		ENV=$(ENV) \
		./scripts/run-ansible.sh run

dry-run:	## Run in check mode (preview changes)
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		PLAYBOOK=$(PLAYBOOK) \
		INVENTORY=$(INVENTORY) \
		TESTING_INVENTORY=$(TESTING_INVENTORY) \
		TAGS=$(TAGS) \
		ENV=$(ENV) \
		./scripts/run-ansible.sh dry-run

test:	## Run in testing environment
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		PLAYBOOK=$(PLAYBOOK) \
		INVENTORY=$(INVENTORY) \
		TESTING_INVENTORY=$(TESTING_INVENTORY) \
		TAGS=$(TAGS) \
		ENV=$(ENV) \
		./scripts/run-ansible.sh test


check: syntax	## Check syntax and configuration

syntax:	## Check playbook syntax
	@echo "Checking playbook syntax..."
	@cd $(ANSIBLE_DIR) && ansible-playbook $(PLAYBOOK) --syntax-check

lint:	## Lint with ansible-lint
	@echo "Linting ansible playbook..."
	@cd $(ANSIBLE_DIR) && ansible-lint $(PLAYBOOK) || echo "Note: ansible-lint not installed or found issues"

deps: install-deps	## Install dependencies

install-deps:	## Install Ansible and dependencies
	@./scripts/install-deps.sh

vagrant-up:	## Start Vagrant VM
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		./scripts/vagrant.sh up

vagrant-provision:	## Re-run provisioning
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		./scripts/vagrant.sh provision

vagrant-destroy:	## Destroy Vagrant VM
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		./scripts/vagrant.sh destroy

vagrant-status:	## Show Vagrant status
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		./scripts/vagrant.sh status

vagrant-ssh:	## SSH into Vagrant box
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		./scripts/vagrant.sh ssh

vagrant-destroy-all:	## Destroy all VMs
	@./scripts/vagrant.sh destroy-all

vagrant-clean:	## Clean all VMs and cache
	@./scripts/vagrant.sh clean

proxmox-create:	## Create Proxmox VM from template
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		PROXMOX_API_HOST=$(PROXMOX_API_HOST) \
		PROXMOX_API_USER=$(PROXMOX_API_USER) \
		PROXMOX_API_TOKEN_ID=$(PROXMOX_API_TOKEN_ID) \
		PROXMOX_API_TOKEN_SECRET=$(PROXMOX_API_TOKEN_SECRET) \
		PROXMOX_NODE=$(PROXMOX_NODE) \
		TEMPLATE_ID_NOBLE=$(TEMPLATE_ID_NOBLE) \
		TEMPLATE_ID_JAMMY=$(TEMPLATE_ID_JAMMY) \
		VM_ID=$(VM_ID) \
		VM_NAME=$(VM_NAME) \
		VM_USER=$(VM_USER) \
		PLAYBOOK=$(PLAYBOOK) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		TAGS=$(TAGS) \
		./scripts/proxmox.sh create

proxmox-provision:	## Provision VM with TTDAIU
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		PROXMOX_API_HOST=$(PROXMOX_API_HOST) \
		PROXMOX_API_USER=$(PROXMOX_API_USER) \
		PROXMOX_API_TOKEN_ID=$(PROXMOX_API_TOKEN_ID) \
		PROXMOX_API_TOKEN_SECRET=$(PROXMOX_API_TOKEN_SECRET) \
		PROXMOX_NODE=$(PROXMOX_NODE) \
		TEMPLATE_ID_NOBLE=$(TEMPLATE_ID_NOBLE) \
		TEMPLATE_ID_JAMMY=$(TEMPLATE_ID_JAMMY) \
		VM_ID=$(VM_ID) \
		VM_NAME=$(VM_NAME) \
		VM_USER=$(VM_USER) \
		PLAYBOOK=$(PLAYBOOK) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		TAGS=$(TAGS) \
		./scripts/proxmox.sh provision

proxmox-destroy:	## Destroy Proxmox VM
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		PROXMOX_API_HOST=$(PROXMOX_API_HOST) \
		PROXMOX_API_USER=$(PROXMOX_API_USER) \
		PROXMOX_API_TOKEN_ID=$(PROXMOX_API_TOKEN_ID) \
		PROXMOX_API_TOKEN_SECRET=$(PROXMOX_API_TOKEN_SECRET) \
		PROXMOX_NODE=$(PROXMOX_NODE) \
		TEMPLATE_ID_NOBLE=$(TEMPLATE_ID_NOBLE) \
		TEMPLATE_ID_JAMMY=$(TEMPLATE_ID_JAMMY) \
		VM_ID=$(VM_ID) \
		VM_NAME=$(VM_NAME) \
		./scripts/proxmox.sh destroy

proxmox-ssh:	## SSH into Proxmox VM
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		PROXMOX_API_HOST=$(PROXMOX_API_HOST) \
		PROXMOX_API_USER=$(PROXMOX_API_USER) \
		PROXMOX_API_TOKEN_ID=$(PROXMOX_API_TOKEN_ID) \
		PROXMOX_API_TOKEN_SECRET=$(PROXMOX_API_TOKEN_SECRET) \
		PROXMOX_NODE=$(PROXMOX_NODE) \
		TEMPLATE_ID_NOBLE=$(TEMPLATE_ID_NOBLE) \
		TEMPLATE_ID_JAMMY=$(TEMPLATE_ID_JAMMY) \
		VM_ID=$(VM_ID) \
		VM_NAME=$(VM_NAME) \
		VM_USER=$(VM_USER) \
		./scripts/proxmox.sh ssh

proxmox-status:	## Show Proxmox VM status
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		PROXMOX_API_HOST=$(PROXMOX_API_HOST) \
		PROXMOX_API_USER=$(PROXMOX_API_USER) \
		PROXMOX_API_TOKEN_ID=$(PROXMOX_API_TOKEN_ID) \
		PROXMOX_API_TOKEN_SECRET=$(PROXMOX_API_TOKEN_SECRET) \
		PROXMOX_NODE=$(PROXMOX_NODE) \
		TEMPLATE_ID_NOBLE=$(TEMPLATE_ID_NOBLE) \
		TEMPLATE_ID_JAMMY=$(TEMPLATE_ID_JAMMY) \
		VM_ID=$(VM_ID) \
		VM_NAME=$(VM_NAME) \
		./scripts/proxmox.sh status

proxmox-list:	## List all test VMs
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		PROXMOX_API_HOST=$(PROXMOX_API_HOST) \
		PROXMOX_API_USER=$(PROXMOX_API_USER) \
		PROXMOX_API_TOKEN_ID=$(PROXMOX_API_TOKEN_ID) \
		PROXMOX_API_TOKEN_SECRET=$(PROXMOX_API_TOKEN_SECRET) \
		PROXMOX_NODE=$(PROXMOX_NODE) \
		TEMPLATE_ID_NOBLE=$(TEMPLATE_ID_NOBLE) \
		TEMPLATE_ID_JAMMY=$(TEMPLATE_ID_JAMMY) \
		VM_ID=$(VM_ID) \
		VM_NAME=$(VM_NAME) \
		./scripts/proxmox.sh list

proxmox-clean:	## Clean all test VMs
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		PROXMOX_API_HOST=$(PROXMOX_API_HOST) \
		PROXMOX_API_USER=$(PROXMOX_API_USER) \
		PROXMOX_API_TOKEN_ID=$(PROXMOX_API_TOKEN_ID) \
		PROXMOX_API_TOKEN_SECRET=$(PROXMOX_API_TOKEN_SECRET) \
		PROXMOX_NODE=$(PROXMOX_NODE) \
		TEMPLATE_ID_NOBLE=$(TEMPLATE_ID_NOBLE) \
		TEMPLATE_ID_JAMMY=$(TEMPLATE_ID_JAMMY) \
		VM_ID=$(VM_ID) \
		VM_NAME=$(VM_NAME) \
		./scripts/proxmox.sh clean

info:	## Show project information
	@echo "Project: TTDAIU - Things to do after installing Ubuntu"
	@echo "Ubuntu Version: $(UBUNTU_VERSION)"
	@echo "Ansible Directory: $(ANSIBLE_DIR)"
	@echo "Playbook: $(PLAYBOOK)"
	@echo "Inventory: $(INVENTORY)"
	@echo "Current Tags: $(TAGS)"
	@echo "Environment: $(ENV)"
	@echo "Ansible version: $$(ansible --version | head -1 2>/dev/null || echo 'Not installed')"

clean:	## Clean temporary files
	@./scripts/cleanup.sh
