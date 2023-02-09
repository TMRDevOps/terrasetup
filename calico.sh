#!/usr/bin/env bash

#kubectl apply -f https://docs.projectcalico.org/manifest/calico.yaml

#kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
#kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml


kubectl get pods -A
kubectl get node


kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml