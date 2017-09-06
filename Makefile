include utils/Makefile.help
include utils/Makefile.functions
# Makefile.
SHELL := /bin/bash
.DEFAULT_GOAL := setup

setup: root intermediate ##@default Creates the root and the intermediate certificate authority.
.PHONY: setup

all: root intermediate etcd kubernetes ##@default Creates all certificate authorities, root, intermediate, etcd, kubernetes.
.PHONY: all

clean: ##@targets Removes all generated files.
	cd docker_registry && $(MAKE) clean
	cd etcd_ca && $(MAKE) clean
	cd intermediate && $(MAKE) clean
	cd kubernetes_ca && $(MAKE) clean
	cd root && $(MAKE) clean
.PHONY: clean

root: ##@targets Creates a new root certificate authority.
	cd root && $(MAKE)
.PHONY: root

intermediate: root ##@targets Creates a new intermediate certificate authority.
	cd intermediate && $(MAKE)
	cd intermediate && $(MAKE) verify
.PHONY: intermediate

etcd: intermediate ##@targets Creates a new etcd certificate authority.
	cd etcd_ca && $(MAKE)
	cd etcd_ca && $(MAKE) verify
.PHONY: etcd

kubernetes: intermediate ##@targets Creates a new kubernetes certificate authority.
	cd kubernetes_ca && $(MAKE)
	cd kubernetes_ca && $(MAKE) verify
.PHONY: kubernetes

docker-registry: intermediate ##@targets Creates a new docker-registry certificate authority.
	cd docker_registry && $(MAKE)
	cd docker_registry && $(MAKE) verify
.PHONY: docker-registry

server:
	$(call check_defined, SERVER_NAME, The server FQDN for the request)
	cd intermediate && $(MAKE) server SERVER_NAME=$(SERVER_NAME)
	cd intermediate && $(MAKE) verify_server SERVER_NAME=$(SERVER_NAME)
.PHONY: server

regenerate: ##@targets Regenerates the certificate revocation lists.
	cd intermediate && $(MAKE) regenerate
.PHONY: regenerate

show-crl: ##@targets Shows the certificate revocation lists.
	cd intermediate && $(MAKE) show_crl
.PHONY: show-crl

ocsp: ##@targets Creates the OCSP cryptographic pair.
	$(call check_defined, OCSP_NAME, The OCSP server FQDN)
	cd intermediate && $(MAKE) ocsp OCSP_NAME=$(OCSP_NAME)
.PHONY: ocsp
