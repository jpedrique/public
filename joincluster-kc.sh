#!/bin/bash

sed -i '/swap/d' /etc/fstab
swapoff -a
systemctl disable --now ufw >/dev/null 2>&1
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1
apt update -qq >/dev/null 2>&1
apt install -qq -y containerd apt-transport-https >/dev/null 2>&1
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1
apt install -qq -y kubeadm=1.21.0-00 kubelet=1.21.0-00 kubectl=1.21.0-00 >/dev/null 2>&1
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc
#hostnamectl set-hostname kanban-w01
hostname -i | cut -c1-13
IPA=$(hostname -i | cut -c1-13)
echo -e "${IPA}\t${HOSTNAME}" >> /etc/hosts
cat >>/etc/hosts<<EOF
172.31.34.201 kanban-m01
172.31.34.202 kanban-m02
172.31.34.101 kanban-w01
172.31.34.102 kanban-w02
EOF
kubeadm join 172.31.34.201:6443 --token p7c264.z9xm4y2czg72ki8r \
        --discovery-token-ca-cert-hash sha256:00bd7dad2d30130045088d8a10fb03745869e64a76a07b1242b3a23c505d1a93
