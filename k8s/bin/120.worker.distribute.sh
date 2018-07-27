# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source k8s.conf
source cluster.conf

current=`pwd`
echo `kubeadm token create --print-join-command` > worker-command
touch cluster-token
touch discovery-hash


muser=$USER # cluster.conf USER, need to be OS user will work with only user/password login
for W in $W1 $W2 $W3; do
    host="${W}${SERVER_DOMAIN}"
    echo "[ ${GREEN}INFO${NC} ] Joining Worker $muser@$host to Master Cluster from $current"
    # upload join-command using scp
    sudo -S -u $USER scp cluster-token discovery-hash worker-command $current/* $muser@$host:/tmp/
    # Execute distribution Script to move certs to right folders
    echo "[ ${BLUE}WARN${NC} ] Execute Below Set of commands :
    cd /tmp && chmod 777 * && ./000.precheck.sh && ./010.k8s.installation.sh && ./121.setupWorker.sh && exit"
    sudo -S -u $USER ssh $muser@$host "sudo su - "
done
kubectl get nodes

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Kubernetes cluster token distributed to workers          ==="
echo "========================================================================="
