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
	@grep -E '^(run|dry-run|test|check|syntax|lint|deps|install-deps|info|clean):.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Vagrant targets:"
	@grep -E '^vagrant-.*:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Proxmox targets:"
	@grep -E '^proxmox-.*:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Usage examples:"
	@echo "  make run                         # Run full setup (Noble/24.04)"
	@echo "  make run UBUNTU_VERSION=jammy   # Run setup for Jammy/22.04"
	@echo "  make run TAGS=apt               # Run only apt-related tasks"
	@echo "  make run TAGS=snap              # Run only snap-related tasks"
	@echo "  make test                       # Run in testing environment"
	@echo "  make run ENV=testing            # Run with testing inventory"
	@echo "  make dry-run                    # Check what would be executed"
	@echo "  make vagrant-up                 # Start Vagrant environment"

run:	## Run Ansible playbook
	@echo "Running TTDAIU setup ($(ENV) environment)..."
	@cd $(ANSIBLE_DIR) && ansible-playbook $(PLAYBOOK) \
		-i $(if $(filter testing,$(ENV)),$(TESTING_INVENTORY),$(INVENTORY)) \
		$(if $(TAGS),--tags "$(TAGS)") \
		--ask-become-pass

dry-run:	## Run in check mode (preview changes)
	@echo "Running TTDAIU setup in check mode ($(ENV) environment)..."
	@cd $(ANSIBLE_DIR) && ansible-playbook $(PLAYBOOK) \
		-i $(if $(filter testing,$(ENV)),$(TESTING_INVENTORY),$(INVENTORY)) \
		$(if $(TAGS),--tags "$(TAGS)") \
		--check --diff \
		--ask-become-pass

test:	## Run in testing environment
	@echo "Running TTDAIU setup in testing environment..."
	@cd $(ANSIBLE_DIR) && ansible-playbook $(PLAYBOOK) \
		-i $(TESTING_INVENTORY) \
		$(if $(TAGS),--tags "$(TAGS)") \
		--ask-become-pass


check: syntax	## Check syntax and configuration

syntax:	## Check playbook syntax
	@echo "Checking playbook syntax..."
	@cd $(ANSIBLE_DIR) && ansible-playbook $(PLAYBOOK) --syntax-check

lint:	## Lint with ansible-lint
	@echo "Linting ansible playbook..."
	@cd $(ANSIBLE_DIR) && ansible-lint $(PLAYBOOK) || echo "Note: ansible-lint not installed or found issues"

deps: install-deps	## Install dependencies

install-deps:	## Install Ansible and dependencies
	@echo "Installing dependencies..."
	@sudo apt update
	@sudo apt install -y ansible git sshpass

vagrant-up:	## Start Vagrant VM
	@echo "Starting Vagrant environment for $(UBUNTU_VERSION)..."
	@cd $(ANSIBLE_DIR) && vagrant up

vagrant-provision:	## Re-run provisioning
	@echo "Provisioning Vagrant environment for $(UBUNTU_VERSION)..."
	@cd $(ANSIBLE_DIR) && vagrant provision

vagrant-destroy:	## Destroy Vagrant VM
	@echo "Destroying Vagrant environment for $(UBUNTU_VERSION)..."
	@cd $(ANSIBLE_DIR) && vagrant destroy -f

vagrant-status:	## Show Vagrant status
	@echo "Vagrant status for $(UBUNTU_VERSION):"
	@cd $(ANSIBLE_DIR) && vagrant status

vagrant-ssh:	## SSH into Vagrant box
	@echo "SSH into $(UBUNTU_VERSION) Vagrant box..."
	@cd $(ANSIBLE_DIR) && vagrant ssh

vagrant-destroy-all:	## Destroy all VMs
	@echo "Destroying all Vagrant environments..."
	@cd ./noble && vagrant destroy -f 2>/dev/null || true
	@cd ./jammy && vagrant destroy -f 2>/dev/null || true

vagrant-clean:	## Clean all VMs and cache
	@echo "Cleaning all Vagrant environments..."
	@$(MAKE) vagrant-destroy-all
	@echo "Removing Vagrant global status entries..."
	@vagrant global-status --prune

proxmox-create:	## Create Proxmox VM from template
	@echo "Creating Proxmox VM $(VM_NAME) (ID: $(VM_ID)) for $(UBUNTU_VERSION)..."
	@if [ -z "$(PROXMOX_API_TOKEN_SECRET)" ]; then \
		echo "Error: PROXMOX_API_TOKEN_SECRET not set. Please create .env file from .env.example"; \
		exit 1; \
	fi
	@curl -k -X POST "$(PROXMOX_API_URL)/nodes/$(PROXMOX_NODE)/qemu/$(TEMPLATE_ID)/clone" \
		-H "Authorization: $(PROXMOX_AUTH)" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-d "newid=$(VM_ID)" \
		-d "name=$(VM_NAME)" \
		-d "target=$(PROXMOX_NODE)" \
		-d "full=1" && \
	echo "VM $(VM_NAME) created successfully"

