#!/bin/bash

ARGO_ADMIN_PASSWORD="replace_me"

# Create a k3d cluster for argocd and set it as context
k3d cluster create argocluster
kubectl config use-context k3d-argocluster

# Create required namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Configure argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{
  "spec": {
    "type": "NodePort",
    "ports": [
      {
        "port": 443,
        "targetPort": 8080,
        "nodePort": 31888
      }
    ]
  }
}'

# Login to argocd
SERVER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3d-argocluster-server-0)
echo "Admin dashboard $SERVER_IP:31888"
echo "Playground-app $SERVER_IP:30888"
echo "Waiting for argocd-server to be deployed..."
kubectl wait --for=condition=available --timeout=300s deployment -n argocd argocd-server
INITIAL_ARGOCD_PASSWORD=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login $SERVER_IP:31888 --username admin --password $INITIAL_ARGOCD_PASSWORD --insecure
argocd account update-password --current-password $INITIAL_ARGOCD_PASSWORD --new-password $ARGO_ADMIN_PASSWORD

# Apply app configuration
kubectl apply -f ../confs/argocd/application.yaml -n argocd
