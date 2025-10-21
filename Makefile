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
INVENTORY	= inventory/base.ini
FULL_INVENTORY = inventory/full.ini
TAGS		?=
ENV		?= base



# Default target - show help
.DEFAULT_GOAL := help

.PHONY: help run dry-run check syntax lint deps install-deps info clean

help:	## Show this help
	@echo "TTDAIU - Things to do after installing Ubuntu"
	@echo ""
	@echo "Main targets:"
	@grep -h -E '^(run|dry-run|check|syntax|lint|deps|install-deps|info|clean):.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  %-13s %s\n", $$1, $$2}'
	@echo ""
	@echo "Usage examples:"
	@printf "  %-30s # Run setup (base env, Noble/24.04)\n" "make run"
	@printf "  %-30s # Run setup for Jammy/22.04\n" "make run UBUNTU_VERSION=jammy"
	@printf "  %-30s # Run in base environment\n" "make run ENV=base"
	@printf "  %-30s # Run in full environment\n" "make run ENV=full"
	@printf "  %-30s # Run only package-role tasks\n" "make run TAGS=packages"
	@printf "  %-30s # Run only snap-related tasks\n" "make run TAGS=snap"
	@printf "  %-30s # Check what would be executed\n" "make dry-run"

run:	## Run Ansible playbook
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		PLAYBOOK=$(PLAYBOOK) \
		INVENTORY=$(INVENTORY) \
		FULL_INVENTORY=$(FULL_INVENTORY) \
		TAGS=$(TAGS) \
		ENV=$(ENV) \
		./scripts/run-ansible.sh run

dry-run:	## Run in check mode (preview changes)
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		ANSIBLE_DIR=$(ANSIBLE_DIR) \
		PLAYBOOK=$(PLAYBOOK) \
		INVENTORY=$(INVENTORY) \
		FULL_INVENTORY=$(FULL_INVENTORY) \
		TAGS=$(TAGS) \
		ENV=$(ENV) \
		./scripts/run-ansible.sh dry-run


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



info:	## Show project information
	@echo "Project: TTDAIU - Things to do after installing Ubuntu"
	@echo "Ubuntu Version: $(UBUNTU_VERSION)"
	@echo "Ansible Directory: $(ANSIBLE_DIR)"
	@echo "Playbook: $(PLAYBOOK)"
	@echo "Inventory: $(INVENTORY)"
	@echo "Current Tags: $(if $(TAGS),$(TAGS),auto (ENV=$(ENV)))"
	@echo "Environment: $(ENV)"
	@echo "Ansible version: $$(ansible --version | head -1 2>/dev/null || echo 'Not installed')"


clean:	## Clean temporary files
	@./scripts/cleanup.sh
