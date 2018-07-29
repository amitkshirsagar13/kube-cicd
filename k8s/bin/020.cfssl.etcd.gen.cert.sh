# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source isRoot.sh
source colorCode.sh

[[ ":PATH:" != *":/usr/local/bin:"* ]] && PATH="$PATH:/usr/local/bin"

echo "[ ${BLUE}WARN${NC} ] cfssl version: `cfssl version`"

# Create Certificates
etcd_certs="/etc/kubernetes/pki/etcd"
if [ -d "$etcd_certs" ]; then
    echo "[ ${GREEN}INFO${NC} ] etcd cert directory available "
else
    echo "[ ${BLUE}WARN${NC} ] creating etcd cert directory : $etcd_certs"
    mkdir -p $etcd_certs
fi

# Creating etcd master configuration certs
cd $etcd_certs

cat > ca-config.json << EOF
{
    "signing": {
        "default": {
            "expiry": "43800h"
        },
        "profiles": {
            "server": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
EOF

cat > ca-csr.json << EOF
{
    "CN": "etcd",
    "key": {
        "algo": "rsa",
        "size": 2048
    }
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca -

cat > client.json << EOF
{
    "CN": "client",
    "key": {
        "algo": "ecdsa",
        "size": 256
    }
}
EOF


echo "[ ${GREEN}INFO${NC} ] Generating client certs"

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client client.json | cfssljson -bare client

chmod 755 *.*
echo "[ ${GREEN}INFO${NC} ] `pwd && ls -ltr`"

echo "========================================================================="
scriptName=`echo $0|cut -d "/" -f2`
echo "=== [ ${GREEN}INFO${NC} ] Executing Current Script $scriptName"
echo "=== [ ${GREEN}INFO${NC} ] Next Few Scripts: 
`ls -1 |grep -A2 $scriptName`"
echo "=== [ ${GREEN}INFO${NC} ] etcd certificate generation completed                    ==="
echo "========================================================================="
