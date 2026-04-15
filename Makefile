# TTDAIU - Things to do after installing Ubuntu
# Shell script automation for Ubuntu post-installation setup

# Load environment variables if .env exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Variables
UBUNTU_VERSION	?= noble
VERSION_DIR	= ./ubuntu/$(UBUNTU_VERSION)
SCRIPT		?=
ENV		?= full
HOST		?=
MAKE_DIR	= ./make

# Default target - show help
.DEFAULT_GOAL := help

.PHONY: help info install-deps deps install dry-install uninstall dry-uninstall clean

# =============================================================================
# Information
# =============================================================================

help:	## Show this help
	@echo "TTDAIU - Things to do after installing Ubuntu"
	@echo ""
	@echo "Main targets:"
	@grep -h -E '^[a-z-]+:.*## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Usage examples:"
	@echo ""
	@echo "  Install:"
	@printf "    %-48s %s\n" "make install" "# Noble/24.04, completo, local"
	@printf "    %-48s %s\n" "make install ENV=base" "# Apenas perfil base"
	@printf "    %-48s %s\n" "make install SCRIPT=node,docker" "# Scripts específicos"
	@printf "    %-48s %s\n" "make install UBUNTU_VERSION=jammy" "# Jammy/22.04"
	@printf "    %-48s %s\n" "make install HOST=root@server" "# Remoto via SSH"
	@echo ""
	@echo "  Uninstall:"
	@printf "    %-48s %s\n" "make uninstall" "# Remove tudo"
	@printf "    %-48s %s\n" "make uninstall SCRIPT=docker" "# Remove componente específico"
	@echo ""
	@echo "  Preview:"
	@printf "    %-48s %s\n" "make dry-install SCRIPT=node" "# Preview da instalação"
	@printf "    %-48s %s\n" "make dry-uninstall SCRIPT=node" "# Preview da desinstalação"

info:	## Show current configuration
	@echo "Project       : TTDAIU - Things to do after installing Ubuntu"
	@echo "Ubuntu Version: $(UBUNTU_VERSION)"
	@echo "Directory     : $(VERSION_DIR)"
	@echo "Scripts       : $(if $(SCRIPT),$(SCRIPT),todos)"
	@echo "Environment   : $(ENV)"
	@echo "Host (SSH)    : $(if $(HOST),$(HOST),local)"

# =============================================================================
# Setup
# =============================================================================

install-deps:	## Install dependencies (curl, rsync)
	@$(MAKE_DIR)/install-deps.sh

deps: install-deps	## Install dependencies (alias)

# =============================================================================
# Execution
# =============================================================================

install:	## Install and configure the system
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		VERSION_DIR=$(VERSION_DIR) \
		SCRIPT=$(SCRIPT) \
		ENV=$(ENV) \
		HOST=$(HOST) \
		$(MAKE_DIR)/run-shell.sh run

dry-install:	## Preview changes (no modifications)
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		VERSION_DIR=$(VERSION_DIR) \
		SCRIPT=$(SCRIPT) \
		ENV=$(ENV) \
		HOST=$(HOST) \
		$(MAKE_DIR)/run-shell.sh dry-run

uninstall:	## Remove installed components
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		VERSION_DIR=$(VERSION_DIR) \
		SCRIPT=$(SCRIPT) \
		ENV=$(ENV) \
		HOST=$(HOST) \
		$(MAKE_DIR)/run-shell.sh uninstall

dry-uninstall:	## Preview what would be removed (no modifications)
	@UBUNTU_VERSION=$(UBUNTU_VERSION) \
		VERSION_DIR=$(VERSION_DIR) \
		SCRIPT=$(SCRIPT) \
		ENV=$(ENV) \
		HOST=$(HOST) \
		$(MAKE_DIR)/run-shell.sh dry-uninstall

# =============================================================================
# Maintenance
# =============================================================================

clean:	## Clean temporary files
	@$(MAKE_DIR)/cleanup.sh
