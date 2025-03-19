#!/bin/bash

# Master Deployment Script
# This script can be used for both manual deployment and GitHub Actions

# Exit on error and unset variables
set -eu

# Get the base directory for consistent pathing
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default values (can be overridden by environment variables)
MASTER_USER=${MASTER_USER:-$USER}
MASTER_HOST=${MASTER_HOST:-"localhost"}
REMOTE_MODE=${REMOTE_MODE:-false}
SSH_KEY=${SSH_KEY:-""}
GATEWAY_HOST=${GATEWAY_HOST:-""}
GATEWAY_USER=${GATEWAY_USER:-""}
GATEWAY_SSH_KEY=${GATEWAY_SSH_KEY:-""}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --remote)
      REMOTE_MODE=true
      shift
      ;;
    --host)
      MASTER_HOST="$2"
      shift 2
      ;;
    --user)
      MASTER_USER="$2"
      shift 2
      ;;
    --key)
      SSH_KEY="$2"
      shift 2
      ;;
    --gateway-host)
      GATEWAY_HOST="$2"
      shift 2
      ;;
    --gateway-user)
      GATEWAY_USER="$2"
      shift 2
      ;;
    --gateway-key)
      GATEWAY_SSH_KEY="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --remote              Run in remote mode (default: local)"
      echo "  --host HOST           Remote host (default: localhost)"
      echo "  --user USER           Remote user (default: current user)"
      echo "  --key KEY_FILE        SSH key file for remote connection"
      echo "  --gateway-host HOST   Gateway host (optional)"
      echo "  --gateway-user USER   Gateway user (optional)"
      echo "  --gateway-key KEY     Gateway SSH key file (optional)"
      echo "  --help, -h            Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1. Use --help for usage information."
      exit 1
      ;;
  esac
done

# Function to run commands locally or remotely
run_cmd() {
  local cmd="$1"
  local error_msg="${2:-Command execution failed}"
  
  echo "Executing: $cmd"
  if [[ "$REMOTE_MODE" == "true" ]]; then
    if [[ -n "$SSH_KEY" ]]; then
      ssh -i "$SSH_KEY" $MASTER_USER@$MASTER_HOST "$cmd" || echo "$error_msg"
    else
      ssh $MASTER_USER@$MASTER_HOST "$cmd" || echo "$error_msg"
    fi
  else
    eval "$cmd" || echo "$error_msg"
  fi
}

# Function to copy files locally or remotely
copy_file() {
  local src="$1"
  local dest="$2"
  local error_msg="${3:-File copy failed: $src -> $dest}"
  
  # Check if source exists
  if [[ "$REMOTE_MODE" == "false" && ! -e "$src" ]]; then
    echo "Warning: Source does not exist: $src, skipping"
    return 0
  fi
  
  echo "Copying: $src -> $dest"
  if [[ "$REMOTE_MODE" == "true" ]]; then
    if [[ -n "$SSH_KEY" ]]; then
      scp -i "$SSH_KEY" -r "$src" $MASTER_USER@$MASTER_HOST:"$dest" || echo "$error_msg"
    else
      scp -r "$src" $MASTER_USER@$MASTER_HOST:"$dest" || echo "$error_msg"
    fi
  else
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest" || echo "$error_msg"
  fi
}

# Function to run commands on gateway
run_gateway_cmd() {
  local cmd="$1"
  local error_msg="${2:-Gateway command execution failed}"
  
  if [[ -z "$GATEWAY_HOST" || -z "$GATEWAY_USER" ]]; then
    echo "Gateway host or user not specified. Skipping gateway commands."
    return 0
  }
  
  echo "Executing on gateway: $cmd"
  if [[ -n "$GATEWAY_SSH_KEY" ]]; then
    ssh -i "$GATEWAY_SSH_KEY" $GATEWAY_USER@$GATEWAY_HOST "$cmd" || echo "$error_msg"
  else
    ssh $GATEWAY_USER@$GATEWAY_HOST "$cmd" || echo "$error_msg"
  fi
}

echo "=== Master Deployment Started ==="

# Create necessary directories
echo "Creating directories..."
run_cmd "mkdir -p /tmp/overmind /tmp/nvidia /tmp/k8s" "Failed to create necessary directories"

# Build overmind if running locally
if [[ "$REMOTE_MODE" == "false" ]]; then
  echo "Building overmind..."
  cd "$BASE_DIR"
  go build -o overmind cmd/main.go || echo "Failed to build overmind"
  cd "$BASE_DIR/scripts"
fi

# Copy binaries and files
echo "Copying files..."
copy_file "$BASE_DIR/overmind" "/tmp/overmind/" "Failed to copy overmind binary"
copy_file "$BASE_DIR/nvidia/" "/tmp/nvidia/" "Failed to copy nvidia files"

# Create directories for containerd content
echo "Setting up containerd directories..."
run_cmd "sudo mkdir -p /var/lib/containerd/io.containerd.content.v1.content/bin" "Failed to create containerd bin directory"

# Copy binaries to containerd content store
run_cmd "sudo cp /tmp/overmind/overmind /var/lib/containerd/io.containerd.content.v1.content/bin/" "Failed to copy overmind to containerd bin"

# Set proper permissions
run_cmd "sudo chmod 755 /var/lib/containerd/io.containerd.content.v1.content/bin/overmind" "Failed to set permissions on overmind binary"
run_cmd "sudo chmod +x /tmp/nvidia/setup-nvidia.sh" "Failed to make setup-nvidia.sh executable"

# Configure NVIDIA runtime
echo "Configuring NVIDIA runtime..."
run_cmd "cd /tmp/nvidia && sudo ./setup-nvidia.sh" "Failed to configure NVIDIA runtime"

# Apply Kubernetes manifests on gateway if gateway info is provided
if [[ -n "$GATEWAY_HOST" && -n "$GATEWAY_USER" ]]; then
  echo "Applying Kubernetes manifests on gateway..."
  run_gateway_cmd "sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl apply -f /tmp/k8s/overmind/overmind-config.yaml || echo 'Warning: Failed to apply overmind-config.yaml'" "Failed to apply overmind-config.yaml"
  run_gateway_cmd "sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl apply -f /tmp/k8s/overmind/" "Failed to apply overmind manifests"
  run_gateway_cmd "sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl rollout restart deployment overmind" "Failed to restart overmind deployment"
fi

echo "=== Master Deployment Completed ==="
echo "Overmind service is now deployed on the master node" 