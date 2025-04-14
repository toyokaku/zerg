package main

import (
	"context"
	"flag"
	"log"
	"net"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"github.com/zerg/badger/internal/service"
	"github.com/zerg/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

var (
	grpcAddr   = flag.String("grpc-addr", ":9090", "gRPC listen address")
	dataDir    = flag.String("data-dir", "./data", "Data directory")
	photoDir   = flag.String("photo-dir", "", "Photo directory (default: data/photo)")
	isStorage  = flag.Bool("storage", false, "Register this device as a storage node")
	deviceName = flag.String("name", "", "Device name (default: hostname)")
	deviceType = flag.String("type", "", "Device type (controller, compute, storage, mobile, desktop)")
)

func main() {
	flag.Parse()

	// Set up logger
	logger := log.New(os.Stdout, "badger: ", log.LstdFlags)
	logger.Println("Starting Zerg agent...")

	// Create data directories
	if err := os.MkdirAll(*dataDir, 0755); err != nil {
		logger.Fatalf("Failed to create data directory: %v", err)
	}

	// Set default photo dir if not specified
	photoDirectory := *photoDir
	if photoDirectory == "" {
		photoDirectory = filepath.Join(*dataDir, "photo")
	}
	if err := os.MkdirAll(photoDirectory, 0755); err != nil {
		logger.Fatalf("Failed to create photo directory: %v", err)
	}

	// Create backup directory
	backupDir := filepath.Join(*dataDir, "backup")
	if err := os.MkdirAll(backupDir, 0755); err != nil {
		logger.Fatalf("Failed to create backup directory: %v", err)
	}

	// Determine device name and type
	name := *deviceName
	if name == "" {
		hostname, err := os.Hostname()
		if err != nil {
			hostname = "unknown-device"
		}
		name = hostname
	}

	// Determine device type
	deviceTypeEnum := proto.DeviceType_DEVICE_TYPE_DESKTOP // default
	if *deviceType != "" {
		switch *deviceType {
		case "controller":
			deviceTypeEnum = proto.DeviceType_DEVICE_TYPE_CONTROLLER
		case "compute":
			deviceTypeEnum = proto.DeviceType_DEVICE_TYPE_COMPUTE
		case "storage":
			deviceTypeEnum = proto.DeviceType_DEVICE_TYPE_STORAGE
		case "mobile":
			deviceTypeEnum = proto.DeviceType_DEVICE_TYPE_MOBILE
		case "desktop":
			deviceTypeEnum = proto.DeviceType_DEVICE_TYPE_DESKTOP
		default:
			logger.Printf("Unknown device type: %s, using desktop", *deviceType)
		}
	}

	// Create gRPC server
	grpcServer := grpc.NewServer()

	// Create and register services
	deviceRegistry := service.NewDeviceRegistry()
	taskRouter := service.NewTaskRouter(deviceRegistry)
	filesystemService := service.NewFilesystemService(deviceRegistry)

	// Link services together
	taskRouter.SetFilesystemService(filesystemService)
	filesystemService.SetTaskRouter(taskRouter)

	// Register services with gRPC server
	proto.RegisterDeviceRegistryServiceServer(grpcServer, deviceRegistry)
	proto.RegisterTaskRouterServiceServer(grpcServer, taskRouter)
	proto.RegisterFilesystemServiceServer(grpcServer, filesystemService)

	// Enable reflection for debugging
	reflection.Register(grpcServer)

	// Set up the local device
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Create capabilities map based on device role
	capabilities := make(map[string]string)
	if *isStorage {
		capabilities["role"] = "storage"
	}

	// Create resource info
	resources := make(map[string]*proto.ResourceInfo)

	// Add basic resources
	resources["cpu"] = &proto.ResourceInfo{
		Used:  0,
		Total: float64(getNumCPUs()),
	}

	memoryInfo := getMemoryInfo()
	resources["memory"] = &proto.ResourceInfo{
		Used:  memoryInfo.Used,
		Total: memoryInfo.Total,
	}

	storageInfo := getStorageInfo(*dataDir)
	resources["storage"] = &proto.ResourceInfo{
		Used:  storageInfo.Used,
		Total: storageInfo.Total,
		Unit:  "MB",
	}

	// Register this device with the registry
	resp, err := deviceRegistry.RegisterDevice(ctx, &proto.RegisterDeviceRequest{
		Name:         name,
		IpAddress:    getLocalIP(),
		Type:         deviceTypeEnum,
		Resources:    resources,
		Capabilities: capabilities,
	})

	if err != nil {
		logger.Printf("Warning: Failed to register local device: %v", err)
	} else {
		logger.Printf("Registered local device: %s (ID: %s)", name, resp.Device.Id)

		// Register device paths with filesystem service
		filesystemService.RegisterDeviceRootPath(resp.Device.Id, *dataDir)

		// Start watching the photo directory for new photos
		if photoDirectory != "" {
			photoRelPath, err := filepath.Rel(*dataDir, photoDirectory)
			if err != nil {
				photoRelPath = "photo" // Default if relative path can't be determined
			}

			_, err = filesystemService.WatchDirectory(context.Background(), &proto.WatchChangesRequest{
				DeviceId:    resp.Device.Id,
				Paths:       []string{photoRelPath},
				Recursive:   true,
				ChangeTypes: []proto.FileChangeType{proto.FileChangeType_FILE_CHANGE_TYPE_CREATED},
			})

			if err != nil {
				logger.Printf("Warning: Failed to start watching photo directory: %v", err)
			} else {
				logger.Printf("Started watching photo directory: %s", photoDirectory)
			}
		}
	}

	// Start background status updater
	go updateStatus(deviceRegistry, resp.Device.Id)

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
	logger.Println("Server stopped")
}

func updateStatus(registry *service.DeviceRegistry, deviceID string) {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for {
		<-ticker.C

		// Update device status
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)

		// Get updated resource info
		resources := make(map[string]*proto.ResourceInfo)

		// Add basic resources
		resources["cpu"] = &proto.ResourceInfo{
			Used:  getCPUUsage(),
			Total: float64(getNumCPUs()),
		}

		memoryInfo := getMemoryInfo()
		resources["memory"] = &proto.ResourceInfo{
			Used:  memoryInfo.Used,
			Total: memoryInfo.Total,
		}

		storageInfo := getStorageInfo(*dataDir)
		resources["storage"] = &proto.ResourceInfo{
			Used:  storageInfo.Used,
			Total: storageInfo.Total,
			Unit:  "MB",
		}

		// Update device status
		_, err := registry.UpdateDeviceStatus(ctx, &proto.UpdateDeviceStatusRequest{
			DeviceId:  deviceID,
			Status:    proto.DeviceStatus_DEVICE_STATUS_ONLINE,
			Resources: resources,
		})

		cancel()

		if err != nil {
			log.Printf("Failed to update device status: %v", err)
		}
	}
}

// Helper function to get the number of CPUs
func getNumCPUs() int {
	// This would be platform-specific in a real implementation
	// For simplicity, just return a constant value
	return 4
}

// Helper function to get CPU usage
func getCPUUsage() float64 {
	// This would be platform-specific in a real implementation
	// For simplicity, just return a random value
	return 1.0 + 2.0*float64(time.Now().Unix()%3)
}

type MemoryInfo struct {
	Used  float64
	Total float64
}

// Helper function to get memory info
func getMemoryInfo() MemoryInfo {
	// This would be platform-specific in a real implementation
	// For simplicity, just return constant values
	return MemoryInfo{
		Used:  2048.0,
		Total: 8192.0,
	}
}

type StorageInfo struct {
	Used  float64
	Total float64
}

// Helper function to get storage info
func getStorageInfo(path string) StorageInfo {
	// This would use something like statvfs in a real implementation
	// For simplicity, just return constant values
	return StorageInfo{
		Used:  10240.0,  // 10 GB
		Total: 102400.0, // 100 GB
	}
}

// Helper function to get the local IP address
func getLocalIP() string {
	// This would determine the actual IP in a real implementation
	// For simplicity, just return a placeholder
	return "127.0.0.1"
}
