#!/bin/bash
set -e

function get_host_ip() {
    ip route get 1 | awk '{print $NF;exit}'
}

HostIP="`get_host_ip`"

docker run -d \
 -v /usr/share/ca-certificates/:/etc/ssl/certs \
 -v /var/lib/etcd:/var/lib/etcd \
 -e ETCD_DATA_DIR=/var/lib/etcd \
 -e ETCD_CERT_FILE=/etc/ssl/certs/etcd/k8-master.muellerpublic.de_cert.pem \
 -e ETCD_KEY_FILE=/etc/ssl/certs/etcd/k8-master.muellerpublic.de_key_insecure.pem \
 -e ETCD_CA_FILE=/etc/ssl/certs/etcd/ca_cert.pem \
 -e ETCD_TRUSTED_CA_FILE=/etc/ssl/certs/etcd/ca_cert.pem \
 -e ETCD_CLIENT_CERT_AUTH=true \
 -e ETCD_PEER_CERT_FILE=/etc/ssl/certs/etcd/k8-master.muellerpublic.de_cert.pem \
 -e ETCD_PEER_KEY_FILE=/etc/ssl/certs/etcd/k8-master.muellerpublic.de_key_insecure.pem \
 -e ETCD_PEER_CLIENT_CERT_AUTH=true \
 -p 4001:4001 -p 2380:2380 -p 2379:2379 \
 --restart unless-stopped \
 --name etcd0 \
 quay.io/coreos/etcd etcd \
 -name etcd0 \
 -advertise-client-urls https://${HostIP}:2379,https://${HostIP}:4001 \
 -listen-client-urls https://0.0.0.0:2379,https://0.0.0.0:4001 \
 -initial-advertise-peer-urls https://${HostIP}:2380 \
 -listen-peer-urls https://0.0.0.0:2380 \
 -initial-cluster-token etcd-cluster-1 \
 -initial-cluster etcd0=https://${HostIP}:2380 \
 -initial-cluster-state new
