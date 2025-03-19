#!/bin/bash
set -e

# Load secrets from /tmp/config/secrets.env
if [ ! -f "/tmp/config/secrets.env" ]; then
  echo "Error: /tmp/config/secrets.env not found"
  exit 1
fi

source /tmp/config/secrets.env

# Create temp directory for processed files
TEMP_DIR=$(mktemp -d)
# trap 'rm -rf "$TEMP_DIR"' EXIT

# Simple variable substitution function
substitute_vars() {
  local input="$1"
  local output="$2"
  
  # Base64 encode AUTH_USERS if needed (it's used in a Kubernetes Secret)
  if [ -n "${AUTH_USERS}" ]; then
    AUTH_USERS_B64=$(echo -n "${AUTH_USERS}" | base64 -w 0)
  else
    AUTH_USERS_B64=""
  fi
  
  # Format TLS_DNS_NAMES as a YAML array if needed
  if [ -n "${TLS_DNS_NAMES}" ]; then
    if [[ "${TLS_DNS_NAMES}" == *","* ]]; then
      # Convert comma-separated format to YAML array format
      TLS_DNS_NAMES_YAML="$(echo "${TLS_DNS_NAMES}" | sed 's/,/", "/g')"
      TLS_DNS_NAMES_YAML="[\"${TLS_DNS_NAMES_YAML}\"]"
    else
      # Single domain, make it a JSON array
      TLS_DNS_NAMES_YAML="[\"${TLS_DNS_NAMES}\"]"
    fi
  else
    TLS_DNS_NAMES_YAML='["example.com"]'
  fi
  
  # Standard variable replacement
  sed -e "s|\${AUTH_USERS}|${AUTH_USERS_B64:-}|g" \
      -e "s|\${ACME_EMAIL}|${ACME_EMAIL:-no-reply@example.com}|g" \
      -e "s|\${TLS_DNS_NAMES}|${TLS_DNS_NAMES_YAML}|g" \
      -e "s|\${INTERNAL_HOST}|${INTERNAL_HOST:-dashboard.local}|g" \
      -e "s|\${EXTERNAL_HOST}|${EXTERNAL_HOST:-dashboard.example.com}|g" \
      "$input" > "$output"
}

# Process core files
mkdir -p /tmp/k3s

# Traefik config (with Secret)
if [ -f "/tmp/k3s/traefik-config.yaml" ]; then
  substitute_vars "/tmp/k3s/traefik-config.yaml" "$TEMP_DIR/traefik-config.yaml"
  kubectl apply -f "$TEMP_DIR/traefik-config.yaml"
fi

# Traefik TLS (with DNS names)
if [ -f "/tmp/k3s/traefik-tls.yaml" ]; then
  substitute_vars "/tmp/k3s/traefik-tls.yaml" "$TEMP_DIR/traefik-tls.yaml"
  kubectl apply -f "$TEMP_DIR/traefik-tls.yaml"
fi

# Traefik routes
if [ -f "/tmp/k3s/traefik-routes.yaml" ]; then
  substitute_vars "/tmp/k3s/traefik-routes.yaml" "$TEMP_DIR/traefik-routes.yaml"
  kubectl apply -f "$TEMP_DIR/traefik-routes.yaml"
fi

# Cert-manager
if [ -f "/tmp/k3s/cert-manager.yaml" ]; then
  substitute_vars "/tmp/k3s/cert-manager.yaml" "$TEMP_DIR/cert-manager.yaml"
  kubectl apply -f "$TEMP_DIR/cert-manager.yaml"
fi

# NATS config
if [ -f "/tmp/k3s/nats.yaml" ]; then
  substitute_vars "/tmp/k3s/nats.yaml" "$TEMP_DIR/nats.yaml"
  kubectl apply -f "$TEMP_DIR/nats.yaml"
fi 