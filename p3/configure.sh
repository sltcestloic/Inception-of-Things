#!/bin/bash

# Create a k3d cluster for argocd
k3d cluster create argocluster --agents 2

# Create required namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Configure argocd
# core install is missing permanent server for dashboard
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# configure ports
kubectl port-forward svc/argocd-server -n argocd 8080:443
# enable dashboard not perma
argocd admin dashboard -n argocd
