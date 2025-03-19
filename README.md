# Zerg - K3s Cluster Manager

This repository contains the Zerg project, a suite of services for managing and monitoring K3s clusters.

## Components

- **Badger**: A gRPC service that provides node information and metrics from the K3s cluster
- **Frontend**: A web interface for monitoring and managing the K3s cluster
- **Gateway**: A Traefik-based gateway for routing traffic to services

## Project Structure

```
zerg/
├── badger/                 # Badger service source code
│   ├── cmd/                # Command-line entry points
│   │   └── badger/         # Main badger service
│   └── internal/           # Internal packages
│       ├── k3s/            # K3s client interface
│       ├── proto/          # Protocol buffer definitions
│       └── service/        # Service implementations
├── build/                  # Build artifacts
├── frontend/               # Frontend web application
├── k3s/                    # K3s manifests
│   ├── badger/             # Badger deployment manifests
│   ├── core/               # Core infrastructure manifests
│   ├── frontend/           # Frontend deployment manifests 
│   └── ingress/            # Ingress configuration
├── logs/                   # Log files
├── proto/                  # Protocol buffer definition files
├── scripts/                # Deployment scripts
└── tools/                  # Development tools
    └── scripts/            # Build and test scripts
```

## Quick Start

### Building and Running the Badger Service

```bash
# Generate protocol buffers and build the badger service
./tools/scripts/build_proto.sh

# Run the badger service in local mode
./build/badger --local-mode
```

### Building and Running the Frontend

```bash
# Navigate to the frontend directory
cd frontend

# Generate proto code
export PATH="$PATH":"$HOME/.pub-cache/bin"
./generate_protos.sh

# Run in development mode
flutter run -d chrome
```

### Testing the Badger Service

```bash
# Run the test script to build, start and test the badger service
./tools/scripts/test_service.sh
```

### Testing with grpcurl

If you have [grpcurl](https://github.com/fullstorydev/grpcurl) installed:

```bash
# List available services
grpcurl -plaintext localhost:9090 list

# Test the Ping method
grpcurl -plaintext -d '{"message":"Test ping"}' localhost:9090 proto.NodeService/Ping

# Get server stats
grpcurl -plaintext -d '{}' localhost:9090 proto.NodeService/GetStats

# Get nodes (empty in local mode)
grpcurl -plaintext -d '{}' localhost:9090 proto.NodeService/GetNodes
```

## Deployment

For production deployment:

```bash
# Build and deploy in production mode
./scripts/deploy_gateway.sh -h your-gateway-host.example.com
```

## Development

### Requirements

- Go 1.18 or higher
- Protocol Buffers compiler (protoc)
- Go Protocol Buffers plugins:
  ```bash
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
  ```
- Flutter 3.0 or higher for frontend development
- Dart Protocol Buffers plugin:
  ```bash
  dart pub global activate protoc_plugin
  ```

### Workflow

1. Make changes to the protocol buffer definitions in the `proto/` directory
2. Run `./tools/scripts/build_proto.sh` to generate code for the backend
3. For the frontend: `cd frontend && ./generate_protos.sh` to generate Dart code
4. Test your changes with `./tools/scripts/test_service.sh`
5. Test the frontend with `cd frontend && flutter run -d chrome`
