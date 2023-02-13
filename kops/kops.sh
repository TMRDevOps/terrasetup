#!/usr/bin/env bash

# install AWSCLI
    sudo apt update -y
    sudo apt install unzip wget -y
    sudo curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
    sudo apt install python -y
    sudo apt install awscli -y
    wait 5;

# install kops
    sudo apt install wget -y
    sudo wget https://github.com/kubernetes/kops/releases/download/v1.22.0/kops-linux-amd64
    sudo chmod +x kops-linux-amd64
    sudo mv kops-linux-amd64 /usr/local/bin/kops
    wait 5

# install kubectl
    sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    sudo chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl

# create S3 bucket
    aws s3 mb s3://tmrs3bucket
    aws s3 ls # to verify