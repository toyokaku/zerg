# Badger Service

Gateway service that manages the K3s cluster and handles API requests.

## Overview

Central coordinator for the Zerg project. Manages the Kubernetes cluster, handles API requests, and coordinates with the Overmind service for ML tasks.

## Directory Structure

```
badger/
├── cmd/                # Entry points
├── internal/           # Core packages
│   ├── api/            # API handlers
│   ├── config/         # Configuration
│   ├── containerd/     # Containerd integration
│   └── k8s/            # K8s client utilities
├── k3s/                # Cluster-wide configs
└── k8s/                # Service-specific manifests
```

## Key Components

### K3s Configuration

The `k3s/` directory contains cluster-wide configurations:

- **Traefik**: Routing with internal/external access
- **Cert-Manager**: TLS certificates
- **NATS**: Messaging

### Kubernetes Manifests

The `k8s/` directory contains service-specific manifests:

- **ConfigMap**: Service configuration
- **Deployment**: Service deployment
- **Service**: API exposure

## Deployment

Deployed using containerd as the runtime. Binary built with:

```bash
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o badger ./cmd
``` 