# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source k8s.conf
source cluster.conf

#kubeadm join --token `cat cluster-token` ${MASTER_IP1}:6443 --discovery-token-ca-cert-hash sha256:`cat discovery-hash`
source worker-command

echo "========================================================================="
scriptName=`echo $0|cut -d "/" -f2`
echo "=== [ ${GREEN}INFO${NC} ] Executing Current Script $scriptName"
echo "=== [ ${GREEN}INFO${NC} ] Next Few Scripts: 
`ls -1 |grep -A2 $scriptName`"
echo "=== [ ${GREEN}INFO${NC} ] Kubernetes cluster joined by worker                      ==="
echo "========================================================================="
