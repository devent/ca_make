# Include utilities.
include ../utils/Makefile.functions
include ../utils/Makefile.help
include ../utils/Makefile.ca
# Misc.
SHELL := /bin/bash
CA_CERT_DAYS := 3650
OPENSSL_ARGS := -config ./openssl.cnf
# Files and directories.
DIRS := certs csr crl newcerts private passwords
FILES := index.txt
SERIAL := serial
CONFIG_FILE := openssl.cnf
ROOT_KEY := private/ca_key.pem
ROOT_KEY_INSECURE := private/ca_key_insecure.pem
CA_CERT := certs/ca_cert.pem
CA_CSR := csr/ca_csr.pem
CA_CERT := certs/ca_cert.pem
CA_CHAIN := certs/ca_chain_cert.pem
CRL_FILE := crl/k8s_crl.pem
# API Server certificate.
SERVER_KEY := private/server_key.pem
SERVER_KEY_INSECURE := private/server_key_insecure.pem
SERVER_CERT := certs/server_cert.pem
SERVER_CSR := csr/server_csr.pem
SERVER_CERT_DAYS := 365
USER_CERT_DAYS := 30
# Worker certificate.
WORKER_CERT_DAYS := 365
# Tools.
OPENSSL := /usr/bin/openssl
PWGEN := /usr/bin/pwgen
# Makefile.
.DEFAULT_GOAL := run

run: ca server ##@default Creates the root certificate authority.
.PHONY: run

setup: $(OPENSSL) $(DIRS) $(FILES)
.PHONY: setup

ca: setup $(ROOT_KEY) $(CA_CSR) $(CA_CERT) $(CA_CHAIN) $(SERIAL) $(CRL_NUMBER) ##@targets Creates a new root certificate authority.
.PHONY: ca

server: $(SERVER_KEY) $(SERVER_CSR) $(SERVER_CERT) ##@targets Creates a new API server certificate.
.PHONY: server

clean: ##@targets Deletes all created directories and files.
	rm -rf $(DIRS) $(FILES) $(SERIAL) serial.old index.txt.attr index.txt.attr.old index.txt.old crlnumber
.PHONY: clean

show: ##@targets Shows the root certificate.
	$(OPENSSL) x509 -noout -text -in $(CA_CERT)
.PHONY: show

verify: ##@targets Verifies the kubernetes CA certificate against the intermediate certificate.
	set $(SET_FLAG) \
	&& current_pwd=$$PWD \
	&& cd ../intermediate \
	&& $(OPENSSL) verify -CAfile $(CA_CHAIN) "$$current_pwd/$(CA_CERT)"
.PHONY: verify

