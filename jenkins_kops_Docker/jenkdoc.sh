#!/usr/bin/env bash

# update package
    sudo apt-get update
    sudo apt-get install -y wget
    sudo apt install -y net-tools
    sudo apt-get install -y tree
    sudo apt-get install -y git
    wait 5

#hostname
    sudo hostnamectl set-hostname jenkins


#install and run apache2   
    #sudo apt install -y apache2
    #sudo systemctl start apache2

#TMR Repo Setup
    mkdir /home/jenkins/setup || exit
    cd /home/jenkins/setup || exit
    sudo git init
    sudo git clone https://github.com/TMRDevOps/terrasetup.git
    sudo chmod 777 -R /home/jenkins/setup/
    sudo chmod 777 -R /home/jenkins/setup/*
    sudo chown nobody:nogroup -R /home/jenkins/setup/*
    sudo chown nobody:nogroup -R /home/jenkins/setup/

    mkdir /home/ubuntu/setup || exit
    cd /home/ubuntu/setup || exit
    sudo git init
    sudo git clone https://github.com/TMRDevOps/terrasetup.git
    sudo chmod 777 -R /home/ubuntu/setup/
    sudo chmod 777 -R /home/ubuntu/setup/*
    sudo chown nobody:nogroup -R /home/ubuntu/setup/*
    sudo chown nobody:nogroup -R /home/ubuntu/setup/


#Setup ssh
   # kops
        sudo adduser kops
        sudo echo "kops  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/kops
        sudo mkdir /home/kops/.ssh
        sudo cp /home/ubuntu/.ssh/authorized_keys /home/kops/.ssh/authorized_keys 
        sudo chown kops:kops -R /home/kops/.ssh/* 
        sudo chown kops:kops -R /home/kops/.ssh/
        sudo chmod 600 -R /home/kops/.ssh/authorized_keys
        sudo chmod 700 -R /home/kops/.ssh/
    #Jenkins
        #sudo adduser jenkins
        sudo echo "jenkins  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/jenkins
        sudo mkdir /home/jenkins/.ssh
        sudo cp /home/ubuntu/.ssh/authorized_keys /home/jenkins/.ssh/authorized_keys 
        sudo chown jenkins:jenkins -R /home/jenkins/.ssh/* 
        sudo chown jenkins:jenkins -R /home/jenkins/.ssh/
        sudo chmod 600 -R /home/jenkins/.ssh/authorized_keys
        sudo chmod 700 -R /home/jenkins/.ssh/



#install Java
    sudo wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm
    sudo yum install java-11-openjdk-devel -y
    wait 5

#add Jenkins Repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    cd /etc/yum.repos.d/
    sudo curl -O https://pkg.jenkins.io/redhat-stable/jenkins.repo

#install Jenkins

    sudo yum -y install jenkins  --nobest
    wait 5

#install Docker
    sudo apt-get update
    sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    #sudo apt-get update
    wait 5
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    wait 5

#add Jenkins to Docker group
    usermod -aG docker jenkins

#Kops
    # install AWSCLI
        sudo apt update -y
        sudo apt install unzip wget -y
        sudo curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
        sudo apt install python -y
        wait 5
        sudo apt install awscli -y
        wait 5

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
        s3buck="tmrs3bucket2"
        aws s3 mb s3://"$s3buck";
# copy seport commands
cat >> /home/kops/.bashrc << EOF
export NAME=class30.k8s.local
export KOPS_STATE_STORE=s3://class30kops
EOF
source /home/kops/.bashrc

# create ssh key {in -f file with -N no passphrase}
    ssh-keygen -f /home/kops/.ssh/id_rsa -q -N ""

# create cluster
    kops create cluster --zones us-east-2a --networking weave --master-size t2.medium --master-count 1 --node-size t2.micro --node-count=2 ${NAME};
    wait 5
# copy the sshkey into your cluster to be able to access your kubernetes node from the kops server
    kops create secret --name ${NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub;
    wait 5
#update cluster
    kops update cluster ${NAME} --yes
