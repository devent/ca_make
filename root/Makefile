# Include utilities.
include ../utils/Makefile.functions
include ../utils/Makefile.help
include ../utils/Makefile.ca
# Misc.
SHELL := /bin/bash
CA_CERT_DAYS := 7300
OPENSSL_ARGS := -config ./openssl.cnf
# Files and directories.
DIRS := certs csr crl newcerts private passwords
FILES := index.txt
SERIAL := serial
CONFIG_FILE := openssl.cnf
ROOT_KEY := private/ca_key.pem
CA_CERT := certs/ca_cert.pem
# Makefile.
.DEFAULT_GOAL := run

run: ca ##@default Creates the root certificate authority.
.PHONY: run

setup: $(OPENSSL) $(DIRS) $(FILES)
.PHONY: setup

ca: setup $(ROOT_KEY) $(CA_CERT) $(SERIAL) ##@targets Creates a new root certificate authority.
.PHONY: ca

clean: ##@targets Deletes all created directories and files.
	rm -rf $(DIRS) $(FILES) $(SERIAL) index.txt.attr index.txt.attr.old index.txt.old crlnumber
.PHONY: clean

show: ##@targets Shows the root certificate.
	$(OPENSSL) x509 -noout -text -in $(CA_CERT)
.PHONY: show

create_key: _create_key ##@targets Creates a new certificate key. Optionally, the key size can be specified by setting SERVER_KEY_SIZE.
.PHONY: create_key

create_crt: _create_crt ##@targets Creates a new certificate signing request.
.PHONY: create_crt

$(DIRS):
	mkdir -p $(DIRS)
	chmod 700 private passwords
	
$(FILES):
	touch $(FILES)

$(SERIAL):

$(ROOT_KEY):
	set $(SET_FLAG) \
	&& ROOT_KEY_PASS="passwords/`basename $(ROOT_KEY)`.txt" \
	&& $(PWGEN) 128 1 > "$$ROOT_KEY_PASS" \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $(ROOT_KEY) 4096

$(CA_CERT):
	$(call printInfo1, "Default values can be used.")
	$(OPENSSL) req $(OPENSSL_ARGS) -key $(ROOT_KEY) -new -x509 -days $(CA_CERT_DAYS) -sha256 -extensions v3_ca -out $(CA_CERT)
