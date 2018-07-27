# Copyright (C) Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source isRoot.sh
source colorCode.sh
source cluster.conf

if [ "$#" -ne 1 ]; then
    echo "[ ${RED}ERROR${NC} ] Usage: $0 master|backup"
    exite 1
fi

node=$1

case "$input" in
    master) STATE="MASTER" ;;
    backup) STATE="BACKUP" ;;
    *) STATE="" ;;
esac

if [[ -z "$STATE" ]]; then
    echo "[ ${RED}ERROR${NC} ] 20 Usage: $0 master|backup"
    exite 1
else
    if [ $STATE = "MASTER" ]; then
        PRIORITY="101"
    else
        PRIORITY="100"
    fi
fi

echo "[ ${GREEN}INFO${NC} ] $STATE $PRIORITY"

# cleanup existing configuration
if [ -e /tmp/alive.conf ]; then
    rm -f /tmp/alive.conf
    rm -f /tmp/apiserver_check.conf
fi

echo "[ ${GREEN}INFO${NC} ] Generate health check script and configuration"
cat > /tmp/apiserver_check.sh << EOF
#!/bin/bash
RED=`tput setaf 1`
BLUE=`tput setaf 4`
GREEN=`tput setaf 2`
NC=`tput setaf 7` # No Color


errorLog() {
    echo "[ ${RED}ERROR${NC} ] Generate health check script" 1>&2
    exit 1
}
curl --silent --max-time 3 --insecure https://localhost:6443/ -0 /dev/null || errorLog "Error GET https://localhost:6443"
LBCOUNT=`ip addr|grep $LB|wc -l`
if [ $LBCOUNT = 0 ]; then
    curl --silent --max-time 3 --insecure https://$LB:6443/ -0 /dev/null || errorLog "Error GET https://$LB:6443"
fi

EOF

cat > /tmp/alive.conf << EOF
global_defs {
    router_id LVS_DEVEL
}

vrrp_script apiserver_check {
    script "/etc/keepalived/apiserver_check.sh"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state ${STATE}
    interface ${INTERFACE}
    virtual_router_id 33
    priority ${PRIORITY}
    virtual_ipaddress {
        ${LB}
    }
    track_script {
        chk_nginx
    }
}
EOF

# Install Keepalived
yum install -y keepalived

mv /tmp/alive.conf /etc/keepalived/alive.conf
mv /tmp/apiserver_check.sh /etc/keepalived/apiserver_check.sh 
chmod 755 /etc/keepalived/apiserver_check.sh 

systemctl enable keepalived && systemctl start keepalived && systemctl status keepalived

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] VIP configuration completed                              ==="
echo "========================================================================="
