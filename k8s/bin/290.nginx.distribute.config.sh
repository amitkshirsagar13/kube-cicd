# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source k8s.conf
source cluster.conf

#sudo rm -f nginx.conf

echo "[ ${GREEN}INFO${NC} ] Generating nginx config file"

cp /etc/kubernetes/pki/etcd/* .

sudo /usr/local/bin/cfssl print-defaults csr |sudo tee nginx.json
sudo sed -i '0,/CN/{s/example\.net/'"$PEERNAME${SERVER_DOMAIN}"'/}' nginx.json
sudo sed -i 's/www\.example\.net/'"$PRIVATEIP"'/' nginx.json
sudo sed -i 's/example\.net/'$PEERNAME'/' nginx.json
sudo sed -i 's/ecdsa/rsa/' nginx.json
sudo sed -i 's/256/2048/' nginx.json
sudo /usr/local/bin/cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server nginx.json |sudo /usr/local/bin/cfssljson -bare nginx
chmod 666 nginx-key.pem
muser=$USER # cluster.conf USER, need to be OS user will work with only user/password login
for M in $M2 $M3; do
    host="${M}${SERVER_DOMAIN}"
    echo "[ ${GREEN}INFO${NC} ] Distributing nginx.conf to $muser@$host"
    # upload certs and distribution using scp
    sudo -S -u $USER scp nginx.conf k8m.conf nginx.pem nginx-key.pem nginx.csr $muser@$host:/tmp/
    # Execute distribution Script to move certs to right folders

    echo "[ ${BLUE}WARN${NC} ] Execute Below Set of commands :
    cd /tmp && ./291.setupNginx.sh && exit"
    sudo -S -u $USER ssh $muser@$host "sudo su - "
done

chmod 644 nginx-key.pem


helminit

sleep 10

# kubectl create namespace nginx
# kubectl create secret tls nginx-tls --namespace nginx --key /etc/pki/nginx/private/nginx-key.pem --cert /etc/pki/nginx/nginx.pem

# kubectl create clusterrolebinding nginx --clusterrole cluster-admin --serviceaccount=nginx:default

# #helm upgrade --install nginx --namespace nginx stable/nginx-ingress --set controller.service.type=NodePort --set controller.kind=daemonset --set controller.service.nodePorts.https=30443 --set controller.service.nodePorts.http=30080
# helm upgrade --install nginx --namespace nginx stable/nginx-ingress --set controller.service.type=NodePort --set controller.service.nodePorts.https=30443 --set controller.service.nodePorts.http=30080


kubectl delete namespace dev
kubectl create namespace dev
sleep 5
kubectl --namespace dev create secret tls dev-tls --key /etc/pki/nginx/private/nginx-key.pem --cert /etc/pki/nginx/nginx.pem
kubectl --namespace dev run echoserver --image=gcr.io/google_containers/echoserver:1.4 --port=8080
kubectl --namespace dev expose deployment echoserver --type=NodePort

kubectl apply -f ingress/echoserver.ingress.http.yml
kubectl apply -f ingress/echoserver.ingress.https.yml

# cafe Sample: 
kubectl delete namespace cafe
kubectl create namespace cafe
sleep 5
kubectl apply -f cafe/coffee.yaml

echo "[ ${GREEN}INFO${NC} ] http://echoserver.dev.gce.k8m.k8cluster.io:30080/"
echo "[ ${GREEN}INFO${NC} ] https://sechoserver.dev.gce.k8m.k8cluster.io:30443/"
echo "[ ${GREEN}INFO${NC} ] https://sechoserver.dev.gce.k8m.k8cluster.io/"
echo "[ ${GREEN}INFO${NC} ] https://cafe.dev.gce.k8m.k8cluster.io/"
echo "[ ${GREEN}INFO${NC} ] https://tea.dev.gce.k8m.k8cluster.io/"

source 291.setupNginx.sh


echo "========================================================================="
scriptName=`echo $0|cut -d "/" -f2`
echo "=== [ ${GREEN}INFO${NC} ] Executing Current Script $scriptName"
echo "=== [ ${GREEN}INFO${NC} ] Next Few Scripts: 
`ls -1 |grep -A2 $scriptName`"
echo "=== [ ${GREEN}INFO${NC} ] Nginx configuration distributed to Masters               ==="
echo "========================================================================="