proxmox-provision:	## Provision VM with TTDAIU
	@echo "Waiting for VM $(VM_NAME) to be ready..."
	@sleep 10
	@echo "Getting VM IP address..."
	@VM_IP=$$(curl -k -s "$(PROXMOX_API_URL)/nodes/$(PROXMOX_NODE)/qemu/$(VM_ID)/agent/network-get-interfaces" \
		-H "Authorization: $(PROXMOX_AUTH)" | \
		grep -o '"ip-address":"[^"]*' | grep -v "127.0.0.1" | head -1 | cut -d'"' -f4); \
	echo "VM IP: $$VM_IP"; \
	if [ -n "$$VM_IP" ]; then \
		echo "Provisioning VM with TTDAIU..."; \
		cd $(ANSIBLE_DIR) && ansible-playbook $(PLAYBOOK) \
			-i "$$VM_IP," \
			-u $(VM_USER) \
			$(if $(TAGS),--tags "$(TAGS)") \
			--ask-become-pass; \
	else \
		echo "Could not get VM IP address. VM may not be ready yet."; \
		exit 1; \
	fi

proxmox-destroy:	## Destroy Proxmox VM
	@echo "Destroying Proxmox VM $(VM_NAME) (ID: $(VM_ID))..."
	@curl -k -X DELETE "$(PROXMOX_API_URL)/nodes/$(PROXMOX_NODE)/qemu/$(VM_ID)" \
		-H "Authorization: $(PROXMOX_AUTH)" && \
	echo "VM $(VM_NAME) destroyed successfully"

proxmox-ssh:	## SSH into Proxmox VM
	@echo "Getting VM IP for SSH connection..."
	@VM_IP=$$(curl -k -s "$(PROXMOX_API_URL)/nodes/$(PROXMOX_NODE)/qemu/$(VM_ID)/agent/network-get-interfaces" \
		-H "Authorization: $(PROXMOX_AUTH)" | \
		grep -o '"ip-address":"[^"]*' | grep -v "127.0.0.1" | head -1 | cut -d'"' -f4); \
	if [ -n "$$VM_IP" ]; then \
		echo "Connecting to $(VM_NAME) at $$VM_IP..."; \
		ssh -o StrictHostKeyChecking=no $(VM_USER)@$$VM_IP; \
	else \
		echo "Could not get VM IP address"; \
		exit 1; \
	fi

proxmox-status:	## Show Proxmox VM status
	@echo "Proxmox VM status for $(VM_NAME) (ID: $(VM_ID)):"
	@curl -k -s "$(PROXMOX_API_URL)/nodes/$(PROXMOX_NODE)/qemu/$(VM_ID)/status/current" \
		-H "Authorization: $(PROXMOX_AUTH)" | \
		grep -o '"status":"[^"]*' | cut -d'"' -f4 || echo "VM not found"

proxmox-list:	## List all test VMs
	@echo "Listing all TTDAIU test VMs in Proxmox..."
	@curl -k -s "$(PROXMOX_API_URL)/nodes/$(PROXMOX_NODE)/qemu" \
		-H "Authorization: $(PROXMOX_AUTH)" | \
		grep -o '"name":"ttdaiu-[^"]*' | cut -d'"' -f4 || echo "No TTDAIU VMs found"

proxmox-clean:	## Clean all test VMs
	@echo "Finding all TTDAIU test VMs..."
	@VM_LIST=$$(curl -k -s "$(PROXMOX_API_URL)/nodes/$(PROXMOX_NODE)/qemu" \
		-H "Authorization: $(PROXMOX_AUTH)" | \
		grep -B2 -A2 '"name":"ttdaiu-' | grep '"vmid"' | grep -o '[0-9]*'); \
	if [ -n "$$VM_LIST" ]; then \
		echo "Found VMs: $$VM_LIST"; \
		echo "This will destroy all TTDAIU test VMs. Continue? (y/N)"; \
		read -r confirm; \
		if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
			for vmid in $$VM_LIST; do \
				echo "Destroying VM $$vmid..."; \
				curl -k -X DELETE "$(PROXMOX_API_URL)/nodes/$(PROXMOX_NODE)/qemu/$$vmid" \
					-H "Authorization: $(PROXMOX_AUTH)"; \
			done; \
			echo "All TTDAIU VMs destroyed"; \
		else \
			echo "Operation cancelled"; \
		fi; \
	else \
		echo "No TTDAIU test VMs found"; \
	fi

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
	@echo "Cleaning temporary files..."
	@find . -name "*.retry" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.pyc" -delete 2>/dev/null || true