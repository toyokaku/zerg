# Overmind Service

Compute service for ML workloads with GPU acceleration.

## Overview

Provides GPU-accelerated machine learning capabilities. Communicates with the Badger service to receive and process ML tasks.

## Directory Structure

```
overmind/
├── cmd/                # Entry points
├── internal/           # Core packages
│   ├── api/            # API handlers
│   ├── config/         # Configuration
│   ├── containerd/     # Containerd integration
│   ├── ml/             # ML models and utilities
│   └── gpu/            # GPU management
├── k8s/                # Service-specific manifests
└── nvidia/             # GPU runtime configs
```

## Key Components

### GPU Configuration

The `nvidia/` directory contains GPU-specific configurations:

- **RuntimeClass**: Defines the runtime for Kubernetes
- **Device Plugin**: Exposes GPU resources
- **Containerd Config**: Runtime configuration
- **Setup Script**: Automates runtime setup

### Kubernetes Manifests

The `k8s/` directory contains service-specific manifests:

- **ConfigMap**: Service configuration
- **Deployment**: Service deployment with GPU resources
- **Service**: API exposure

## Deployment

Deployed using containerd as the runtime. Binary built with:

```bash
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o overmind ./cmd
``` 