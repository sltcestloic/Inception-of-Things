#!/bin/bash

# Create a k3d cluster for argocd and set it as context
k3d cluster create argocluster #--port 8080:80@loadbalancer #--agents 2
kubectl config use-context k3d-argocluster # optional: we only have one cluster

# Create required namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Configure argocd
# core install is missing permanent server for dashboard
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
# kubectl get svc -n argocd

# Login to argocd
# get ip and port
IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3d-argocluster-server-0)
PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath="{.spec.ports[?(@.port==443)].nodePort}")
argocd login $IP:$PORT --username admin --password $(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) --insecure


###
# Test stuff
###
# change namespace; default to go back to normal
kubectl config set-context --current --namespace=argocd

# create app
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace dev
# sync app
argocd app sync guestbook


# configure ports
# kubectl port-forward svc/argocd-server -n argocd 8080:443
# enable dashboard not perma
# argocd admin dashboard -n argocd

# get initial password
argocd admin initial-password -n argocd
# change password
#argocd account update-password
#*** Enter password of currently logged in user (admin): 
#*** Enter new password for user admin: 
#*** Confirm new password for user admin:
