package service

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/zerg/proto"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// DeviceRegistry manages the registry of devices in the Zerg mesh
type DeviceRegistry struct {
	proto.UnimplementedDeviceRegistryServiceServer
	mu             sync.RWMutex
	devices        map[string]*proto.Device
	heartbeats     map[string]time.Time
	offlineTimeout time.Duration
}

// NewDeviceRegistry creates a new DeviceRegistry service
func NewDeviceRegistry() *DeviceRegistry {
	return &DeviceRegistry{
		devices:        make(map[string]*proto.Device),
		heartbeats:     make(map[string]time.Time),
		offlineTimeout: 60 * time.Second, // Consider devices offline after 60 seconds of no heartbeat
	}
}

// RegisterDevice implements the RegisterDevice RPC method
func (dr *DeviceRegistry) RegisterDevice(ctx context.Context, req *proto.RegisterDeviceRequest) (*proto.RegisterDeviceResponse, error) {
	dr.mu.Lock()
	defer dr.mu.Unlock()

	// Generate a unique ID for the device
	deviceID := uuid.New().String()

	// Create the device object
	device := &proto.Device{
		Id:            deviceID,
		Name:          req.Name,
		IpAddress:     req.IpAddress,
		IsOnline:      true,
		Type:          req.Type,
		Status:        proto.DeviceStatus_DEVICE_STATUS_ONLINE,
		Resources:     req.Resources,
		LastHeartbeat: time.Now().UnixMilli(),
		Capabilities:  req.Capabilities,
	}

	// Store the device in the registry
	dr.devices[deviceID] = device
	dr.heartbeats[deviceID] = time.Now()

	// Generate an auth token for the device
	// In production, this should be a proper JWT or other secure token
	authToken := fmt.Sprintf("zerg:%s:%s", deviceID, uuid.New().String())

	return &proto.RegisterDeviceResponse{
		Device:    device,
		AuthToken: authToken,
	}, nil
}

// UpdateDeviceStatus implements the UpdateDeviceStatus RPC method
func (dr *DeviceRegistry) UpdateDeviceStatus(ctx context.Context, req *proto.UpdateDeviceStatusRequest) (*proto.UpdateDeviceStatusResponse, error) {
	dr.mu.Lock()
	defer dr.mu.Unlock()

	deviceID := req.DeviceId
	device, exists := dr.devices[deviceID]
	if !exists {
		return nil, status.Errorf(codes.NotFound, "device with ID %s not found", deviceID)
	}

	// Update device fields
	device.Status = req.Status
	device.LastHeartbeat = time.Now().UnixMilli()
	device.IsOnline = true

	// Update resources if provided
	if req.Resources != nil {
		for key, resource := range req.Resources {
			device.Resources[key] = resource
		}
	}

	// Update capabilities if provided
	if req.Capabilities != nil {
		for key, capability := range req.Capabilities {
			device.Capabilities[key] = capability
		}
	}

	// Update heartbeat time
	dr.heartbeats[deviceID] = time.Now()

	return &proto.UpdateDeviceStatusResponse{
		Device: device,
	}, nil
}

// GetDeviceInfo implements the GetDeviceInfo RPC method
func (dr *DeviceRegistry) GetDeviceInfo(ctx context.Context, req *proto.GetDeviceInfoRequest) (*proto.GetDeviceInfoResponse, error) {
	dr.mu.RLock()
	defer dr.mu.RUnlock()

	deviceID := req.DeviceId
	device, exists := dr.devices[deviceID]
	if !exists {
		return nil, status.Errorf(codes.NotFound, "device with ID %s not found", deviceID)
	}

	return &proto.GetDeviceInfoResponse{
		Device: device,
	}, nil
}

// ListDevices implements the ListDevices RPC method
func (dr *DeviceRegistry) ListDevices(ctx context.Context, req *proto.ListDevicesRequest) (*proto.ListDevicesResponse, error) {
	dr.mu.RLock()
	defer dr.mu.RUnlock()

	// Update online status based on heartbeats before listing
	dr.updateOnlineStatus()

	var devices []*proto.Device
	for _, device := range dr.devices {
		// Apply filters
		if req.FilterType != proto.DeviceType_DEVICE_TYPE_UNSPECIFIED && device.Type != req.FilterType {
			continue
		}

		if req.OnlyOnline && !device.IsOnline {
			continue
		}

		if req.CapabilityFilter != "" {
			if _, hasCapability := device.Capabilities[req.CapabilityFilter]; !hasCapability {
				continue
			}
		}

		// Device passes all filters, add to response
		devices = append(devices, device)
	}

	return &proto.ListDevicesResponse{
		Devices: devices,
	}, nil
}

// RemoveDevice implements the RemoveDevice RPC method
func (dr *DeviceRegistry) RemoveDevice(ctx context.Context, req *proto.RemoveDeviceRequest) (*proto.RemoveDeviceResponse, error) {
	dr.mu.Lock()
	defer dr.mu.Unlock()

	deviceID := req.DeviceId
	_, exists := dr.devices[deviceID]
	if !exists {
		return nil, status.Errorf(codes.NotFound, "device with ID %s not found", deviceID)
	}

	// Remove the device from the registry
	delete(dr.devices, deviceID)
	delete(dr.heartbeats, deviceID)

	return &proto.RemoveDeviceResponse{
		Success: true,
		Message: fmt.Sprintf("Device %s removed successfully", deviceID),
	}, nil
}

// StartHeartbeatChecker periodically checks for devices that have gone offline
func (dr *DeviceRegistry) StartHeartbeatChecker(ctx context.Context) {
	ticker := time.NewTicker(15 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			dr.updateOnlineStatus()
		}
	}
}

// updateOnlineStatus checks heartbeats and updates device online status
func (dr *DeviceRegistry) updateOnlineStatus() {
	now := time.Now()

	for deviceID, lastHeartbeat := range dr.heartbeats {
		if now.Sub(lastHeartbeat) > dr.offlineTimeout {
			device, exists := dr.devices[deviceID]
			if exists {
				device.IsOnline = false
				device.Status = proto.DeviceStatus_DEVICE_STATUS_OFFLINE
			}
		}
	}
}
