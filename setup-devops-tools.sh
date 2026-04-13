#!/bin/bash

set -e

echo "Updating system..."
sudo apt-get update -y

echo "Installing prerequisites..."
sudo apt-get install -y curl wget apt-transport-https ca-certificates gnupg lsb-release unzip

# -----------------------------
# AZURE CLI
# -----------------------------
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

az version

# -----------------------------
# KUBECTL
# -----------------------------
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

kubectl version --client

# -----------------------------
# DOCKER
# -----------------------------
echo "Installing Docker..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

docker --version

# -----------------------------
# HELM
# -----------------------------
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm version

# -----------------------------
# ARGO CD CLI
# -----------------------------
echo "Installing Argo CD CLI..."
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd
rm argocd

argocd version

# -----------------------------
# ARGO ROLLOUTS CLI
# -----------------------------
echo "Installing Argo Rollouts CLI..."

curl -sSL -o kubectl-argo-rollouts https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x kubectl-argo-rollouts
sudo mv kubectl-argo-rollouts /usr/local/bin/

kubectl argo rollouts version
