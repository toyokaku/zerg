package main

import (
	"context"
	"flag"
	"log"
	"net"
	"os"
	"os/signal"
	"sync/atomic"
	"syscall"
	"time"

	pb "github.com/zerg/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var (
	grpcAddr  = flag.String("grpc-addr", ":9090", "gRPC listen address")
	localMode = flag.Bool("local-mode", false, "Run in local mode with mock data")
)

// NodeService implements the NodeService gRPC service
type NodeService struct {
	pb.UnimplementedNodeServiceServer
	pingCount int32
	localMode bool
}

// GetNodes returns a list of nodes
func (s *NodeService) GetNodes(ctx context.Context, req *pb.GetNodesRequest) (*pb.GetNodesResponse, error) {
	// In local mode, return mock data
	if s.localMode {
		log.Println("GetNodes called - returning mock data")
		return &pb.GetNodesResponse{
			Nodes: []*pb.ClusterNode{
				{
					Name:     "node1",
					IsOnline: true,
					Role:     "worker",
					Resources: map[string]*pb.ResourceInfo{
						"cpu":     {Used: 2.0, Total: 8.0},
						"memory":  {Used: 4.0, Total: 16.0},
						"storage": {Used: 100.0, Total: 500.0},
					},
					LastSeen: time.Now().Format(time.RFC3339),
				},
				{
					Name:     "node2",
					IsOnline: true,
					Role:     "master",
					Resources: map[string]*pb.ResourceInfo{
						"cpu":     {Used: 1.0, Total: 4.0},
						"memory":  {Used: 2.0, Total: 8.0},
						"storage": {Used: 50.0, Total: 250.0},
					},
					LastSeen: time.Now().Format(time.RFC3339),
				},
			},
		}, nil
	}

	// In normal mode, would collect data from Kubernetes
	return &pb.GetNodesResponse{Nodes: []*pb.ClusterNode{}}, nil
}

// Ping responds to ping requests and counts them
func (s *NodeService) Ping(ctx context.Context, req *pb.PingRequest) (*pb.PingResponse, error) {
	count := atomic.AddInt32(&s.pingCount, 1)
	log.Printf("Ping called with message: %s (count: %d)", req.Message, count)
	return &pb.PingResponse{
		Message:   "Pong: " + req.Message,
		Timestamp: time.Now().Unix(),
		PingCount: count,
	}, nil
}

// GetStats returns basic stats about the server
func (s *NodeService) GetStats(ctx context.Context, req *pb.StatsRequest) (*pb.StatsResponse, error) {
	log.Println("GetStats called")
	return &pb.StatsResponse{
		ServerName:    "Badger Service",
		Version:       "1.0.0",
		UptimeSeconds: 300, // Placeholder
		Stats: []*pb.SystemStat{
			{Name: "Ping Count", Value: float64(s.pingCount), Unit: "requests"},
		},
	}, nil
}

func main() {
	flag.Parse()

	// Set up logger
	logger := log.New(os.Stdout, "badger: ", log.LstdFlags)
	logger.Println("Starting badger service...")

	// Check for local mode from environment
	if !*localMode && (os.Getenv("LOCAL_MODE") != "" || os.Getenv("NO_K8S") != "") {
		*localMode = true
		logger.Println("Running in local mode (set by environment variable)")
	}

	// Log local mode status
	if *localMode {
		logger.Println("Running in local mode with mock data")
	} else {
		logger.Println("Running in normal mode with Kubernetes integration")
	}

	// Create gRPC server
	grpcServer := grpc.NewServer()

	// Register services
	nodeService := &NodeService{localMode: *localMode}
	pb.RegisterNodeServiceServer(grpcServer, nodeService)

	// Enable reflection for debugging
	reflection.Register(grpcServer)

	// Start gRPC server
	grpcListener, err := net.Listen("tcp", *grpcAddr)
	if err != nil {
		logger.Fatalf("Failed to listen on %s: %v", *grpcAddr, err)
	}

	// Start server in a goroutine
	go func() {
		logger.Printf("gRPC server started on %s", *grpcAddr)
		if err := grpcServer.Serve(grpcListener); err != nil {
			logger.Fatalf("Failed to serve gRPC: %v", err)
		}
	}()

	// Handle graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Println("Shutting down...")
	grpcServer.GracefulStop()
	logger.Println("Badger service stopped")
}
