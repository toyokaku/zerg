package main

import (
	"flag"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/nats-io/nats.go"
	"google.golang.org/grpc"
)

var (
	grpcAddr = flag.String("grpc-addr", ":9090", "gRPC listen address")
	natsURL  = flag.String("nats-url", "nats://nats:4222", "NATS server URL")
)

func main() {
	flag.Parse()

	// Set up logger
	logger := log.New(os.Stdout, "overmind: ", log.LstdFlags)
	logger.Println("Starting overmind service...")

	// Connect to NATS
	logger.Printf("Connecting to NATS at %s...\n", *natsURL)
	nc, err := nats.Connect(*natsURL,
		nats.RetryOnFailedConnect(true),
		nats.MaxReconnects(10),
		nats.ReconnectWait(time.Second*5))
	if err != nil {
		logger.Fatalf("Failed to connect to NATS: %v", err)
	}
	defer nc.Close()
	logger.Println("Connected to NATS")

	// Set up JetStream
	js, err := nc.JetStream()
	if err != nil {
		logger.Fatalf("Failed to create JetStream context: %v", err)
	}

	// Create streams for job data
	_, err = js.AddStream(&nats.StreamConfig{
		Name:     "JOBS",
		Subjects: []string{"jobs.>"},
		Storage:  nats.FileStorage,
	})
	if err != nil {
		logger.Printf("Warning: Failed to create JOBS stream: %v", err)
	}

	// Set up gRPC server
	logger.Printf("Starting gRPC server on %s...\n", *grpcAddr)
	grpcServer := grpc.NewServer()
	// Register services here
	// api.RegisterOvermindServiceServer(grpcServer, overmindService)

	// Start gRPC server
	grpcListener, err := net.Listen("tcp", *grpcAddr)
	if err != nil {
		logger.Fatalf("Failed to listen on %s: %v", *grpcAddr, err)
	}

	go func() {
		if err := grpcServer.Serve(grpcListener); err != nil {
			logger.Fatalf("Failed to serve gRPC: %v", err)
		}
	}()
	logger.Printf("gRPC server started on %s", *grpcAddr)

	// Set up containerd client
	// TODO: Implement containerd client for managing containers

	// Set up Kubernetes client
	// TODO: Implement Kubernetes client for managing jobs

	// Handle graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Println("Shutting down...")

	// Gracefully stop gRPC server
	grpcServer.GracefulStop()
	logger.Println("gRPC server stopped")

	logger.Println("Overmind service stopped")
} 