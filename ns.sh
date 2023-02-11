#!/usr/bin/env bash
kubectl create ns dev;
wait 5;
kubectl create ns qa;