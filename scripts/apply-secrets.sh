#!/bin/bash
set -e

# Function to handle cleanup on exit
cleanup() {
  echo "Cleaning up..."
  rm -f /tmp/secrets.env
  exit 0
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Check if secrets template exists
if [ ! -f "config/secrets.env.template" ]; then
  echo "Error: config/secrets.env.template not found"
  exit 1
fi

# Create secrets file from template
echo "Creating secrets file from template..."
cp config/secrets.env.template /tmp/secrets.env

# Replace placeholders with actual values
echo "Replacing placeholders with actual values..."
sed -i 's/{{GATEWAY_HOST}}/your-gateway-host.example.com/g' /tmp/secrets.env
sed -i 's/{{GATEWAY_USER}}/your-gateway-user/g' /tmp/secrets.env
sed -i 's/{{GATEWAY_SSH_KEY}}/your-gateway-ssh-key/g' /tmp/secrets.env

# Move secrets file to config directory
echo "Moving secrets file to config directory..."
mv /tmp/secrets.env config/secrets.env

# Update Kubernetes secrets using Bazel
echo "Updating Kubernetes secrets..."
bazel run //k3s:secrets -- --from-file=config/secrets.env

echo "Secrets applied successfully" 