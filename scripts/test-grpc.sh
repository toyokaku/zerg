#!/bin/bash
set -e

echo "Testing gRPC communication between services..."

# Make sure the services are running
if ! pgrep -f "bazel.*badger"; then
  echo "Badger service is not running. Start it with: bazel run //badger/cmd:badger"
  exit 1
fi

echo "Badger service is running."
echo "To test frontend-to-badger gRPC communication:"
echo "1. Open http://localhost:8080 in your browser"
echo "2. Check browser console for gRPC connection logs"
echo "3. Verify that data is being fetched from Badger"

echo "Done." 