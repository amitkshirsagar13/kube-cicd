```sudo kubeadm reset
ifconfig|grep flannel
sudo ip link del flannel.1
sudo kubeadm init --apiserver-advertise-address=192.168.1.123 --pod-network-cidr=10.244.0.0/16
sudo rm -f $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl apply -f jenkins/jenkins.deployment.yaml
```
