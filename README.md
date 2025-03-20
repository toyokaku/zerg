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
├── frontend/               # Frontend web application
├── k3s/                    # K3s manifests
│   ├── badger/             # Badger deployment manifests
│   ├── core/               # Core infrastructure manifests
│   ├── frontend/           # Frontend deployment manifests 
│   └── ingress/            # Ingress configuration
├── overmind/               # Overmind service source code
├── proto/                  # Protocol buffer definition files
└── scripts/                # Development scripts
```

## Quick Start

### Prerequisites

- Bazel 6.0 or higher
- Go 1.21 or higher
- Flutter 3.16.0 or higher
- Protocol Buffers compiler (protoc)
- K3s cluster

### Building and Running Services

```bash
# Build all services
bazel build //...

# Run tests
bazel test //...

# Start services in local mode
./scripts/local_dev.sh
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
# Apply secrets
./scripts/apply-secrets.sh

# Deploy all services
bazel run //k3s:all_deployments -- --cluster=minikube
```

## Development

### Requirements

- Bazel 6.0 or higher
- Go 1.21 or higher
- Flutter 3.16.0 or higher
- Protocol Buffers compiler (protoc)

### Workflow

1. Make changes to the protocol buffer definitions in the `proto/` directory
2. Build and test your changes:
   ```bash
   bazel build //...
   bazel test //...
   ```
3. Run services locally:
   ```bash
   ./scripts/local_dev.sh
   ```
4. Deploy changes:
   ```bash
   bazel run //k3s:all_deployments -- --cluster=minikube
   ```
