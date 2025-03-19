package main

import (
	"encoding/json"
	"flag"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/toyokaku/zerg/badger/internal/k3s"
	"github.com/toyokaku/zerg/badger/internal/proto"
	"github.com/toyokaku/zerg/badger/internal/service"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var (
	grpcAddr  = flag.String("grpc-addr", ":9090", "gRPC listen address")
	webAddr   = flag.String("web-addr", ":8090", "gRPC-web proxy listen address")
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

	// Create K3s client (optional in local mode)
	var k3sClient *k3s.Client
	if !*localMode {
		logger.Println("Creating K3s client...")
		var err error
		k3sClient, err = k3s.NewClient()
		if err != nil {
			logger.Printf("Warning: Failed to create K3s client: %v", err)
		} else {
			logger.Println("K3s client created")
		}
	} else {
		logger.Println("Skipping K3s client in local mode")
		k3sClient = &k3s.Client{Disabled: true}
	}

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

	// Set up gRPC-web proxy
	logger.Printf("Starting gRPC-web proxy on %s...\n", *webAddr)
	webMux := http.NewServeMux()
	webMux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Handle CORS
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "*")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		// Handle gRPC-web requests
		if strings.Contains(r.URL.Path, "NodeService") {
			w.Header().Set("Content-Type", "application/json")

			// Get mock data based on the endpoint
			var responseData []byte
			switch {
			case strings.Contains(r.URL.Path, "GetNodes"):
				responseData = getMockNodesResponse()
			case strings.Contains(r.URL.Path, "Ping"):
				responseData = getMockPingResponse()
			case strings.Contains(r.URL.Path, "GetStats"):
				responseData = getMockStatsResponse()
			default:
				http.Error(w, "Not found", http.StatusNotFound)
				return
			}
			w.Write(responseData)
			return
		}

		http.Error(w, "Not found", http.StatusNotFound)
	})

	// Start web server in a goroutine
	go func() {
		if err := http.ListenAndServe(*webAddr, webMux); err != nil {
			logger.Fatalf("Failed to serve gRPC-web: %v", err)
		}
	}()
	logger.Printf("gRPC-web proxy started on %s", *webAddr)

	// Handle graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Println("Shutting down...")
	grpcServer.GracefulStop()
	logger.Println("Badger service stopped")
}

// Mock response functions
func getMockNodesResponse() []byte {
	response := map[string]interface{}{
		"nodes": []map[string]interface{}{
			{
				"name":     "gateway",
				"isOnline": true,
				"role":     "master",
				"resources": map[string]map[string]float64{
					"cpu":     {"used": 0.3, "total": 4.0},
					"memory":  {"used": 1.2, "total": 8.0},
					"storage": {"used": 20.0, "total": 64.0},
				},
				"lastSeen": "2024-03-18T22:30:00Z",
			},
			{
				"name":     "compute",
				"isOnline": true,
				"role":     "worker",
				"resources": map[string]map[string]float64{
					"cpu":     {"used": 2.1, "total": 16.0},
					"memory":  {"used": 24.0, "total": 64.0},
					"storage": {"used": 120.0, "total": 500.0},
					"gpu":     {"used": 1.0, "total": 2.0},
				},
				"lastSeen": "2024-03-18T22:30:00Z",
			},
		},
	}
	data, _ := json.Marshal(response)
	return data
}

func getMockPingResponse() []byte {
	response := map[string]interface{}{
		"message":   "Pong: Ping from Flutter",
		"timestamp": 1679177400000,
		"pingCount": 1,
	}
	data, _ := json.Marshal(response)
	return data
}

func getMockStatsResponse() []byte {
	response := map[string]interface{}{
		"serverName":    "Badger Service",
		"version":       "1.0.0",
		"uptimeSeconds": 300,
		"stats": []map[string]interface{}{
			{"name": "Ping Count", "value": 1, "unit": "requests"},
			{"name": "Memory Usage", "value": 0, "unit": "MB"},
			{"name": "CPU Usage", "value": 0, "unit": "%"},
		},
	}
	data, _ := json.Marshal(response)
	return data
}
