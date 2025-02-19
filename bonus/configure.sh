#!/bin/bash

# Create a k3d cluster for argocd and set it as context
k3d cluster create argocluster #--port 8080:80@loadbalancer #--agents 2
kubectl config use-context k3d-argocluster # optional: we only have one cluster

# Create required namespaces
kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab

# Configure argocd
# core install is missing permanent server for dashboard
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# port-forwarding but not when pending status (above is perma and works well)
# kubectl port-forward svc/argocd-server -n argocd 8080:443 
# kubectl get svc -n argocd

# Login to argocd
SERVER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3d-argocluster-server-0)
SERVER_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath="{.spec.ports[?(@.port==443)].nodePort}")
echo "Admin dashboard $SERVER_IP:$SERVER_PORT"
echo "Playground-app $SERVER_IP:30888"
echo "Waiting for argocd-server to be deployed..."
kubectl wait --for=condition=available --timeout=300s deployment -n argocd argocd-server
echo "Initial password $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
# argocd login $SERVER_IP:$SERVER_PORT --username admin --password $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) --insecure

# Apply app configuration
kubectl apply -f argocd/application.yaml -n argocd
