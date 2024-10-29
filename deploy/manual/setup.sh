#!/bin/bash
#
# * @description    Initial Setup Script
# * @author         ryutoyokaku
# * Copyright ©Pawgege LLC. All rights reserved. Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.
#

# Variables
MASTER_IP="192.168.1.100"  # Raspberry Pi IP
WORKER1_IP="192.168.1.101" # Coral Dev Board 1
WORKER2_IP="192.168.1.102" # Coral Dev Board 2
GPU_NODE_IP="192.168.1.103" # Linux Laptop

# On Raspberry Pi (Master Node)
setup_master() {
    # Install K3s
    curl -sfL https://get.k3s.io | sh -
    # Get node token
    NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
    echo "Node token: $NODE_TOKEN"
    
    # Install monitoring tools
    sudo apt-get update && sudo apt-get install -y \
        prometheus-node-exporter \
        golang-go \
        protobuf-compiler
    
    # Set up Go environment
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
    source ~/.bashrc
    
    # Install gRPC tools
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
}

# On Coral Dev Boards
setup_coral_worker() {
    # Install Docker
    sudo apt-get update && sudo apt-get install -y \
        docker.io \
        golang-go
    
    # Install K3s agent
    curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 \
        K3S_TOKEN=${NODE_TOKEN} sh -
    
    # Install TensorFlow C++
    sudo apt-get install -y \
        build-essential \
        cmake \
        git \
        libedgetpu1-std
    
    # Clone and build TensorFlow Lite
    git clone https://github.com/tensorflow/tensorflow.git
    cd tensorflow
    ./tensorflow/lite/tools/make/download_dependencies.sh
    ./tensorflow/lite/tools/make/build_lib.sh
}

# On Linux Laptop (GPU Node)
setup_gpu_node() {
    # Install CUDA and LibTorch
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
    sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
    sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
    sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
    sudo apt-get update && sudo apt-get install -y cuda-toolkit-11-0
    
    # Install LibTorch
    wget https://download.pytorch.org/libtorch/cu110/libtorch-cxx11-abi-shared-with-deps-1.7.1%2Bcu110.zip
    unzip libtorch-cxx11-abi-shared-with-deps-1.7.1+cu110.zip
    echo 'export TORCH_PATH=/path/to/libtorch' >> ~/.bashrc
    
    # Install K3s agent
    curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 \
        K3S_TOKEN=${NODE_TOKEN} sh -
}

# Main setup function
main() {
    echo "Starting distributed system setup..."
    
    # Run appropriate setup based on hostname
    case $(hostname) in
        "raspberrypi")
            setup_master
            ;;
        "coral-dev"*)
            setup_coral_worker
            ;;
        "gpu-node")
            setup_gpu_node
            ;;
        *)
            echo "Unknown hostname. Please run on supported device."
            exit 1
            ;;
    esac
    
    echo "Setup completed successfully!"
}

main "$@"