include Makefile.help
include Makefile.functions
SHELL := /bin/bash
DIRS = certsdb certreqs crl private
FILES = index.txt
CONFIG_FILE = openssl.cnf
DEFAULT_ARGS := -config ./openssl.cnf
CA_KEY_CSR = private/cakey.pem careq.pem
INSECURE_CA_KEY = private/cakey.key_insecure
CA_CRT = cacert.pem
SERVER_FILE = server.key server.csr server.crt
OPENSSL := /usr/bin/openssl
PWGEN := /usr/bin/pwgen
SED := /bin/sed
.PHONY: setup ca server
.DEFAULT_GOAL := setup

setup: $(OPENSSL) $(DIRS) $(FILES) $(CONFIG_FILE) ##@default Creates the directory structure and needed files to manage the certificates.

ca: setup $(CA_CRT) ##@targets Creates a new certificate authority.

server: $(PWGEN) ca ##@targets Creates a new server certificate. The argument SERVER_NAME=<fqdn> must be set. Will override any existing certificates.
	$(call check_defined, SERVER_NAME, The server FQDN for the request)
	$(PWGEN) 128 1
	if [ ! -f "certreqs/$(SERVER_NAME)_req.pem" ]; then \
	$(OPENSSL) req $(DEFAULT_ARGS) -new -newkey rsa:2048 -keyout private/$(SERVER_NAME)_key.pem -out certreqs/$(SERVER_NAME)_req.pem ;\
	fi
	if [ ! -f "private/$(SERVER_NAME).key_insecure" ]; then \
	$(OPENSSL) rsa -in private/$(SERVER_NAME)_key.pem -out private/$(SERVER_NAME).key_insecure ;\
	fi
	if [ ! -f "certsdb/$(SERVER_NAME)_cert.pem" ]; then \
	$(OPENSSL) ca $(DEFAULT_ARGS) -out certsdb/$(SERVER_NAME)_cert.pem -days 365 -keyfile private/cakey.pem -extensions usr_cert -policy policy_anything -infiles certreqs/$(SERVER_NAME)_req.pem ;\
	fi

$(OPENSSL):
	sudo apt-get install -y openssl

$(PWGEN):
	sudo apt-get install -y pwgen

$(DIRS):
	mkdir -p $(DIRS)
	chmod 700 private
	
$(FILES):
	touch index.txt

$(CONFIG_FILE): $(SED)
	find /etc -name "openssl.cnf" -exec cp '{}' . \; 2>/dev/null; true
	$(SED) -i -r "s/^(dir\s*=\s*)(.*)([#.]*)/\1.\3/" openssl.cnf

$(CA_KEY_CSR):
	pwgen 128
	$(OPENSSL) req $(DEFAULT_ARGS) -new -newkey rsa:2048 -keyout private/cakey.pem -out careq.pem
	
$(INSECURE_CA_KEY): $(CA_KEY_CSR)
	$(OPENSSL) rsa -in private/cakey.pem -out private/cakey.key_insecure
	
$(CA_CRT): $(INSECURE_CA_KEY)
	$(OPENSSL) ca $(DEFAULT_ARGS) -create_serial -out cacert.pem -days 3650 -keyfile private/cakey.key_insecure -selfsign -extensions v3_ca_has_san -infiles careq.pem
