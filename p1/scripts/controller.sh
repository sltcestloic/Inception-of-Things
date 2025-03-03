#!/bin/bash

# Get vars
SHARED_FOLDER=$1
MASTER_IP=$2

# Ready the environment for K3s
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install curl -y

# Install K3s
export K3S_KUBECONFIG_MODE="644" # k3s server
export INSTALL_K3S_EXEC="--bind-address=$2 --node-external-ip=$2 --flannel-iface=eth1"
curl -sfL https://get.k3s.io | sh -

# Copy config and token to shared folder for future use
sudo cp /etc/rancher/k3s/k3s.yaml $SHARED_FOLDER/
sudo cp /var/lib/rancher/k3s/server/node-token $SHARED_FOLDER/token