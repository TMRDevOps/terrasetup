#!/bin/bash
#1) make sure to run as root

    sudo hostnamectl set-hostname  master

#2) Disable swap & add kernel settings

    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


#3) Add  kernel settings & Enable IP tables(CNI Prerequisites)

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

#4) Install containerd run time

    apt-get update -y
    apt-get install ca-certificates curl gnupg lsb-release -y

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install containerd

    apt-get update -y
    apt-get install containerd.io -y

    containerd config default > /etc/containerd/config.toml



    sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

    systemctl restart containerd
    systemctl enable containerd



#5) Installing kubeadm, kubelet and kubectl
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl

    # Download the Google Cloud public signing key:

    curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

    # Add the Kubernetes apt repository:

    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    # Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:

    apt-get update
    apt-get install -y kubelet kubeadm kubectl

    # apt-mark hold will prevent the package from being automatically upgraded or removed.

    apt-mark hold kubelet kubeadm kubectl

    # Enable and start kubelet service

    systemctl daemon-reload
    systemctl start kubelet
    systemctl enable kubelet.service
