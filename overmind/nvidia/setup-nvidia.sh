#!/bin/bash

# This script sets up the NVIDIA runtime for containerd on the Ubuntu PC

# Install NVIDIA Container Runtime
sudo apt-get update
sudo apt-get install -y nvidia-container-runtime

# Create containerd config directory
sudo mkdir -p /etc/containerd

# Copy containerd config
sudo cp containerd-config.toml /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd

# Apply NVIDIA runtime configuration to Kubernetes
kubectl apply -f nvidia-runtime.yaml

# Label the node for GPU
kubectl label nodes $(hostname) gpu=true --overwrite

echo "NVIDIA runtime setup complete!" 