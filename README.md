# Zerg - Distributed Compute and Media Orchestration Platform

A cross-device distributed compute and media orchestration platform that allows trusted devices to collaborate and share compute, storage, and smart home functionalities.

## Overview

Zerg is a distributed platform that enables devices registered to the same mesh to coordinate tasks like AI inference, media sharing, photo storage, and more. Each device installs the Zerg app, which includes a Flutter-based frontend UI and a Go-based backend agent compiled into a single binary.

## Components

- **Device Registry Service**: Manages device registration, heartbeats, and capabilities
- **Task Router**: Distributed task scheduler and executor
- **Filesystem Service**: Cross-device file access and synchronization
- **Frontend**: Flutter-based UI for monitoring and managing the device mesh
- **Extensions**:
  - **Overmind**: AI compute extension for devices with GPUs/TPUs
  - **Media**: Media streaming and transcoding extension

## Project Structure

```
zerg/
├── badger/                 # Controller service (handles device coordination)
│   ├── cmd/                # Command-line entry points
│   └── internal/           # Service implementations
├── frontend/               # Flutter-based UI application
│   └── lib/                # Frontend code
├── overmind/               # AI compute extension
├── proto/                  # Protocol buffer definitions
│   ├── device_registry.proto  # Device registry service
│   ├── task_router.proto      # Task router service
│   └── filesystem.proto       # Filesystem service
└── scripts/                # Development and deployment scripts
```

## Key Features

### Shared Photo System

- All devices running Zerg can save photos to `//photo/` directory
- Photos are automatically indexed and exposed to the mesh
- Target devices with storage receive synced copies under `//backup/`
- Any device can browse shared photos via the mesh

### Device Management

- Devices register with the mesh and maintain heartbeats
- Each device advertises its capabilities (GPU, storage, etc.)
- Tasks are routed to devices based on their capabilities
- Devices can be monitored through the UI dashboard

## Quick Start

### Prerequisites

- Go 1.21 or higher
- Flutter 3.16.0 or higher
- Protocol Buffers compiler (protoc)

### Building and Running

```bash
# Build the backend
go build -o zerg ./badger/cmd/badger

# Run the controller daemon
./zerg --port=9090

# Build and run the Flutter frontend
cd frontend
flutter run
```

## Development

### Generating Protocol Buffers

```bash
# Generate Go code
protoc --go_out=. --go-grpc_out=. proto/*.proto

# Generate Dart code for Flutter
cd frontend
dart run build_runner build
```

## Deployment

For production deployment:

```bash
# Apply secrets
./scripts/apply-secrets.sh

# Build and deploy
go build -o zerg ./badger/cmd/badger
```
