#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROTO_DIR="$PROJECT_ROOT/proto"
FRONTEND_PROTO_DIR="$PROJECT_ROOT/frontend/lib/generated"

# Add flutter pub-cache to PATH if not already present
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Ensure the frontend proto directory exists
mkdir -p "$FRONTEND_PROTO_DIR"

# Check for protoc
if ! command -v protoc &> /dev/null; then
    echo "Error: protoc is not installed. Please install protocol buffers compiler."
    exit 1
fi

# Check for dart protoc plugin
if ! command -v protoc-gen-dart &> /dev/null; then
    echo "Error: protoc-gen-dart is not installed."
    echo "Installing protoc_plugin..."
    cd "$PROJECT_ROOT/frontend" && flutter pub global activate protoc_plugin
    
    # Recheck
    if ! command -v protoc-gen-dart &> /dev/null; then
        echo "Error: Failed to install or find protoc-gen-dart."
        echo "Please run 'cd frontend && flutter pub global activate protoc_plugin' manually."
        echo "Then ensure $HOME/.pub-cache/bin is in your PATH."
        exit 1
    fi
fi

echo "Generating Dart proto files from $PROTO_DIR to $FRONTEND_PROTO_DIR"

# Generate Dart files from protos
protoc \
    --proto_path="$PROTO_DIR" \
    --dart_out=grpc:"$FRONTEND_PROTO_DIR" \
    "$PROTO_DIR"/*.proto

echo "Proto generation complete" 