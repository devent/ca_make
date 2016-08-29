# Include utilities.
include ../utils/Makefile.help
include ../utils/Makefile.functions
# Misc.
SHELL := /bin/bash
CA_CERT_DAYS := 7300
OPENSSL_ARGS := -config ./openssl.cnf
# Files and directories.
DIRS := certs crl newcerts private passwords
FILES := index.txt
SERIAL := serial
CONFIG_FILE := openssl.cnf
ROOT_KEY := private/ca_key.pem
CA_CERT := certs/ca_cert.pem
# Tools.
OPENSSL := /usr/bin/openssl
PWGEN := /usr/bin/pwgen
# Makefile.
.PHONY: run setup ca clean show
.DEFAULT_GOAL := run

run: ca ##@default Creates the root certificate authority.

setup: $(OPENSSL) $(DIRS) $(FILES)

ca: setup $(ROOT_KEY) $(CA_CERT) $(SERIAL) ##@targets Creates a new root certificate authority.

clean: ##@targets Deletes all created directories and files.
	rm -rf $(DIRS) $(FILES) $(SERIAL) index.txt.attr index.txt.attr.old index.txt.old crlnumber

show: ##@targets Shows the root certificate.
	$(OPENSSL) x509 -noout -text -in $(CA_CERT)

$(OPENSSL):
	sudo apt-get install -y openssl

$(PWGEN):
	sudo apt-get install -y pwgen

$(DIRS):
	mkdir -p $(DIRS)
	chmod 700 private passwords
	
$(FILES):
	touch $(FILES)

$(SERIAL):

$(ROOT_KEY):
	set $(SET_FLAG) \
	&& SERVER_KEY=private/$(SERVER_NAME)_key.pem \
	&& SERVER_CSR=csr/$(SERVER_NAME)_csr.pem \
	&& SERVER_CERT=certs/$(SERVER_NAME)_cert.pem \
	&& SERVER_KEY_PASS="passwords/`basename $$SERVER_KEY`.txt" \
	&& $(PWGEN) 128 1 > "$$SERVER_KEY_PASS" \
	&& $(call printInfo2, "$$SERVER_KEY_PASS: `cat $$SERVER_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $$SERVER_KEY 2048 \
	&& $(call printWarn, "Common name must be: $(SERVER_NAME)") \
	&& $(OPENSSL) req $(OPENSSL_ARGS) -key $$SERVER_KEY -new -sha256 -out $$SERVER_CSR \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& $(OPENSSL) ca $(OPENSSL_ARGS) -create_serial -extensions server_cert -days $(SERVER_DAYS) -notext -md sha256 -in $$SERVER_CSR -out $$SERVER_CERT
