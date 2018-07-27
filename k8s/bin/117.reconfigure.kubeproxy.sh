# Copyright (C) Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source k8s.conf
source cluster.conf

MASTERFQDN="${M1}${SERVER_DOMAIN}"
echo "[ ${GREEN}INFO${NC} ] Primary Master ${KMASTERFQDN}"

kubectl get configmap -n kube-system kube-proxy -o yaml > kube-proxy-cm.yaml

cp kube-proxy-cm.yaml kube-proxy-cm.yaml.orig
sed -i "s|server:.*|server: https://${KMASTERFQDN}:$LB_PORT|g" kube-proxy-cm.yaml

kubectl apply -f kube-proxy-cm.yaml --force
sleep 2

# Restart kube-proxy pods with updated configmap
kubectl delete pod -n kube-system -l k8s-app=kube-proxy


echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Reconfigure kube-proxy completed                         ==="
echo "========================================================================="
