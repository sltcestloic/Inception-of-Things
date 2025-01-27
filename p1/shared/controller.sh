#!/bin/bash
# Install K3s
# ? INSTALL_K3S_EXEC="--bind-address=192.168.58.110 --node-external-ip=192.168.58.110 --flannel-iface=enp0s8" K3S_KUBECONFIG_MODE="644"
curl -sfL https://get.k3s.io | sh -

# Make sure kubectl is set up for the vagrant user
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config

# Get the token for the worker nodes
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Store the token for the workers to use
echo $TOKEN > /vagrant/token