#!/bin/bash
# Get the controller node IP
MASTER_IP=$1

# Get the token from the shared folder
TOKEN=$(cat /vagrant/token)

# Install K3s agent (worker) and join the master node
# ? INSTALL_K3S_EXEC="--flannel-iface=enp0s8"
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN sh -