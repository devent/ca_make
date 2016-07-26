include utils/Makefile.help
include utils/Makefile.functions
# Makefile.
SHELL := /bin/bash
.PHONY: setup clean root intermediate server regenerate show_crl ocsp
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

regenerate: ##@targets Regenerates the certificate revocation lists.
	cd intermediate && $(MAKE) regenerate

show_crl: ##@targets Shows the certificate revocation lists.
	cd intermediate && $(MAKE) show_crl

ocsp: ##@targets Creates the OCSP cryptographic pair.
	$(call check_defined, OCSP_NAME, The OCSP server FQDN)
	cd intermediate && $(MAKE) ocsp OCSP_NAME=$(OCSP_NAME)
