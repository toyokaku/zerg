#!/bin/bash
set -e

# Log file for debugging
LOG_FILE="/tmp/local_dev.log"
echo "Starting local dev environment $(date)" > $LOG_FILE

# Function to handle cleanup on exit
cleanup() {
  echo "Cleaning up processes..." | tee -a $LOG_FILE
  kill $(jobs -p) 2>/dev/null || true
  exit 0
}

# Function to check if a port is available
is_port_available() {
  if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
    return 1
  else
    return 0
  fi
}

# Find an available port starting from a base port
find_available_port() {
  local port=$1
  while ! is_port_available $port; do
    echo "Port $port is in use, trying next port..." | tee -a $LOG_FILE
    port=$((port + 1))
  done
  echo $port
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Ensure protoc is installed
if ! command -v protoc &> /dev/null; then
  echo "Error: protoc is not installed. Please install it with:" | tee -a $LOG_FILE
  echo "  sudo apt-get install protobuf-compiler" | tee -a $LOG_FILE
  exit 1
fi

# Ensure lsof is installed
if ! command -v lsof &> /dev/null; then
  echo "Warning: lsof is not installed. Port availability checks will be skipped." | tee -a $LOG_FILE
  echo "  It's recommended to install lsof with: sudo apt-get install lsof" | tee -a $LOG_FILE
fi

# Ensure protoc-gen-dart is installed for Dart proto generation
if ! command -v protoc-gen-dart &> /dev/null; then
  export PATH="$PATH":"$HOME/.pub-cache/bin"
  if ! command -v protoc-gen-dart &> /dev/null; then
    echo "Installing protoc_plugin for Dart..." | tee -a $LOG_FILE
    (cd frontend && flutter pub global activate protoc_plugin)
    export PATH="$PATH":"$HOME/.pub-cache/bin"
  fi
fi

# Check for grpcwebproxy
if ! command -v grpcwebproxy &> /dev/null; then
  echo "Installing grpcwebproxy..." | tee -a $LOG_FILE
  go install github.com/improbable-eng/grpc-web/go/grpcwebproxy@latest
  export PATH="$PATH":"$HOME/go/bin"
  if ! command -v grpcwebproxy &> /dev/null; then
    echo "Failed to install grpcwebproxy. Please install manually with:" | tee -a $LOG_FILE
    echo "  go install github.com/improbable-eng/grpc-web/go/grpcwebproxy@latest" | tee -a $LOG_FILE
    exit 1
  fi
fi

# Generate Dart proto files for frontend
echo "Generating Dart proto files from central proto directory..." | tee -a $LOG_FILE
mkdir -p frontend/lib/generated
protoc --proto_path=proto --dart_out=grpc:frontend/lib/generated proto/*.proto
echo "Proto generation complete." | tee -a $LOG_FILE

# Check if dashboard_screen.dart uses 'Node' instead of 'ClusterNode'
if grep -q "List<Node>" frontend/lib/screens/dashboard_screen.dart; then
  echo "Fixing Node references in dashboard_screen.dart to use ClusterNode..." | tee -a $LOG_FILE
  sed -i 's/List<Node>/List<ClusterNode>/g' frontend/lib/screens/dashboard_screen.dart
  sed -i 's/Widget _buildNodeCard(Node node)/Widget _buildNodeCard(ClusterNode node)/g' frontend/lib/screens/dashboard_screen.dart
  echo "Fixed Node references in dashboard_screen.dart." | tee -a $LOG_FILE
fi

# Build badger with Bazel
echo "Building badger with Bazel..." | tee -a $LOG_FILE
bazel build //badger/cmd:badger
echo "Build complete." | tee -a $LOG_FILE

# Find available ports
BADGER_PORT=9090
if command -v lsof &> /dev/null; then
  BADGER_PORT=$(find_available_port 9090)
fi

PROXY_PORT=8090
if command -v lsof &> /dev/null; then
  PROXY_PORT=$(find_available_port 8090)
fi

FLUTTER_PORT=8080
if command -v lsof &> /dev/null; then
  FLUTTER_PORT=$(find_available_port 8080)
fi

# Start services in local mode
echo "Starting services..." | tee -a $LOG_FILE

# Start Badger service with local mode flag
echo "Starting Badger service on port $BADGER_PORT..." | tee -a $LOG_FILE
bazel run //badger/cmd:badger -- --local-mode --grpc-addr=:$BADGER_PORT >> $LOG_FILE 2>&1 &
BADGER_PID=$!
echo "Started Badger (PID: $BADGER_PID)" | tee -a $LOG_FILE
sleep 2

# Start gRPC-Web proxy for browser support with correct flags
echo "Starting gRPC-Web proxy on port $PROXY_PORT..." | tee -a $LOG_FILE
grpcwebproxy \
  --backend_addr=localhost:$BADGER_PORT \
  --run_tls_server=false \
  --allow_all_origins \
  --allowed_headers=* \
  --use_websockets \
  --websocket_ping_interval=30s \
  --server_http_debug_port=$PROXY_PORT >> $LOG_FILE 2>&1 &
PROXY_PID=$!
echo "Started gRPC-Web proxy (PID: $PROXY_PID)" | tee -a $LOG_FILE
sleep 2

# Start Frontend service
echo "Starting Frontend at http://localhost:$FLUTTER_PORT..." | tee -a $LOG_FILE
(cd frontend && flutter pub get && flutter run -d web-server --web-port=$FLUTTER_PORT --dart-define=BADGER_GRPC_URL=localhost:$PROXY_PORT) >> $LOG_FILE 2>&1 &
FRONTEND_PID=$!
echo "Started Frontend (PID: $FRONTEND_PID)" | tee -a $LOG_FILE

echo "Services started:" | tee -a $LOG_FILE
echo "- Badger: gRPC at localhost:$BADGER_PORT (local mode)" | tee -a $LOG_FILE
echo "- gRPC-Web proxy: http://localhost:$PROXY_PORT" | tee -a $LOG_FILE
echo "- Frontend: http://localhost:$FLUTTER_PORT" | tee -a $LOG_FILE
echo "Log file: $LOG_FILE" | tee -a $LOG_FILE
echo "Press Ctrl+C to stop" | tee -a $LOG_FILE

wait 