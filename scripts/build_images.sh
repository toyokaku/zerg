#!/bin/bash

# Build container images using Buildah (without Docker)
# This script builds container images for badger and frontend services

# Exit on error
set -e

# Set image names and tags
BADGER_IMAGE="localhost/badger:latest"
FRONTEND_IMAGE="localhost/frontend:latest"

echo "=== Building Container Images with Buildah ==="

# Build badger Go binary first
echo "Building badger binary..."
cd "$(dirname "$0")/../badger"
go build -o badger cmd/main.go

# Build badger container image
echo "Building badger container image..."
buildah from --name badger-container scratch
buildah copy badger-container badger /app/badger
buildah config --entrypoint '["/app/badger"]' badger-container
buildah config --port 9090 badger-container
buildah commit badger-container $BADGER_IMAGE
buildah rm badger-container

# Build frontend web files
echo "Building frontend..."
cd "../frontend"
flutter build web

# Build frontend container image
echo "Building frontend container image..."
buildah from --name frontend-container alpine:3.18
buildah run frontend-container -- apk add --no-cache lighttpd
buildah copy frontend-container build/web /app/web
buildah run frontend-container -- sh -c 'cat > /etc/lighttpd/lighttpd.conf << EOF
server.document-root = "/app/web" 
server.port = 8080
server.modules = (
    "mod_access",
    "mod_accesslog"
)
include "mime-types.conf"
static-file.exclude-extensions = ( ".fcgi", ".php", ".rb", "~", ".inc" )
index-file.names = ( "index.html" )
server.errorlog = "/dev/stderr"
accesslog.filename = "/dev/stdout"
EOF'
buildah config --port 8080 frontend-container
buildah config --user 1000:1000 frontend-container
buildah config --entrypoint '["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]' frontend-container
buildah commit frontend-container $FRONTEND_IMAGE
buildah rm frontend-container

# Print summary
echo "=== Container Images Built Successfully ==="
echo "Badger image: $BADGER_IMAGE"
echo "Frontend image: $FRONTEND_IMAGE"
echo ""
echo "To push these images to your K3s node:"
echo "1. Save images to files:"
echo "   buildah push $BADGER_IMAGE oci-archive:/tmp/badger-image.tar"
echo "   buildah push $FRONTEND_IMAGE oci-archive:/tmp/frontend-image.tar"
echo "2. Copy files to your K3s node (if remote)"
echo "3. Import images into containerd:"
echo "   sudo ctr -n k8s.io images import /tmp/badger-image.tar"
echo "   sudo ctr -n k8s.io images import /tmp/frontend-image.tar"
echo ""
echo "Or update your K8s manifests to use these image names" 