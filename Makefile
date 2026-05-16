INSTALL_DIR ?= $(HOME)/.local/lib/rm-lock
SHELL_RC    ?= $(HOME)/.bashrc
SOURCE_LINE  = source "$(INSTALL_DIR)/rm-lock.sh"  \# rm-lock

MODULES = lib/check.sh lib/add.sh lib/remove.sh lib/list.sh lib/status.sh lib/edit.sh

.PHONY: all install uninstall test deb help

all: help

help:
	@echo "Usage:"
	@echo "  make install      Install to $(INSTALL_DIR)"
	@echo "  make uninstall    Remove installation"
	@echo "  make deb          Build .deb package (requires fpm)"
	@echo "  make test         Run test suite"
	@echo "  make INSTALL_DIR=/custom/path install"

install: scripts/install/install.sh
	@bash scripts/install/install.sh $(INSTALL_DIR)

uninstall: scripts/install/uninstall.sh
	@INSTALL_DIR=$(INSTALL_DIR) bash scripts/install/uninstall.sh

deb: scripts/deb/build.sh
	@bash scripts/deb/build.sh

test:
	@bash tests/test.sh
