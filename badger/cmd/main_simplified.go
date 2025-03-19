package main

import (
	"flag"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/toyokaku/zerg/badger/internal/k3s"
	"github.com/toyokaku/zerg/badger/internal/proto"
	"github.com/toyokaku/zerg/badger/internal/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var (
	grpcAddr  = flag.String("grpc-addr", ":9090", "gRPC listen address")
	localMode = flag.Bool("local-mode", false, "Run in local mode without K8s")
)

func main() {
	flag.Parse()

	// Set up logger
	logger := log.New(os.Stdout, "badger: ", log.LstdFlags)
	logger.Println("Starting badger service...")

	// Check for local mode from environment
	if !*localMode && (os.Getenv("LOCAL_MODE") != "" || os.Getenv("NO_K8S") != "" || os.Getenv("DISABLE_K8S") != "") {
		*localMode = true
		logger.Println("Running in local mode (set by environment variable)")
	}

	// Create disabled K3s client in local mode
	k3sClient := &k3s.Client{Disabled: true}
	logger.Println("Using disabled K3s client in local mode")

	// Create node service
	nodeService := service.NewNodeService(k3sClient)

	// Set up gRPC server
	logger.Printf("Starting gRPC server on %s...\n", *grpcAddr)
	grpcServer := grpc.NewServer()

	// Register services
	proto.RegisterNodeServiceServer(grpcServer, nodeService)

	// Enable reflection for debugging
	reflection.Register(grpcServer)

	// Start gRPC server
	grpcListener, err := net.Listen("tcp", *grpcAddr)
	if err != nil {
		logger.Fatalf("Failed to listen on %s: %v", *grpcAddr, err)
	}

	// Start server in a goroutine
	go func() {
		if err := grpcServer.Serve(grpcListener); err != nil {
			logger.Fatalf("Failed to serve gRPC: %v", err)
		}
	}()
	logger.Printf("gRPC server started on %s", *grpcAddr)

	// Handle graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Println("Shutting down...")
	grpcServer.GracefulStop()
	logger.Println("Badger service stopped")
}
