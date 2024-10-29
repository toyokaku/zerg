<!--
 * @description    
 * @author         ryutoyokaku
 * Copyright ©Pawgege LLC. All rights reserved.
 * Use of this source code is governed by a BSD-style license in the LICENSE file.
-->

### Setup process step by step:
1. First, set up your development environment on your Ubuntu desktop:
```bash
# Install required tools
sudo apt update && sudo apt install -y \
    golang-go \
    protobuf-compiler \
    make \
    git

# Install Go protocol buffer plugins
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Add to PATH
export PATH="$PATH:$(go env GOPATH)/bin"
```
2. Create a Makefile at the root of your project:

```makefile
.PHONY: proto build test deploy

# Generate protocol buffer code
proto:
    protoc --go_out=. --go_opt=paths=source_relative \
        --go-grpc_out=. --go-grpc_opt=paths=source_relative \
        src/proto/*.proto

# Build control plane
build:
    go build -o bin/control-plane src/control-plane/cmd/main.go

# Run tests
test:
    go test ./...

# Deploy to devices
deploy:
    cd deploy/ansible && ansible-playbook -i inventory.yml playbooks/setup-all.yml
```
3. Initialize Go modules:

```bash
go mod init edge-compute-platform
go mod tidy
```
4. Generate the gRPC code:

```bash
make proto
```
5. Test the control plane locally:
```
```bash
make build
./bin/control-plane
```
### Verify the basic setup is working on all devices:
1. On the Raspberry Pi (master node):

```bash
# Check K3s status
sudo systemctl status k3s
# Get node list
sudo kubectl get nodes
```
2. On Coral Dev Boards:
```bash
# Check K3s agent status
sudo systemctl status k3s-agent
# Check Docker status
sudo systemctl status docker
```
3. On the GPU node:
```bash
# Check K3s agent status
sudo systemctl status k3s-agent
# Verify NVIDIA drivers
nvidia-smi
```