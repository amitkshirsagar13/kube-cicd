# Copyright (C) Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source cluster.conf
source k8s.conf

PEERNAME=`hostname`
PRIVATEIP=`hostname -i`

etcd_certs="/etc/kubernetes/pki/etcd"
if [ ! -f  "$etcd_certs/server.pem" ]; then
    cd $etcd_certs
    echo "[ ${BLUE}INFO${NC} ] Generating Server and peer Certs"
    sudo chmod 777 *
    sudo /usr/local/bin/cfssl print-defaults csr |sudo tee config.json
    sudo sed -i '0,/CN/{s/example\.net/'"$PEERNAME"'/}' config.json
    sudo sed -i 's/www\.example\.net/'"$PRIVATEIP"'/' config.json
    sudo sed -i 's/example\.net/'$PEERNAME'/' config.json
    sudo /usr/local/bin/cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile server config.json |sudo /usr/local/bin/cfssljson -bare server
    sudo /usr/local/bin/cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile peer config.json |sudo /usr/local/bin/cfssljson -bare peer
else
    echo "[ ${GREEN}INFO${NC} ] Server and peer Certs Available"
fi


# Download etcd
if [ ! -x "$(command -v etcdctl)" ]; then
    echo "[ ${BLUE}WARN${NC} ] Downloading etcd version $ETCD"
    DOWNLOAD_URL=${GOOGLE_URL}
    rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
    rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

    curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
    tar xzf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /usr/local/bin --strip-components=1
    rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
    rm -f /usr/local/bin/README*
    rm -Rf /usr/local/bin/Documentation
else
    echo "[ ${GREEN}INFO${NC} ] etcd version `etcdctl version`"
fi

if [ -e /etc/etcd.env ]; then
  sudo rm -f /etc/etcd.env
fi
touch /etc/etcd.env
echo "PEERNAME=$PEERNAME" >> /etc/etcd.env
echo "PRIVATEIP=$PRIVATEIP" >> /etc/etcd.env

echo "[ ${GREEN}INFO${NC} ] Setting etcd service"

mkdir -p /var/lib/etcd

cat > /etc/systemd/system/etcd.service << EOF
[UNIT]
Description=etcd
Documentation=https://github.com/coreos/etcd
Conflicts=etcd.service
Conflicts=etcd2.service

[Service]
EnvironmentFile=/etc/etcd.env
Type=notify
Restart=always
RestartSec=5s
LimitNOFILE=40000
TimeoutStartSec=0

ExecStart=/usr/local/bin/etcd --name etcd_${PEERNAME} \
    --data-dir /var/lib/etcd \
    --listen-client-urls https://${PRIVATEIP}:2379 \
    --advertise-client-urls https://${PRIVATEIP}:2379 \
    --listen-peer-urls https://${PRIVATEIP}:2380 \
    --initial-advertise-peer-urls https://${PRIVATEIP}:2380 \
    --cert-file=/etc/kubernetes/pki/etcd/server.pem \
    --key-file=/etc/kubernetes/pki/etcd/server-key.pem \
    --client-cert-auth \
    --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.pem \
    --peer-cert-file=/etc/kubernetes/pki/etcd/peer.pem \
    --peer-key-file=/etc/kubernetes/pki/etcd/peer-key.pem \
    --peer-client-cert-auth \
    --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.pem \
    --initial-cluster etcd_k8m1=https://${MASTER_IP1}:2380,etcd_k8m2=https://${MASTER_IP2}:2380,etcd_k8m3=https://${MASTER_IP3}:2380 \
    --initial-cluster-token etcd-cluster-1 \
    --initial-cluster-state new

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now etcd
systemctl status etcd

etcdctl -ca-file $etcd_certs/ca.pem --cert-file $etcd_certs/client.pem --key-file $etcd_certs/client-key.pem --endpoint https://$PRIVATEIP:2379 member list

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] etcd startup completed, verify etcdctl commands          ==="
echo "========================================================================="
