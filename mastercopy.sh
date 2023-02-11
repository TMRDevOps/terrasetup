#!/usr/bin/env bash
mkdir -p /home/ubuntu/.kube;
wait 5;
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config;
wait 5;
sudo chown $(id -u):$(id -g) /home/ubuntu/.kube/config;