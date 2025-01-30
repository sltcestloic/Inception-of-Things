#!/bin/bash

# Get vars
MASTER_IP=$1

# Ready the environment for K3s
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install curl -y

# Install K3s
export K3S_KUBECONFIG_MODE="644" k3s server
export INSTALL_K3S_EXEC="--bind-address=$MASTER_IP --node-external-ip=$MASTER_IP --flannel-iface=eth1"
curl -sfL https://get.k3s.io | sh -

kubectl apply -f /vagrant/app1/
kubectl apply -f /vagrant/app2/
kubectl apply -f /vagrant/app3/
kubectl apply -f /vagrant/ingress.yaml

echo "Waiting for the deployments to be available..."
kubectl wait --for=condition=available deployment --all --timeout=300s