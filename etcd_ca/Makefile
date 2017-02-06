# Include utilities.
include ../utils/Makefile.functions
include ../utils/Makefile.help
include ../utils/Makefile.ca
# Misc.
SHELL := /bin/bash
CA_CERT_DAYS := 3650
SERVER_DAYS := 375
OCSP_DAYS := 375
OPENSSL_ARGS := -config ./openssl.cnf
# Files and directories.
DIRS := certs csr crl newcerts private passwords
FILES := index.txt
SERIAL := serial
CRL_NUMBER := crlnumber
CONFIG_FILE := openssl.cnf
ROOT_KEY := private/ca_key.pem
CA_CERT := certs/ca_cert.pem
# Client certificate.
CLIENT_CERT_DAYS := 365
# Tools.
OPENSSL := /usr/bin/openssl
PWGEN := /usr/bin/pwgen
# Makefile.
.PHONY: run setup ca clean show verify regenerate show_crl server show_server verify_server revoke_server ocsp start_ocsp query_ocsp
.DEFAULT_GOAL := run

run: ca ##@default Creates the intermediate certificate authority.

setup: $(OPENSSL) $(DIRS) $(FILES)

ca: setup $(ROOT_KEY) $(CA_CERT) $(SERIAL) ##@targets Creates a new intermediate certificate authority.

clean: ##@targets Deletes all created directories and files.
	rm -rf $(DIRS) $(FILES) $(SERIAL) index.txt.attr index.txt.attr.old index.txt.old crlnumber *.old

server: _create_key _create_crt ##@targets Creates a new server certificate. Needed arguments SERVER_NAME.
	set $(SET_FLAG) \
	&& $(SERVER_ARGS) \
	&& $(call printInfo1, "Signing '$$SERVER_CSR'...") \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& $(OPENSSL) ca $(OPENSSL_ARGS) -create_serial -extensions etcd_server -days $(SERVER_DAYS) -notext -md sha256 -in $$SERVER_CSR -out $$SERVER_CERT

show_server: ##@targets Shows the server certificate.
	$(call check_defined, SERVER_NAME, The server FQDN for the request)
	$(OPENSSL) x509 -noout -text -in certs/$(SERVER_NAME)_cert.pem

show_server: _show_server ##@targets Shows the server certificate. Needed arguments: SERVER_NAME.

verify_server: _verify_server ##@targets Verifies the server certificate. Needed arguments: SERVER_NAME.

revoke_server: _revoke_server ##@targets Revokes the server certificate. Needed arguments: SERVER_NAME.

client: ##@targets Creates a new client certificate, needed argument CLIENT_NAME.
	$(call check_defined, CLIENT_NAME, The client name for the request)
	set $(SET_FLAG) \
	&& CLIENT_KEY=private/$(CLIENT_NAME)_key.pem \
	&& CLIENT_KEY_INSECURE=private/$(CLIENT_NAME)_key_insecure.pem \
	&& CLIENT_CSR=csr/$(CLIENT_NAME)_csr.pem \
	&& CLIENT_CERT=certs/$(CLIENT_NAME)_cert.pem \
	&& CLIENT_KEY_PASS="passwords/`basename $$CLIENT_KEY`.txt" \
	&& $(PWGEN) 128 1 > "$$CLIENT_KEY_PASS" \
	&& $(call printInfo2, "$$CLIENT_KEY_PASS: `cat $$CLIENT_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $$CLIENT_KEY $(CLIENT_KEY_SIZE) \
	&& $(OPENSSL) rsa -in $$CLIENT_KEY -out $$CLIENT_KEY_INSECURE \
	&& $(call printWarn, "Common name must be: $(CLIENT_NAME)") \
	&& $(OPENSSL) req -config ./openssl.cnf -key $$CLIENT_KEY_INSECURE -new -sha256 -out $$CLIENT_CSR \
	&& $(call printInfo1, "Signing `echo $$CLIENT_CSR`...") \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& $(OPENSSL) ca -config ./openssl.cnf -create_serial -extensions etcd_client -policy policy_loose -days $(CLIENT_CERT_DAYS) -notext -md sha256 -in $$CLIENT_CSR -out $$CLIENT_CERT

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
	&& ROOT_KEY_PASS="passwords/`basename $(ROOT_KEY)`.txt" \
	&& ROOT_KEY_INSECURE="private/`basename $(ROOT_KEY) .pem`_insecure.pem" \
	&& $(PWGEN) 128 1 > "$$ROOT_KEY_PASS" \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $(ROOT_KEY) $(ROOT_KEY_SIZE) \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) rsa -in $(ROOT_KEY) -out $$ROOT_KEY_INSECURE

$(CA_CERT):
	$(call printInfo1, "Default values can be used.")
	$(OPENSSL) req $(OPENSSL_ARGS) -key $(ROOT_KEY) -new -x509 -days $(CA_CERT_DAYS) -sha256 -extensions v3_ca -out $(CA_CERT)
