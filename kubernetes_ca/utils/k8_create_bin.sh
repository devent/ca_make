#!/bin/bash
set -x

if [ ! -f /home/erwin/tmp/kubernetes-server-linux-amd64.tar.gz ]; then
    exit 1
fi

cd /home/erwin/tmp
tar xf kubernetes-server-linux-amd64.tar.gz

sudo cp kubernetes/server/bin/kube-apiserver \
    kubernetes/server/bin/kube-controller-manager \
    kubernetes/server/bin/kube-scheduler \
    kubernetes/server/bin/kubelet \
    kubernetes/server/bin/kube-proxy \
    kubernetes/server/bin/kubectl \
    /usr/local/bin/

rm -rf kubernetes
