#!/bin/bash
#
## Este es un script para instalar kubernetes con containerd solo para generic/ubuntu20.04
#
## !IMPORTANTE ##
#
# Antes de correr el script asegurese de actualizar los paquetes del sistema operativo 
# sudo apt update
# sudo apt -y upgrade && sudo systemctl reboot

sudo apt update -qq -y
sudo apt install toilet figlet -y
#toilet -f smblock --filter border:metal "KUBERNETES"

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

systemctl disable --now ufw

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
sysctl --system

sudo apt install -qq -y curl git gnupg2 apt-transport-https ca-certificates software-properties-common containerd
sudo apt-mark hold containerd
sudo mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update -qq

sudo apt install -qq -y kubeadm=1.21.0-00 kubelet=1.21.0-00 kubectl=1.21.0-00
#sudo apt install -qq -y kubeadm kubelet kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet

sudo sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
sudo systemctl reload sshd

echo -e "kubeadmin\nkubeadmin" | passwd root
echo "export TERM=xterm" >> /etc/bash.bashrc

hostnamectl set-hostname kanban-m01
hostname -i | cut -c1-13
IPA=$(hostname -i | cut -c1-13)
PC=$(hostname -f)
#echo -e "${IPA}\t${HOSTNAME}" >> /etc/hosts
cat >>/etc/hosts<<EOF
172.31.34.201 kanban-m01
172.31.34.202 kanban-m02
172.31.34.101 kanban-w01
172.31.34.102 kanban-w02
EOF

#printf "           ${G}*** ${B}INSTALACION DE KUBERNETES MASTER ${G}***${NC}\n"

#printf "${B}[TAREA 11]${NC} Descargando los contenedores requeridos\n"
sudo kubeadm config images pull

#printf "${B}[TAREA 12]${NC} Inicializacion del Cluster de Kubernetes\n"
sudo kubeadm init --apiserver-advertise-address=${IPA} --pod-network-cidr=10.244.0.0/16 >> /root/kubeinit.log
cat /root/kubeinit.log | grep initialized
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

#printf "${B}[TAREA 13]${NC} Despliegue de la Red Frannel\n"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#printf "${B}[TAREA 14]${NC} Generar TOKEN y salvar en un script para unir nodos (workers) al cluster /joincluster.sh\n"
kubeadm token create --print-join-command > /joincluster.sh

#printf "${B}[TAREA 15]${NC} Estado de los servicios de Kubernetes\n"
#printf "${P}Servicio Containerd${NC}\n"
systemctl status containerd |grep Active
#printf "${P}Servicio Kuebelet${NC}\n"
systemctl status kubelet | grep Active

#printf "${B}[TAREA 16]${NC} Informacion del estado del cluster K8s\n\n"
#printf "${Y}Estado del Cluster K8s${NC}\n"
sudo cp -a /etc/kubernetes/manifests/kube-controller-manager.yaml .
sudo cp -a /etc/kubernetes/manifests/kube-scheduler.yaml .
sudo sed -i '26d' /etc/kubernetes/manifests/kube-controller-manager.yaml
sudo sed -i '19d' /etc/kubernetes/manifests/kube-scheduler.yaml
sudo systemctl restart kubelet.service
sleep 40
kubectl get componentstatus
printf "${Y}Estado de los Nodos${NC}\n"
kubectl get nodes
printf "${Y}Estado de los PODs${NC}\n"
#kubectl get pod -n kube-system -o wide
sleep 50
kubectl get all -A -o wide
