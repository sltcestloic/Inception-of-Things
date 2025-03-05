#!/bin/bash

ARGO_ADMIN_PASSWORD="replace_me"

# Create cluster
k3d cluster create argolab 

# Install and configure gitlab
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
    --timeout 600s \
    --namespace gitlab \
    --set certmanager-issuer.email=lbertran@student.42lyon.fr \
    --set global.hosts.externalIP="127.0.0.1" \
    --set global.hosts.https=false
echo "Waiting for gitlab to be deployed..."
kubectl wait --for=condition=available --timeout=500s deployment -n gitlab --all
echo "Saving initial gitlab password..."
INITIAL_GITLAB_PASSWORD=$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)
echo "$INITIAL_GITLAB_PASSWORD" > ~/tmp
echo "Initial gitlab password saved in ~/tmp"


# Install and configure argocd
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
    --timeout 300s \
    --namespace argocd
echo "Waiting for argocd to be deployed..."
kubectl wait --for=condition=available --timeout=300s deployment -n argocd argocd-server
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

SERVER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3d-argolab-server-0)
INITIAL_ARGOCD_PASSWORD=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login $SERVER_IP:31888 --username admin --password $INITIAL_ARGOCD_PASSWORD --insecure
argocd account update-password --current-password $INITIAL_ARGOCD_PASSWORD --new-password $ARGO_ADMIN_PASSWORD

# Expose gitlab
kubectl port-forward --namespace gitlab svc/gitlab-webservice-default 8080:8181 > /dev/null 2>&1 &

# Create api access token
GITLAB_TOKEN=$(kubectl -n gitlab exec -it $(kubectl -n gitlab get pods -l app=toolbox -o jsonpath='{.items[0].metadata.name}') -- \
    gitlab-rails runner '
    token = PersonalAccessToken.create!(
      user: User.find_by(username: "root"),
      name: "admin-token",
      scopes: ["api", "read_repository"],
      expires_at: 1.year.from_now
    )
    puts token.token
    ' 2>/dev/null | tail -n1 | tr -d '\r')

# Create repo
curl --request POST "http://localhost:8080/api/v4/projects" \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --data "name=playground&visibility=public"
cd ../confs/playground
git init
git remote add origin http://root:$INITIAL_GITLAB_PASSWORD@localhost:8080/root/playground.git
git add .
git commit -m "initial commit"
git push -u origin master
cd ../../scripts

# Start app
kubectl create namespace dev
kubectl apply -f ../confs/argocd/application.yaml -n argocd

# Access
echo "ArgoCD Admin Dashboard $SERVER_IP:31888"
echo "GitLab localhost:8080"
echo "App $SERVER_IP:30888"