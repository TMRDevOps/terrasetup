#!/usr/bin/env bash

# install AWSCLI
    sudo apt update -y
    sudo apt install unzip wget -y
    sudo curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
    sudo apt install python -y
    sudo apt install awscli -y
    wait 5;

# install kops
    sudo wget https://github.com/kubernetes/kops/releases/download/v1.22.0/kops-linux-amd64
    sudo chmod +x kops-linux-amd64
    sudo mv kops-linux-amd64 /usr/local/bin/kops
    wait 5

# install kubectl
    sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    sudo chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl

# create S3 bucket
    s3buck="tmrs3bucket"
    aws s3 mb s3://"$s3buck";
    aws s3 ls # to verify


# copy seport commands
   
cat >> /home/kops/.bashrc << EOF
export NAME=class30.k8s.local
export KOPS_STATE_STORE=s3://class30kops
EOF

source /home/kops/.bashrc  

#Verify this by running 
#$ echo $NAME
#$ echo $KOPS_STATE_STORE

# create ssh key {in -f file with -N no passphrase}

ssh-keygen -f /home/kops/.ssh/id_rsa -q -N ""

# create cluster
# only use variables in a script


kops create cluster --zones us-east-2a --networking weave --master-size t2.medium --master-count 1 --node-size t2.micro --node-count=2 ${NAME};
wait 5
# copy the sshkey into your cluster to be able to access your kubernetes node from the kops server
kops create secret --name ${NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub;
wait 5

#update cluster

kops update cluster ${NAME} --yes



###########
#If you log out and log in run

kops export kubecfg $NAME --admin