#!/bin/bash

# This script generates basic auth credentials for Traefik

# Check if username and password are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

# Check if htpasswd is installed
if ! command -v htpasswd &> /dev/null; then
    echo "htpasswd is not installed. Installing apache2-utils..."
    sudo apt-get update
    sudo apt-get install -y apache2-utils
fi

# Generate the auth string
AUTH_STRING=$(htpasswd -nb "$USERNAME" "$PASSWORD")
BASE64_AUTH=$(echo "$AUTH_STRING" | base64)

echo "Generated auth string: $AUTH_STRING"
echo "Base64 encoded: $BASE64_AUTH"
echo ""
echo "Use this base64 encoded string in your Kubernetes Secret:"
echo ""
echo "apiVersion: v1"
echo "kind: Secret"
echo "metadata:"
echo "  name: traefik-basic-auth"
echo "  namespace: default"
echo "type: Opaque"
echo "data:"
echo "  users: $BASE64_AUTH"

# Create the secret YAML file
cat > traefik-auth-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: traefik-basic-auth
  namespace: default
type: Opaque
data:
  users: $BASE64_AUTH
EOF

echo ""
echo "Secret YAML file created: traefik-auth-secret.yaml"
echo "Apply it with: kubectl apply -f traefik-auth-secret.yaml" 