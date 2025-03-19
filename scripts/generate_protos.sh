#!/bin/bash
set -e

# Get the absolute path to the project root
PROJECT_ROOT=$(realpath "$(dirname "$0")/..")

# Check for Dart protoc plugin
if ! command -v protoc-gen-dart >/dev/null 2>&1; then
  echo "Error: protoc-gen-dart not found. Please install it with:"
  echo "dart pub global activate protoc_plugin"
  echo "Then add \$HOME/.pub-cache/bin to your PATH"
  exit 1
fi

# Clean up existing generated files
rm -f "$PROJECT_ROOT/badger/node_service.pb.go" "$PROJECT_ROOT/badger/node_service_grpc.pb.go"
rm -f "$PROJECT_ROOT/badger/internal/proto/node_service.pb.go" "$PROJECT_ROOT/badger/internal/proto/node_service_grpc.pb.go"
rm -f "$PROJECT_ROOT/badger/github.com/toyokaku/zerg/badger/internal/proto/node_service.pb.go"
mkdir -p "$PROJECT_ROOT/frontend/lib/generated"
rm -f "$PROJECT_ROOT/frontend/lib/generated/"*.dart

# Generate Go protobuf files
protoc --go_out="$PROJECT_ROOT/badger" --go_opt=paths=source_relative \
       --go-grpc_out="$PROJECT_ROOT/badger" --go-grpc_opt=paths=source_relative \
       --proto_path="$PROJECT_ROOT/proto" "$PROJECT_ROOT/proto/node_service.proto"

# Generate Dart protobuf files
protoc --dart_out=grpc:"$PROJECT_ROOT/frontend/lib/generated" \
       --proto_path="$PROJECT_ROOT/proto" "$PROJECT_ROOT/proto/node_service.proto"

# Move generated files if needed
if [ -f "$PROJECT_ROOT/badger/node_service.pb.go" ]; then
  mv "$PROJECT_ROOT/badger/node_service.pb.go" "$PROJECT_ROOT/badger/internal/proto/"
  mv "$PROJECT_ROOT/badger/node_service_grpc.pb.go" "$PROJECT_ROOT/badger/internal/proto/"
fi

echo "Proto files generated successfully" 