# Copyright Amit Kshirsagar - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Amit Kshirsagar <amit.kshirsagar.13@gmail.com>, Jul, 2018
# https://github.com/amitkshirsagar13/kube-cicd

#!/bin/bash
source isRoot.sh
source colorCode.sh

# Check Root access
echo "Checking if user is root"

if [[ $EUID -ne 0 ]]; then
    echo "[ ${RED}ERROR${NC} ] This script must be run as root" 
    exit 1
else
    echo "[ ${GREEN}INFO${NC} ] Running setup as Root"
fi
echo ""

# Turn off selinux
is_selinux_enabled=`getenforce`
echo "[ ${GREEN}INFO${NC} ] SELinux status is: $is_selinux_enabled"
if [[ $is_selinux_enabled -eq "Permissive" ]]; then
    echo "[ ${GREEN}INFO${NC} ] SELinux is already Disabled"
else
    echo "[ ${BLUE}WARN${NC} ] Disabling SELinux"
    setenforce 0
fi

selinux=`cat /etc/sysconfig/selinux |grep SELINUX=disabled|wc -l`
if [[ $selinux -ne 0 ]]; then
    echo "[ ${BLUE}WARN${NC} ] Turning off SELinux Policy" 
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
else
    echo "[ ${GREEN}INFO${NC} ] SELinux policy already turned off"
fi

echo ""
# Turn off swap
is_swap_off=`cat /proc/swaps|grep -e partition -e file|wc -l`
if [[ $is_swap_off -eq 0 ]]; then
    echo "[ ${GREEN}INFO${NC} ] Swap already off" 
else
    echo "[ ${BLUE}WARN${NC} ] SELinux policy already turned off"
    swapoff -a
fi

echo ""
# Configure iptables
is_iptables_configuBLUE=`iptables -S|grep FORWARD|grep DROP|wc -l`
if [[ $is_iptables_configuBLUE -eq 0 ]]; then
    echo "[ ${GREEN}INFO${NC} ] iptables configuration is not requiBLUE" 
else
    echo "[ ${BLUE}WARN${NC} ] Configuring iptables FORWARD policy"
    iptables -P FORWARD ACCEPT
fi

if [ -x "$(command -v wget)" ]; then
    echo "[ ${GREEN}INFO${NC} ] wget already installed"
    echo "[ ${GREEN}INFO${NC} ] ${BLUE}`wget --version`${NC}"
else
    yum install -y wget
fi

echo "========================================================================="
echo "=== [ ${GREEN}INFO${NC} ] Precheck completed successfully                          ==="
echo "========================================================================="

