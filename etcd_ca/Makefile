# Include utilities.
include ../utils/Makefile.help
include ../utils/Makefile.functions
# Misc.
SHELL := /bin/bash
CA_CERT_DAYS := 7300
# Files and directories.
DIRS := certs csr crl newcerts private passwords
FILES := index.txt
SERIAL := serial
CONFIG_FILE := openssl.cnf
ROOT_KEY := private/ca_key.pem
ROOT_KEY_INSECURE := private/ca_key_insecure.pem
CA_CERT := certs/ca_cert.pem
# Server certificate.
SERVER_CERT_DAYS := 3650
# Client certificate.
CLIENT_CERT_DAYS := 3650
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
	rm -rf $(DIRS) $(FILES) $(SERIAL) serial.old index.txt.attr index.txt.attr.old index.txt.old crlnumber

show: ##@targets Shows the root certificate.
	$(OPENSSL) x509 -noout -text -in $(CA_CERT)

server: ##@targets Creates a new etcd server certificate, needed arguments are ETCD_SAN and ETCD_NAME.
	$(call check_defined, ETCD_SAN, The server SAN IP address(es) for the request)
	$(call check_defined, ETCD_NAME, The server FQDN for the request)
	set $(SET_FLAG) \
	&& $(call ETCD_VARS,$(ETCD_NAME)) \
	&& $(PWGEN) 128 1 > "$$ETCD_KEY_PASS" \
	&& $(call printInfo2, "$$ETCD_KEY_PASS: `cat $$ETCD_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $$ETCD_KEY 2048 \
	&& $(OPENSSL) rsa -in $$ETCD_KEY -out $$ETCD_KEY_INSECURE \
	&& $(call printWarn, "Common name must be: $(ETCD_NAME)") \
	&& ETCD_SAN="$(ETCD_SAN)" $(OPENSSL) req -config ./openssl.cnf -key $$ETCD_KEY_INSECURE -new -sha256 -out $$ETCD_CSR \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& ETCD_SAN="$(ETCD_SAN)" $(OPENSSL) ca -config ./openssl.cnf -create_serial -extensions etcd_server -days $(SERVER_CERT_DAYS) -notext -md sha256 -in $$ETCD_CSR -out $$ETCD_CERT

client: ##@targets Creates a new etcd client certificate.
	set $(SET_FLAG) \
	&& $(call ETCD_VARS,client) \
	&& $(PWGEN) 128 1 > "$$ETCD_KEY_PASS" \
	&& $(call printInfo2, "$$ETCD_KEY_PASS: `cat $$ETCD_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $$ETCD_KEY 2048 \
	&& $(OPENSSL) rsa -in $$ETCD_KEY -out $$ETCD_KEY_INSECURE \
	&& ETCD_SAN="$(ETCD_SAN)" $(OPENSSL) req -config ./openssl.cnf -key $$ETCD_KEY_INSECURE -new -sha256 -out $$ETCD_CSR -subj "/CN=etcd-client" \
	&& $(PRINT_ROOT_KEY_PASS) \
	&& ETCD_SAN="$(ETCD_SAN)" $(OPENSSL) ca -config ./openssl.cnf -create_serial -extensions etcd_client -days $(CLIENT_CERT_DAYS) -notext -md sha256 -in $$ETCD_CSR -out $$ETCD_CERT

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
	&& $(PWGEN) 128 1 > "$$ROOT_KEY_PASS" \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) genrsa -aes256 -out $(ROOT_KEY) 4096 \
	&& $(call printInfo2, "$$ROOT_KEY_PASS: `cat $$ROOT_KEY_PASS`") \
	&& $(OPENSSL) rsa -in $(ROOT_KEY) -out $(ROOT_KEY_INSECURE)

$(CA_CERT):
	set $(SET_FLAG) \
	&& $(OPENSSL) req -config ./openssl.cnf -key $(ROOT_KEY) -new -x509 -days $(CA_CERT_DAYS) -sha256 -extensions v3_ca -out $(CA_CERT)
	
# Sets the certificate variables.
#
# Params:
#   1. The server name.
define ETCD_VARS =
ETCD_KEY=private/$(1)_key.pem \
&& ETCD_KEY_INSECURE=private/$(1)_key_insecure.pem \
&& ETCD_CSR=csr/$(1)_csr.pem \
&& ETCD_CERT=certs/$(1)_cert.pem \
&& ETCD_KEY_PASS="passwords/`basename $$ETCD_KEY`.txt" \
&& if [ -f "$$ETCD_KEY" -a -f "$$ETCD_CERT" ]; then \
$(call printError, $$ETCD_CERT already exists.) \
&& exit 1; fi
endef
