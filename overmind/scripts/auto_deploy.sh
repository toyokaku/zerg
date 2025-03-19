#!/bin/bash

# Auto-deployment script for master node
# This script pulls the latest code from GitHub and deploys it

# Exit on error
set -e

# Configuration
REPO_URL=${REPO_URL:-"https://github.com/toyokaku/zerg.git"}
REPO_BRANCH=${REPO_BRANCH:-"main"}
WORK_DIR=${WORK_DIR:-"$HOME/zerg"}
GATEWAY_HOST=${GATEWAY_HOST:-""}
GATEWAY_USER=${GATEWAY_USER:-""}
GATEWAY_SSH_KEY=${GATEWAY_SSH_KEY:-""}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --repo)
      REPO_URL="$2"
      shift 2
      ;;
    --branch)
      REPO_BRANCH="$2"
      shift 2
      ;;
    --work-dir)
      WORK_DIR="$2"
      shift 2
      ;;
    --gateway-host)
      GATEWAY_HOST="$2"
      shift 2
      ;;
    --gateway-user)
      GATEWAY_USER="$2"
      shift 2
      ;;
    --gateway-key)
      GATEWAY_SSH_KEY="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "=== Auto-deployment Started ==="

# Check if the repository exists
if [ ! -d "$WORK_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL" -b "$REPO_BRANCH" "$WORK_DIR"
else
  echo "Updating repository..."
  cd "$WORK_DIR"
  git fetch
  git reset --hard origin/"$REPO_BRANCH"
fi

# Navigate to the repository
cd "$WORK_DIR"

# Check if there are any changes since last deployment
LAST_COMMIT=$(cat "$WORK_DIR/.last_deployed_commit" 2>/dev/null || echo "")
CURRENT_COMMIT=$(git rev-parse HEAD)

if [ "$LAST_COMMIT" == "$CURRENT_COMMIT" ]; then
  echo "No changes since last deployment. Exiting."
  exit 0
fi

# Run the deployment script
echo "Running deployment script..."
cd "$WORK_DIR/overmind/scripts"

# Build gateway connection arguments
GATEWAY_ARGS=""
if [ -n "$GATEWAY_HOST" ]; then
  GATEWAY_ARGS="--gateway-host $GATEWAY_HOST"
  
  if [ -n "$GATEWAY_USER" ]; then
    GATEWAY_ARGS="$GATEWAY_ARGS --gateway-user $GATEWAY_USER"
  fi
  
  if [ -n "$GATEWAY_SSH_KEY" ]; then
    GATEWAY_ARGS="$GATEWAY_ARGS --gateway-key $GATEWAY_SSH_KEY"
  fi
fi

# Run the deployment script
./deploy_master.sh $GATEWAY_ARGS

# Save the current commit hash
echo "$CURRENT_COMMIT" > "$WORK_DIR/.last_deployed_commit"

echo "=== Auto-deployment Completed ===" 