#!/bin/bash

# Exit on error
set -e

# Update system packages
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt-get install -y curl wget git

# Install k3s
echo "Installing k3s..."
curl -sfL https://get.k3s.io | sh -

# Wait for k3s to be ready
echo "Waiting for k3s to be ready..."
sleep 30

# Configure k3s to use the machine's IP instead of localhost
echo "Configuring k3s..."
MACHINE_IP=$(hostname -I | awk '{print $1}')
sudo sed -i "s|server: https://127.0.0.1:6443|server: https://${MACHINE_IP}:6443|" /etc/rancher/k3s/k3s.yaml

# Set proper permissions
echo "Setting permissions..."
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Create .kube directory and copy config
echo "Setting up kubectl configuration..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# Install helm
echo "Installing helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add jenkins helm repo
echo "Adding Jenkins helm repository..."
helm repo add jenkins https://charts.jenkins.io
helm repo update

echo "Installation complete! You can now use kubectl and helm."
echo "To verify the installation, run: kubectl get nodes" 