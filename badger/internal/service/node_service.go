package service

import (
	"context"
	"fmt"
	"sync/atomic"
	"time"

	"github.com/toyokaku/zerg/badger/internal/k3s"
	"github.com/toyokaku/zerg/badger/internal/proto"
)

// NodeService implements the NodeService gRPC service
type NodeService struct {
	proto.UnimplementedNodeServiceServer
	k3sClient *k3s.Client
	pingCount int32
	startTime time.Time
}

// NewNodeService creates a new NodeService
func NewNodeService(k3sClient *k3s.Client) *NodeService {
	return &NodeService{
		k3sClient: k3sClient,
		startTime: time.Now(),
	}
}

// GetNodes implements the GetNodes method of the NodeService
func (s *NodeService) GetNodes(ctx context.Context, req *proto.GetNodesRequest) (*proto.GetNodesResponse, error) {
	if s.k3sClient.Disabled {
		// Return mock data when running in disabled/local mode
		return getMockNodes(), nil
	}

	// Get nodes from k3s
	k3sNodes, err := s.k3sClient.GetNodes(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get nodes: %w", err)
	}

	// Convert to protobuf format
	var nodes []*proto.Node
	for _, n := range k3sNodes {
		// Convert resources
		resources := make(map[string]*proto.ResourceInfo)
		for name, info := range n.Resources {
			resources[name] = &proto.ResourceInfo{
				Used:  info.Used,
				Total: info.Total,
			}
		}

		// Convert node
		nodes = append(nodes, &proto.Node{
			Name:      n.Name,
			IsOnline:  n.IsOnline,
			Role:      n.Role,
			Resources: resources,
			LastSeen:  n.LastSeen.Format(time.RFC3339),
		})
	}

	return &proto.GetNodesResponse{
		Nodes: nodes,
	}, nil
}

// Ping implements the Ping method of the NodeService
func (s *NodeService) Ping(ctx context.Context, req *proto.PingRequest) (*proto.PingResponse, error) {
	// Increment ping count
	count := atomic.AddInt32(&s.pingCount, 1)

	// Format timestamp
	timestamp := time.Now().UnixNano() / int64(time.Millisecond)

	// Return response
	return &proto.PingResponse{
		Message:   fmt.Sprintf("Pong: %s", req.Message),
		Timestamp: timestamp,
		PingCount: count,
	}, nil
}

// GetStats implements the GetStats method of the NodeService
func (s *NodeService) GetStats(ctx context.Context, req *proto.StatsRequest) (*proto.StatsResponse, error) {
	return &proto.StatsResponse{
		ServerName:    "Badger Service",
		Version:       "1.0.0",
		UptimeSeconds: int64(time.Since(s.startTime).Seconds()),
		Stats: []*proto.SystemStat{
			{Name: "Ping Count", Value: float64(atomic.LoadInt32(&s.pingCount)), Unit: "requests"},
			{Name: "Memory Usage", Value: 0, Unit: "MB"},
			{Name: "CPU Usage", Value: 0, Unit: "%"},
		},
	}, nil
}

// Helper function to generate mock node data
func getMockNodes() *proto.GetNodesResponse {
	now := time.Now().Format(time.RFC3339)

	// Create gateway node
	gatewayNode := &proto.Node{
		Name:     "gateway",
		IsOnline: true,
		Role:     "master",
		Resources: map[string]*proto.ResourceInfo{
			"cpu":     {Used: 0.3, Total: 4.0},
			"memory":  {Used: 1.2, Total: 8.0},
			"storage": {Used: 20.0, Total: 64.0},
		},
		LastSeen: now,
	}

	// Create compute node
	computeNode := &proto.Node{
		Name:     "compute",
		IsOnline: true,
		Role:     "worker",
		Resources: map[string]*proto.ResourceInfo{
			"cpu":     {Used: 2.1, Total: 16.0},
			"memory":  {Used: 24.0, Total: 64.0},
			"storage": {Used: 120.0, Total: 500.0},
			"gpu":     {Used: 1.0, Total: 2.0},
		},
		LastSeen: now,
	}

	// Create response with both nodes
	return &proto.GetNodesResponse{
		Nodes: []*proto.Node{gatewayNode, computeNode},
	}
}
