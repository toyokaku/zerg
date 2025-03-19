#!/bin/bash
set -e

# Function to handle cleanup on exit
cleanup() {
  echo "Cleaning up processes..."
  kill $(jobs -p) 2>/dev/null || true
  exit 0
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Get the absolute path to the project root
PROJECT_ROOT=$(realpath "$(dirname "$0")/..")

# Kill any previously running processes
pkill -f "badger.*--local" || true
pkill -f "flutter.*-d web-server" || true
sleep 1

# Install Dart protoc plugin if not present
if ! command -v protoc-gen-dart >/dev/null 2>&1; then
  echo "Installing Dart protoc plugin..."
  dart pub global activate protoc_plugin
  export PATH="$PATH:$HOME/.pub-cache/bin"
fi

# Clean up existing generated proto files
rm -f "$PROJECT_ROOT/badger/node_service.pb.go" "$PROJECT_ROOT/badger/node_service_grpc.pb.go"
rm -f "$PROJECT_ROOT/badger/internal/proto/node_service.pb.go" "$PROJECT_ROOT/badger/internal/proto/node_service_grpc.pb.go"
rm -f "$PROJECT_ROOT/badger/github.com/toyokaku/zerg/badger/internal/proto/node_service.pb.go"
mkdir -p "$PROJECT_ROOT/frontend/lib/generated"
rm -f "$PROJECT_ROOT/frontend/lib/generated/"*.dart

# Generate protobuf files
echo "Generating Go protobuf files..."
protoc --go_out="$PROJECT_ROOT/badger" --go_opt=paths=source_relative \
       --go-grpc_out="$PROJECT_ROOT/badger" --go-grpc_opt=paths=source_relative \
       --proto_path="$PROJECT_ROOT/proto" "$PROJECT_ROOT/proto/node_service.proto"

echo "Generating Dart protobuf files..."
protoc --dart_out=grpc:"$PROJECT_ROOT/frontend/lib/generated" \
       --proto_path="$PROJECT_ROOT/proto" "$PROJECT_ROOT/proto/node_service.proto"

# Move generated files if needed
if [ -f "$PROJECT_ROOT/badger/node_service.pb.go" ]; then
  mv "$PROJECT_ROOT/badger/node_service.pb.go" "$PROJECT_ROOT/badger/internal/proto/"
  mv "$PROJECT_ROOT/badger/node_service_grpc.pb.go" "$PROJECT_ROOT/badger/internal/proto/"
fi

# Set environment variables
export NO_K8S=true
export DISABLE_K8S=true
export LOCAL_MODE=true

# Build and start Badger
echo "Building Badger service..."
cd "$PROJECT_ROOT/badger"
go build -o badger cmd/main.go
cd "$PROJECT_ROOT"

# Start services
echo "Starting Badger service..."
./badger/badger --local-mode --grpc-addr=:9090 --web-addr=:8090 &
BADGER_PID=$!

echo "Starting Flutter web app..."
cd "$PROJECT_ROOT/frontend"
flutter run -d web-server --web-port=8080 --dart-define=BADGER_GRPC_URL=localhost:8090 &
FLUTTER_PID=$!

echo "Services started:"
echo "- Badger gRPC: localhost:9090"
echo "- Badger Web: localhost:8090"
echo "- Frontend: http://localhost:8080"
echo "Press Ctrl+C to stop"

wait