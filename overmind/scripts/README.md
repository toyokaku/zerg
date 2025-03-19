# Master Deployment Scripts

This directory contains scripts for deploying the Overmind service on the master node.

## Manual Deployment

The `deploy_master.sh` script deploys the Overmind service to a master node.

### Usage

```bash
# Manual deployment on the local machine
./deploy_master.sh

# Remote deployment
./deploy_master.sh --remote --host <master-host> --user <master-user> [--key <ssh-key-path>]

# With gateway connection (for K8s manifests)
./deploy_master.sh --gateway-host <gateway-host> --gateway-user <gateway-user> [--gateway-key <gateway-ssh-key-path>]
```

### Options

- `--remote`: Enable remote deployment mode
- `--host`: Specify the master host (IP address or hostname)
- `--user`: Specify the SSH user for the master host
- `--key`: Specify the SSH key file for authentication (optional)
- `--gateway-host`: Specify the gateway host for K8s manifests (optional)
- `--gateway-user`: Specify the SSH user for the gateway host (optional)
- `--gateway-key`: Specify the SSH key file for gateway authentication (optional)

## Auto-Deployment

The `auto_deploy.sh` script automatically pulls the latest code from GitHub and deploys it.

### Usage

```bash
# Basic usage
./auto_deploy.sh

# With options
./auto_deploy.sh --repo <repo-url> --branch <branch-name> --work-dir <working-directory> --gateway-host <gateway-host> --gateway-user <gateway-user> [--gateway-key <gateway-ssh-key-path>]
```

### Systemd Integration

The `zerg-auto-deploy.service` and `zerg-auto-deploy.timer` files can be used to set up automatic deployment as a systemd service.

1. Edit the `zerg-auto-deploy.service` file to set the correct user and gateway information
2. Install the service and timer:

```bash
sudo cp zerg-auto-deploy.service /etc/systemd/system/
sudo cp zerg-auto-deploy.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zerg-auto-deploy.timer
sudo systemctl start zerg-auto-deploy.timer
```

This will configure the master node to check for updates every 15 minutes and deploy them automatically. 