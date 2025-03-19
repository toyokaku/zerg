package main

import (
	"context"
	"flag"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var (
	grpcAddr  = flag.String("grpc-addr", ":9090", "gRPC listen address")
	localMode = flag.Bool("local-mode", false, "Run in local mode without K8s")
)

// Simple types for our service
type PingRequest struct {
	NodeId string
}

type PingResponse struct {
	Message   string
	Timestamp int64
}

type StatsRequest struct {
	NodeId string
}

type SystemStat struct {
	CpuUsage    float64
	MemoryUsage float64
	DiskUsage   float64
}

type StatsResponse struct {
	Stats *SystemStat
}

// NodeServiceServer is the server API for NodeService service.
type NodeServiceServer interface {
	Ping(context.Context, *PingRequest) (*PingResponse, error)
	Stats(context.Context, *StatsRequest) (*StatsResponse, error)
}

// NodeServiceImpl implements NodeServiceServer
type NodeServiceImpl struct {
	logger *log.Logger
}

// Ensure we implement the interface
var _ NodeServiceServer = &NodeServiceImpl{}

// Ping implements NodeServiceServer.Ping
func (s *NodeServiceImpl) Ping(ctx context.Context, req *PingRequest) (*PingResponse, error) {
	s.logger.Printf("Received ping from node: %s", req.NodeId)
	return &PingResponse{
		Message:   "Pong from badger server",
		Timestamp: time.Now().Unix(),
	}, nil
}

// Stats implements NodeServiceServer.Stats
func (s *NodeServiceImpl) Stats(ctx context.Context, req *StatsRequest) (*StatsResponse, error) {
	s.logger.Printf("Received stats request for node: %s", req.NodeId)
	
	// In a real implementation, we would get actual system stats
	// For now, return dummy values
	return &StatsResponse{
		Stats: &SystemStat{
			CpuUsage:    12.5,
			MemoryUsage: 34.2,
			DiskUsage:   45.7,
		},
	}, nil
}

// Register the service with gRPC server
func RegisterNodeServiceServer(s *grpc.Server, srv NodeServiceServer) {
	s.RegisterService(&_NodeService_serviceDesc, srv)
}

// Service descriptor
var _NodeService_serviceDesc = grpc.ServiceDesc{
	ServiceName: "zerg.node.NodeService",
	HandlerType: (*NodeServiceServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "Ping",
			Handler:    _NodeService_Ping_Handler,
		},
		{
			MethodName: "Stats",
			Handler:    _NodeService_Stats_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "internal/proto/node_service.proto",
}

// Handler functions
func _NodeService_Ping_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(PingRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(NodeServiceServer).Ping(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/zerg.node.NodeService/Ping",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(NodeServiceServer).Ping(ctx, req.(*PingRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _NodeService_Stats_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(StatsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(NodeServiceServer).Stats(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/zerg.node.NodeService/Stats",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(NodeServiceServer).Stats(ctx, req.(*StatsRequest))
	}
	return interceptor(ctx, in, info, handler)
}

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

	// Set up gRPC server
	logger.Printf("Starting gRPC server on %s...\n", *grpcAddr)
	grpcServer := grpc.NewServer()

	// Register our service
	nodeService := &NodeServiceImpl{logger: logger}
	RegisterNodeServiceServer(grpcServer, nodeService)

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
