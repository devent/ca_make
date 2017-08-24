# Include utilities.
include ../utils/Makefile.functions
include ../utils/Makefile.help
include ../utils/Makefile.ca
# Misc.
SHELL := /bin/bash
OPENSSL_ARGS := -config ./openssl.cnf
# Files and directories.
DIRS := certs csr crl newcerts private passwords
FILES := index.txt
SERIAL := serial
CRL_NUMBER := crlnumber
CONFIG_FILE := openssl.cnf
ROOT_KEY := private/intermediate_key.pem
CA_CSR := csr/intermediate_csr.pem
CA_CERT := certs/intermediate_cert.pem
CA_CHAIN := certs/ca_chain_cert.pem
# Makefile.
.DEFAULT_GOAL := run

run: ca ##@default Creates the intermediate certificate authority.
.PHONY: run

setup: $(OPENSSL) $(DIRS) $(FILES)
.PHONY: setup

ca: setup $(ROOT_KEY) $(CA_CSR) $(CA_CERT) $(CA_CHAIN) $(SERIAL) $(CRL_NUMBER) ##@targets Creates a new intermediate certificate authority.
.PHONY: ca

clean: ##@targets Deletes all created directories and files.
	rm -rf $(DIRS) $(FILES) $(SERIAL) index.txt.attr index.txt.attr.old index.txt.old crlnumber *.old
.PHONY: clean

show: ##@targets Shows the intermediate certificate.
	$(OPENSSL) x509 -noout -text -in $(CA_CERT)
.PHONY: show

verify: ##@targets Verifies the intermediate certificate against the root certificate.
	set $(SET_FLAG) \
	&& cd ../root \
	&& $(OPENSSL) verify -CAfile certs/ca_cert.pem ../intermediate/$(CA_CERT)
.PHONY: verify

regenerate: ##@targets Regenerates the certificate revocation list.
	$(PRINT_ROOT_KEY_PASS)
	$(OPENSSL) ca $(OPENSSL_ARGS) -gencrl -out crl/intermediate.crl.pem
.PHONY: regenerate

show-crl: ##@targets Shows the certificate revocation list.
	$(OPENSSL) crl -in crl/intermediate.crl.pem -noout -text
.PHONY: show-crl

server: _create_key _create_crt ##@targets Creates a new server certificate.
	$(call check_defined, SERVER_NAME, The server FQDN for the request)
	set $(SET_FLAG) \
	&& $(SERVER_ARGS) \
	&& $(call printInfo1, Signing $$SERVER_CSR...) \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& $(OPENSSL) ca $(OPENSSL_ARGS) -create_serial -extensions server_cert -days $(SERVER_CERT_DAYS) -notext -md sha256 -in $$SERVER_CSR -out $$SERVER_CERT
.PHONY: server

show-server: _show_server ##@targets Shows the server certificate. Needed arguments: SERVER_NAME.
.PHONY: show-server

verify-server: _verify_server ##@targets Verifies the server certificate. Needed arguments: SERVER_NAME.
.PHONY: verify-server

revoke-server: _revoke_server ##@targets Revokes the server certificate. Needed arguments: SERVER_NAME.
.PHONY: revoke-server

ocsp: _ocsp ##@targets Creates the OCSP cryptographic pair.

start-ocsp: _start-ocsp ##@targets Starts an OCSP responder on localhost.
.PHONY: start-ocsp

query-ocsp: _query-ocsp ##@targets Query the OCSP responder on localhost.
.PHONY: query-ocsp

$(DIRS):
	mkdir -p $(DIRS)
	chmod 700 private passwords
	
$(FILES):
	touch $(FILES)

$(SERIAL):

$(CRL_NUMBER):
	echo 1000 > crlnumber

$(ROOT_KEY):
	set $(SET_FLAG) \
	&& ROOT_KEY_PASS="passwords/`basename $(ROOT_KEY)`.txt" \
	&& $(PWGEN) 128 1 > "$$ROOT_KEY_PASS" \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $(ROOT_KEY) 4096

$(CA_CSR):
	$(PRINT_ROOT_KEY_PASS)
	$(call printInfo1, "Default values can be used.")
	$(OPENSSL) req $(OPENSSL_ARGS) -new -sha256 -key $(ROOT_KEY) -out $(CA_CSR)

$(CA_CERT):
	set $(SET_FLAG) \
	&& cd ../root \
	&& ROOT_KEY_PASS="passwords/ca_key.pem.txt" \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) ca $(OPENSSL_ARGS) -create_serial -extensions v3_intermediate_ca -days $(INTERMEDIATE_CA_CERT_DAYS) -notext -md sha256 -in ../intermediate/$(CA_CSR) -out ../intermediate/$(CA_CERT)

$(CA_CHAIN):
	cat $(CA_CERT) ../root/certs/ca_cert.pem > $(CA_CHAIN)
