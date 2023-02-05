#!/usr/bin/env bash
cd /home/ubuntu/setup/terrasetup/YML Files;
kubectl apply -f myapp.yml;
kubectl apply -f myrc.yml;
kubectl apply -f pod.yml;
kubectl apply -f service.yml;
