# Deployment Scripts

This directory contains scripts for deploying the Zerg system.

## Gateway Deployment

The `deploy_gateway.sh` script deploys the gateway components (badger service and frontend) to a gateway node.

### Usage

```bash
# Manual deployment on the local machine
./deploy_gateway.sh

# Remote deployment
./deploy_gateway.sh --remote --host <gateway-host> --user <gateway-user> [--key <ssh-key-path>]
```

### Options

- `--remote`: Enable remote deployment mode
- `--host`: Specify the gateway host (IP address or hostname)
- `--user`: Specify the SSH user for the gateway host
- `--key`: Specify the SSH key file for authentication (optional)

## Master Deployment

The master deployment scripts are located in the `overmind/scripts` directory.

### Manual Deployment

```bash
# Navigate to the overmind scripts directory
cd overmind/scripts

# Manual deployment on the local machine
./deploy_master.sh

# Remote deployment
./deploy_master.sh --remote --host <master-host> --user <master-user> [--key <ssh-key-path>]
```

### Auto-Deployment

The master node can be configured to automatically pull and deploy updates from GitHub:

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