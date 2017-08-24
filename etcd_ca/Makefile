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
ROOT_KEY := private/etcd_key.pem
CA_CSR := csr/etcd_csr.pem
CA_CERT := certs/etcd_cert.pem
CA_CHAIN := certs/ca_chain_cert.pem
CRL_FILE := crl/etcd_crl.pem
# Makefile.
.DEFAULT_GOAL := run

run: ca ##@default Creates the etcd certificate authority.
.PHONY: run

setup: $(OPENSSL) $(DIRS) $(FILES)
.PHONY: setup

ca: setup $(ROOT_KEY) $(CA_CSR) $(CA_CERT) $(CA_CHAIN) $(SERIAL) $(CRL_NUMBER) ##@targets Creates a new etcd certificate authority.
.PHONY: ca

clean: ##@targets Deletes all created directories and files.
	rm -rf $(DIRS) $(FILES) $(SERIAL) index.txt.attr index.txt.attr.old index.txt.old crlnumber *.old
.PHONY: clean

show: ##@targets Shows the etcd certificate.
	$(OPENSSL) x509 -noout -text -in $(CA_CERT)
.PHONY: show

verify: ##@targets Verifies the etcd CA certificate against the intermediate certificate.
	set $(SET_FLAG) \
	&& current_pwd=$$PWD \
	&& cd ../intermediate \
	&& $(OPENSSL) verify -CAfile certs/ca_chain_cert.pem "$$current_pwd/$(CA_CERT)"
.PHONY: verify

regenerate: ##@targets Regenerates the certificate revocation list.
	$(PRINT_ROOT_KEY_PASS)
	$(OPENSSL) ca $(OPENSSL_ARGS) -gencrl -out $(CRL_FILE)
.PHONY: regenerate

show-crl: ##@targets Shows the certificate revocation list.
	$(OPENSSL) crl -in $(CRL_FILE) -noout -text
.PHONY: show-crl

server: ##@targets Creates a new server certificate. Needed arguments SERVER_NAME. Optional arguments are ETCD_SAN. Example: make server SERVER_NAME=robobee-test.test ETCD_SAN=IP:192.168.56.200
	set $(SET_FLAG) \
	&& ETCD_SAN="$(ETCD_SAN)" \
	&& if [ -z "$$ETCD_SAN" ]; then $(call printInfo1, "No SANs set in ETCD_SAN"); fi \
	&& $(MAKE) _create_key \
	&& $(MAKE) _create_crt
	set $(SET_FLAG) \
	&& ETCD_SAN="$(ETCD_SAN)" \
	&& $(SERVER_ARGS) \
	&& $(call printInfo1, Signing $$SERVER_CSR...) \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& $(OPENSSL) ca $(OPENSSL_ARGS) -create_serial -extensions etcd_server -days $(SERVER_CERT_DAYS) -notext -md sha256 -in $$SERVER_CSR -out $$SERVER_CERT
.PHONY: server

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
.PHONY: client

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
	&& $(OPENSSL) genrsa -aes256 -out $(ROOT_KEY) $(ROOT_KEY_SIZE)

$(CA_CSR):
	$(PRINT_ROOT_KEY_PASS)
	$(call printInfo1, "Default values can be used.")
	$(OPENSSL) req $(OPENSSL_ARGS) -new -sha256 -key $(ROOT_KEY) -out $(CA_CSR)

$(CA_CERT):
	set $(SET_FLAG) \
	&& cd ../intermediate \
	&& ROOT_KEY_PASS="passwords/intermediate_key.pem.txt" \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) ca $(OPENSSL_ARGS) -create_serial -extensions v3_intermediate_ca -days $(CHILD_CA_CERT_DAYS) -notext -md sha256 -in ../etcd_ca/$(CA_CSR) -out ../etcd_ca/$(CA_CERT)

$(CA_CHAIN):
	cat $(CA_CERT) ../intermediate/certs/intermediate_cert.pem ../root/certs/ca_cert.pem > $(CA_CHAIN)
