# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source isRoot.sh
source colorCode.sh
source cluster.conf

# Distribute Certificates
current=`pwd`
etcd_certs="/etc/kubernetes/pki/etcd"

if [ -d  "$etcd_certs" ]; then
    echo "[ ${GREEN}INFO${NC} ] etcd cert directory available "
else
    echo "[ ${RED}ERROR${NC} ] etcd cert directory missing: $etcd_certs"
    exit 1
fi

cd $etcd_certs

if [ -e /tmp/distributeEtcdCerts.sh ]; then
    rm -f /tmp/distributeEtcdCerts.sh
fi

echo "[ ${GREEN}INFO${NC} ] Start etcd cert distribution "
chmod 777 -R /tmp

cat > /tmp/distributeEtcdCerts.sh << EOF 
#!/bin/bash
cd /tmp
etcd_certs="/etc/kubernetes/pki/etcd"
if [ ! -d "$etcd_certs" ]; then
    sudo mkdir -p $etcd_certs
fi

# Copy Certs

sudo mv ca.pem $etcd_certs
sudo mv ca-key.pem $etcd_certs
sudo mv client.pem $etcd_certs
sudo mv client-key.pem $etcd_certs
sudo mv ca-config.json $etcd_certs

EOF

sudo -S -u $USER whoami
muser=$USER # cluster.conf USER, need to be OS user will work with only user/password login
for M in $M2 $M3; do
    host="${M}${SERVER_DOMAIN}"
    echo "[ ${GREEN}INFO${NC} ] Distributing cert to $muser@$host"
    # upload certs and distribution using scp
    sudo -S -u $USER scp ca.pem ca-key.pem client.pem client-key.pem ca-config.json /tmp/distributeEtcdCerts.sh $current/* $muser@$host:/tmp/
    # Execute distribution Script to move certs to right folders
    echo "[ ${BLUE}WARN${NC} ] Execute Below Set of commands :
    cd /tmp && chmod 777 *.sh && ./000.precheck.sh && ./010.k8s.installation.sh && ./distributeEtcdCerts.sh && ./031.etcd.start.sh && exit"
    sudo -S -u $USER ssh $muser@$host "sudo su - "
done

cd $current
source 031.etcd.start.sh

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] etcd certificate distribution completed                  ==="
echo "========================================================================="
