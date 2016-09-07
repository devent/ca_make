#!/bin/bash
set -x

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized

cd "$MY_PATH"

CERTS="$HOME/certs/etcd"
CERT="client_cert.pem"
KEY="client_key_insecure.pem"
CA="ca_cert.pem"

curl \
    --cacert "$CERTS/$CA" \
    --cert "$CERTS/$CERT" \
    --key "$CERTS/$KEY" \
    https://k8-master.muellerpublic.de:2379/v2/stats/self
