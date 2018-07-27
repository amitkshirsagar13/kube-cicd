# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source cluster.conf
source k8s.conf

hostIP=`hostname -i`

cat > kubeadm-primary-cfg.yml <<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
kubernetesVersion: ${K8S_VERSION}
api:
  advertiseAddress: ${hostIP}
etcd:
  endpoints:
  - https://${MASTER_IP1}:2379
  - https://${MASTER_IP2}:2379
  - https://${MASTER_IP3}:2379
  caFile: /etc/kubernetes/pki/etcd/ca.pem
  certFile: /etc/kubernetes/pki/etcd/client.pem
  keyFile: /etc/kubernetes/pki/etcd/client-key.pem
networking:
  podSubnet: ${CLUSTER_CIDR}
apiServerCertSANs:
- ${LB}
- ${MASTER_IP1}
- ${MASTER_IP2}
- ${MASTER_IP3}
- ${M1}
- ${M2}
- ${M3}
- ${M1}${SERVER_DOMAIN}
- ${M2}${SERVER_DOMAIN}
- ${M3}${SERVER_DOMAIN}
- 127.0.0.1
apiServerExtraArgs:
  endpoint-reconciler-type: lease

EOF

kubeadm init --config=kubeadm-primary-cfg.yml

sudo rm -Rf $HOME/.kube
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf


current=`pwd`
kubeCerts="/etc/kubernetes/pki"
cd $kubeCerts
sudo chmod 755 ca.crt [cs]a.key sa.pub

echo "[ ${GREEN}INFO${NC} ] Distribute Kubernetes Certs"
if [ -e /tmp/distributeMasterCerts.sh ]; then
  sudo rm -f /tmp/distributeMasterCerts.sh
fi

cat > /tmp/distributeMasterCerts.sh <<EOF
#!/bin/bash
cd /tmp
kubeCerts="/etc/kubernetes/pki"
if [ -d "$kubeCerts" ]; then
    sudo mkdir -p $kubeCerts
fi
sudo mv ca.crt $kubeCerts
sudo mv [cs]a.key $kubeCerts
sudo mv sa.pub $kubeCerts

EOF


muser=$USER # cluster.conf USER, need to be OS user will work with only user/password login
for M in $M2 $M3; do
    host="${M}${SERVER_DOMAIN}"
    echo "[ ${GREEN}INFO${NC} ] Distributing kubernetes certs to $muser@$host"
    # upload certs and distribution using scp
    sudo -S -u $USER scp ca.crt [cs]a.key sa.pub /tmp/distributeMasterCerts.sh $muser@$host:/tmp/
    # Execute distribution Script to move certs to right folders
    echo "[ ${BLUE}WARN${NC} ] Execute Below Set of commands :
    cd /tmp && chmod 777 distributeMasterCerts.sh && ./distributeMasterCerts.sh && ./111.setupSecondaryMaster.sh && exit"
    
    sudo -S -u $USER ssh $muser@$host "sudo su - "
done

helminit

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Kubernetes Primary Master setup completed                ==="
echo "========================================================================="
