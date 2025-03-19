#!/bin/bash

# Gateway Deployment Script
# This script can be used for both manual deployment and GitHub Actions

# Exit on error and unset variables
set -eu

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default values
GATEWAY_USER=${GATEWAY_USER:-$USER}
GATEWAY_HOST=${GATEWAY_HOST:-"localhost"}
REMOTE_MODE=${REMOTE_MODE:-false}
SSH_KEY=${SSH_KEY:-""}
BUILD_IMAGES=${BUILD_IMAGES:-true}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --remote) REMOTE_MODE=true; shift ;;
    --host) GATEWAY_HOST="$2"; shift 2 ;;
    --user) GATEWAY_USER="$2"; shift 2 ;;
    --key) SSH_KEY="$2"; shift 2 ;;
    --no-build) BUILD_IMAGES=false; shift ;;
    --help|-h) 
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --remote            Deploy to remote host (default: local)"
      echo "  --host HOST         Remote host address (default: localhost)"
      echo "  --user USER         Remote user for SSH (default: current user)"
      echo "  --key KEY           SSH private key file"
      echo "  --no-build          Skip building images (use for gateway-only deployments)"
      exit 0 
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Helper functions
run_cmd() {
  if [[ "$REMOTE_MODE" == "true" ]]; then
    ssh ${SSH_KEY:+-i "$SSH_KEY"} $GATEWAY_USER@$GATEWAY_HOST "$1"
  else
    eval "$1"
  fi
}

copy_file() {
  if [[ "$REMOTE_MODE" == "true" ]]; then
    scp ${SSH_KEY:+-i "$SSH_KEY"} -r "$1" $GATEWAY_USER@$GATEWAY_HOST:"$2"
  else
    mkdir -p "$(dirname "$2")"
    cp -r "$1" "$2"
  fi
}

echo "=== Deployment Started ==="

# Create directories
run_cmd "mkdir -p /tmp/k3s /tmp/k8s/badger /tmp/k8s/frontend /tmp/images /tmp/config"

# Build and push container images if enabled
if [[ "$BUILD_IMAGES" == "true" && "$REMOTE_MODE" == "false" ]]; then
  # Check for buildah
  if ! command -v buildah &> /dev/null; then
    echo "Error: buildah is not installed. Please install it or use --no-build option."
    exit 1
  fi
  
  # Build images
  if [ -f "$BASE_DIR/scripts/build_images.sh" ]; then
    chmod +x "$BASE_DIR/scripts/build_images.sh"
    "$BASE_DIR/scripts/build_images.sh"
  else
    echo "Error: build_images.sh not found."
    exit 1
  fi
  
  # Save images as tar archives
  buildah push localhost/badger:latest oci-archive:/tmp/images/badger-image.tar
  buildah push localhost/frontend:latest oci-archive:/tmp/images/frontend-image.tar
fi

# Copy configuration files
copy_file "$BASE_DIR/k3s/core/" "/tmp/k3s/"
if [[ "$BUILD_IMAGES" == "true" ]]; then
  copy_file "$BASE_DIR/k3s/badger/" "/tmp/k8s/badger/"
  copy_file "$BASE_DIR/k3s/frontend/" "/tmp/k8s/frontend/"
fi
copy_file "$BASE_DIR/k3s/ingress/" "/tmp/k3s/"
copy_file "$BASE_DIR/scripts/apply-secrets.sh" "/tmp/"

# Copy images if remote deployment and images were built
if [[ "$REMOTE_MODE" == "true" && "$BUILD_IMAGES" == "true" ]]; then
  copy_file "/tmp/images/" "/tmp/images/"
fi

# Copy secrets
if [[ -f "$BASE_DIR/config/secrets.env" ]]; then
  copy_file "$BASE_DIR/config/secrets.env" "/tmp/config/"
elif [[ -f "$BASE_DIR/config/secrets.env.template" ]]; then
  mkdir -p "$BASE_DIR/config"
  cp "$BASE_DIR/config/secrets.env.template" "$BASE_DIR/config/secrets.env"
  copy_file "$BASE_DIR/config/secrets.env" "/tmp/config/"
fi

# Make script executable
run_cmd "chmod +x /tmp/apply-secrets.sh"

# Import images if they were built
if [[ "$BUILD_IMAGES" == "true" ]]; then
  run_cmd "sudo ctr -n k8s.io images import /tmp/images/badger-image.tar"
  run_cmd "sudo ctr -n k8s.io images import /tmp/images/frontend-image.tar"
fi

# Ensure K3s is running
run_cmd "if ! systemctl is-active --quiet k3s; then sudo systemctl start k3s; sleep 5; fi"

# Apply secrets and configurations
run_cmd "cd /tmp && ./apply-secrets.sh"

# Apply Kubernetes manifests
if [[ "$BUILD_IMAGES" == "true" ]]; then
  run_cmd "kubectl apply -f /tmp/k8s/badger/"
  run_cmd "kubectl apply -f /tmp/k8s/frontend/"
  run_cmd "kubectl rollout restart deployment badger frontend"
fi
run_cmd "kubectl apply -f /tmp/k3s/"

echo "=== Deployment Completed ==="
echo "You can access the dashboard at the configured Traefik host" 