worker: ##@targets Creates a new worker certificate, needed arguments are WORKER_IP and WORKER_NAME.
	$(call check_defined, WORKER_IP, The worker IP address for the request)
	$(call check_defined, WORKER_NAME, The worker FQDN for the request)
	set $(SET_FLAG) \
	&& WORKER_KEY=private/$(WORKER_NAME)_key.pem \
	&& WORKER_KEY_INSECURE=private/$(WORKER_NAME)_key_insecure.pem \
	&& WORKER_CSR=csr/$(WORKER_NAME)_csr.pem \
	&& WORKER_CERT=certs/$(WORKER_NAME)_cert.pem \
	&& WORKER_KEY_PASS="passwords/`basename $$WORKER_KEY`.txt" \
	&& $(PWGEN) 128 1 > "$$WORKER_KEY_PASS" \
	&& $(call printInfo2, "$$WORKER_KEY_PASS: `cat $$WORKER_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $$WORKER_KEY $(SERVER_KEY_SIZE) \
	&& $(OPENSSL) rsa -in $$WORKER_KEY -out $$WORKER_KEY_INSECURE \
	&& WORKER_IP=$(WORKER_IP) $(OPENSSL) req -config ./openssl_worker.cnf -key $$WORKER_KEY_INSECURE -new -sha256 -out $$WORKER_CSR -subj "/CN=$(WORKER_NAME)" \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& WORKER_IP=$(WORKER_IP) $(OPENSSL) ca -config ./openssl_worker.cnf -create_serial -extensions v3_req -days $(WORKER_CERT_DAYS) -notext -md sha256 -in $$WORKER_CSR -out $$WORKER_CERT
.PHONY: worker

user: ##@targets Creates a new user certificate, needed arguments are USER_NAME.
	$(call check_defined, USER_NAME, The user name)
	set $(SET_FLAG) \
	&& USER_KEY=private/$(USER_NAME)_key.pem \
	&& USER_KEY_INSECURE=private/$(USER_NAME)_key_insecure.pem \
	&& USER_CSR=csr/$(USER_NAME)_csr.pem \
	&& USER_CERT=certs/$(USER_NAME)_cert.pem \
	&& USER_KEY_PASS="passwords/`basename $$USER_KEY`.txt" \
	&& $(PWGEN) 128 1 > "$$USER_KEY_PASS" \
	&& $(call printInfo2, "$$USER_KEY_PASS: `cat $$USER_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $$USER_KEY $(SERVER_KEY_SIZE) \
	&& $(OPENSSL) rsa -in $$USER_KEY -out $$USER_KEY_INSECURE \
	&& $(OPENSSL) req -config ./openssl_user.cnf -key $$USER_KEY_INSECURE -new -sha256 -out $$USER_CSR -subj "/CN=$(USER_NAME)" \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& $(OPENSSL) ca -config ./openssl_user.cnf -create_serial -extensions v3_req -days $(USER_CERT_DAYS) -notext -md sha256 -in $$USER_CSR -out $$USER_CERT \
	&& $(call printInfo2, "$$USER_KEY_PASS: `cat $$USER_KEY_PASS`") \
	&& $(OPENSSL) pkcs12 -export -inkey $$USER_KEY -in $$USER_CERT -certfile $(CA_CHAIN) -out private/$$USER_KEY.pfx
.PHONY: user

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
	&& $(OPENSSL) genrsa -aes256 -out $(ROOT_KEY) $(ROOT_KEY_SIZE) \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) rsa -in $(ROOT_KEY) -out $(ROOT_KEY_INSECURE)

$(CA_CSR):
	$(PRINT_ROOT_KEY_PASS)
	$(call printWarn, Common name must be 'kube-ca')
	$(OPENSSL) req -config ./openssl_ca.cnf -new -sha256 -extensions v3_ca -key $(ROOT_KEY) -out $(CA_CSR)

$(CA_CERT):
	set $(SET_FLAG) \
	&& cd ../intermediate \
	&& ROOT_KEY_PASS="passwords/intermediate_key.pem.txt" \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) ca $(OPENSSL_ARGS) -create_serial -extensions v3_intermediate_ca -days $(CA_CERT_DAYS) -notext -md sha256 -in ../kubernetes_ca/$(CA_CSR) -out ../kubernetes_ca/$(CA_CERT)

$(SERVER_KEY):
	set $(SET_FLAG) \
	&& SERVER_KEY_PASS="passwords/`basename $(SERVER_KEY)`.txt" \
	&& $(PWGEN) 128 1 > "$$SERVER_KEY_PASS" \
	&& $(call printInfo2, "$$SERVER_KEY_PASS: `cat $$SERVER_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $(SERVER_KEY) $(SERVER_KEY_SIZE) \
	&& $(call printInfo2, "$$SERVER_KEY_PASS: `cat $$SERVER_KEY_PASS`") \
	&& $(OPENSSL) rsa -in $(SERVER_KEY) -out $(SERVER_KEY_INSECURE)

$(SERVER_CSR):
	set $(SET_FLAG) \
	&& $(OPENSSL) req -config openssl_server.cnf -new -key $(SERVER_KEY_INSECURE) -out $(SERVER_CSR) -subj "/CN=kube-apiserver"

$(SERVER_CERT):
	set $(SET_FLAG) \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& $(OPENSSL) ca -config ./openssl_server.cnf -create_serial -extensions v3_req -days $(SERVER_CERT_DAYS) -notext -md sha256 -in $(SERVER_CSR) -out $(SERVER_CERT)

$(CA_CHAIN):
	cat $(CA_CERT) ../intermediate/certs/intermediate_cert.pem ../root/certs/ca_cert.pem > $(CA_CHAIN)
