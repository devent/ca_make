include utils/Makefile.help
include utils/Makefile.functions
SHELL := /bin/bash
# Makefile.
.PHONY: setup clean root intermediate
.DEFAULT_GOAL := setup

setup: root intermediate ##@default Creates the root and the intermediate certificate authority.

clean: ##@targets Removes all generated files.
	cd root && $(MAKE) clean
	cd intermediate && $(MAKE) clean

root: ##@targets Creates a new root certificate authority.
	cd root && $(MAKE)

intermediate: ##@targets Creates a new intermediate certificate authority.
	cd intermediate && $(MAKE)
	cd intermediate && $(MAKE) verify

server:
	$(call check_defined, SERVER_NAME, The server FQDN for the request)
	cd intermediate && $(MAKE) server SERVER_NAME=$(SERVER_NAME)
	cd intermediate && $(MAKE) verify_server SERVER_NAME=$(SERVER_NAME)
