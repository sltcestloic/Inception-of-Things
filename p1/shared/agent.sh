#!/bin/bash

# Get vars
SHARED_FOLDER=$1
MASTER_IP=$2

# Ready the environment for K3s
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install curl

# Install K3s agent
export K3S_URL=https://$MASTER_IP:6443
# export K3S_URL=https://192.168.58.110:6443
export K3S_TOKEN_FILE=/$SHARED_FOLDER/token
export INSTALL_K3S_EXEC="--flannel-iface=eth1"
# curl -sfL https://get.k3s.io |  sh -