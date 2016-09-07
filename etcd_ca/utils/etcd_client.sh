#!/bin/bash
set -x

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized

cd "$MY_PATH"

CERTS="$HOME/certs/etcd"
CERT="client_cert.pem"
KEY="client_key_insecure.pem"
CA="ca_cert.pem"

etcdctl -C https://k8-master.muellerpublic.de:2379 \
  --cert-file "$CERTS/$CERT" \
  --key-file "$CERTS/$KEY" \
  --ca-file "$CERTS/$CA" \
  --debug \
  $@
