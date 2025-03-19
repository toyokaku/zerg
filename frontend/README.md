# Frontend Application

Web UI for the Zerg system.

## Overview

Provides a responsive interface for managing and monitoring the system. Communicates with the Badger API to control ML jobs.

## Directory Structure

```
frontend/
├── lib/                # Flutter code
│   ├── main.dart       # Entry point
│   ├── screens/        # UI screens
│   ├── widgets/        # UI components
│   ├── models/         # Data models
│   └── services/       # API services
├── pubspec.yaml        # Dependencies
└── k8s/                # Service-specific manifests
```

## Key Components

### Flutter Web Application

Built using Flutter for web, providing:

- Job management
- System monitoring
- Configuration settings
- User management

### Kubernetes Manifests

The `k8s/` directory contains service-specific manifests:

- **Deployment**: Service deployment
- **Service**: Web app exposure
- **IngressRoute**: Traffic routing

## Deployment

Built as a static web application:

```bash
flutter build web
``` 