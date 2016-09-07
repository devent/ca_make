#!/bin/bash
set -e

openssl s_client \
    -cert ~/certs/etcd/k8-master.muellerpublic.de_cert.pem \
    -key ~/certs/etcd/k8-master.muellerpublic.de_key_insecure.pem \
    -CAfile ~/certs/etcd/ca_cert.pem \
    -connect localhost:2379
