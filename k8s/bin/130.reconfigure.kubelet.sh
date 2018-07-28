# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source colorCode.sh
source k8s.conf
source cluster.conf

MASTERFQDN="${M1}${SERVER_DOMAIN}"
echo "[ ${GREEN}INFO${NC} ] Primary Master ${MASTERFQDN}"
sudo cp /etc/kubernetes/kubelet.conf /etc/kubelet.conf.orig
sudo sed -i "s|server:.*|server: https://${MASTERFQDN}:$LB_PORT|g" /etc/kubernetes/kubelet.conf
sudo systemctl restart kubelet && sudo systemctl status kubelet

cat > /tmp/reconfigure.kubelet.sh << EOF
#!/bin/bash
source colorCode.sh
source k8s.conf
source cluster.conf

MASTERFQDN="${M1}${SERVER_DOMAIN}"
echo "[ ${GREEN}INFO${NC} ] Primary Master ${MASTERFQDN}"
sudo cp /etc/kubernetes/kubelet.conf /etc/kubelet.conf.orig
sudo sed -i "s|server:.*|server: https://${MASTERFQDN}:$LB_PORT|g" /etc/kubernetes/kubelet.conf
sudo systemctl restart kubelet && sudo systemctl status kubelet
EOF

muser=$USER # cluster.conf USER, need to be OS user will work with only user/password login
for M in $M2 $M3 $W1 $W2 $W3; do
    host="${M}${SERVER_DOMAIN}"
    # upload certs and distribution using scp
    sudo -S -u $USER scp /tmp/reconfigure.kubelet.sh $muser@$host:/tmp/
    # Execute distribution Script to move certs to right folders

    echo "[ ${BLUE}WARN${NC} ] Execute Below Set of commands :
    cd /tmp && chmod 777 reconfigure.kubelet.sh && ./reconfigure.kubelet.sh && exit"
    
    sudo -S -u $USER ssh $muser@$host "sudo su - "
done


echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Reconfigure kubelet    completed                         ==="
echo "========================================================================="
