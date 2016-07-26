# Include utilities.
include ../utils/Makefile.help
include ../utils/Makefile.functions
# Misc.
SHELL := /bin/bash
CA_CERT_DAYS := 3650
SERVER_DAYS := 375
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
# Tools.
OPENSSL := /usr/bin/openssl
PWGEN := /usr/bin/pwgen
# Makefile.
.PHONY: run setup ca clean show
.DEFAULT_GOAL := run

run: ca ##@default Creates the intermediate certificate authority.

setup: $(OPENSSL) $(DIRS) $(FILES)

ca: setup $(ROOT_KEY) $(CA_CSR) $(CA_CERT) $(CA_CHAIN) $(SERIAL) $(CRL_NUMBER) ##@targets Creates a new intermediate certificate authority.

clean: ##@targets Deletes all created directories and files.
	rm -rf $(DIRS) $(FILES) $(SERIAL) index.txt.attr index.txt.attr.old index.txt.old crlnumber

show: ##@targets Shows the intermediate certificate.
	$(OPENSSL) x509 -noout -text -in $(CA_CERT)

verify: ##@targets Verifies the intermediate certificate against the root certificate.
	set $(SET_FLAG) \
	&& cd ../root \
	&& $(OPENSSL) verify -CAfile certs/ca_cert.pem ../intermediate/$(CA_CERT)

regenerate: ##@targets Regenerates the certificate revocation list.
	$(PRINT_ROOT_KEY_PASS)
	$(OPENSSL) ca $(OPENSSL_ARGS) -gencrl -out crl/intermediate.crl.pem

show_crl: ##@targets Shows the certificate revocation list.
	$(OPENSSL) crl -in crl/intermediate.crl.pem -noout -text

server: ##@targets Creates a new server certificate.
	$(call check_defined, SERVER_NAME, The server FQDN for the request)
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

show_server: ##@targets Shows the server certificate.
	$(call check_defined, SERVER_NAME, The server FQDN for the request)
	$(OPENSSL) x509 -noout -text -in certs/$(SERVER_NAME)_cert.pem

verify_server: ##@targets Verifies the server certificate.
	$(call check_defined, SERVER_NAME, The server FQDN for the request)
	$(OPENSSL) verify -CAfile $(CA_CHAIN) certs/$(SERVER_NAME)_cert.pem

revoke_server: ##@targets Revokes the server certificate.
	$(call check_defined, SERVER_NAME, The server FQDN for the request)
	$(PRINT_ROOT_KEY_PASS)
	$(OPENSSL) ca $(OPENSSL_ARGS) -revoke certs/$(SERVER_NAME)_cert.pem
	$(MAKE) regenerate

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
	&& $(OPENSSL) ca $(OPENSSL_ARGS) -create_serial -extensions v3_intermediate_ca -days $(CA_CERT_DAYS) -notext -md sha256 -in ../intermediate/$(CA_CSR) -out ../intermediate/$(CA_CERT)

$(CA_CHAIN):
	cat $(CA_CERT) ../root/certs/ca_cert.pem > $(CA_CHAIN)
