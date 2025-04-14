package service

import (
	"context"
	"fmt"
	"math/rand"
	"path/filepath"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/zerg/proto"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// TaskRouter manages task scheduling and distribution
type TaskRouter struct {
	proto.UnimplementedTaskRouterServiceServer
	mu                sync.RWMutex
	tasks             map[string]*proto.Task
	deviceRegistry    *DeviceRegistry
	filesystemService *FilesystemService
	taskUpdates       map[string][]chan *proto.TaskUpdate
	taskUpdatesMu     sync.RWMutex
}

// NewTaskRouter creates a new TaskRouter service
func NewTaskRouter(deviceRegistry *DeviceRegistry) *TaskRouter {
	return &TaskRouter{
		tasks:          make(map[string]*proto.Task),
		deviceRegistry: deviceRegistry,
		taskUpdates:    make(map[string][]chan *proto.TaskUpdate),
	}
}

// SetFilesystemService sets the filesystem service for task operations
func (tr *TaskRouter) SetFilesystemService(fs *FilesystemService) {
	tr.filesystemService = fs
}

// CreatePhotoBackupTask creates a task to back up a photo from source device to storage devices
func (tr *TaskRouter) CreatePhotoBackupTask(sourceDeviceID, photoPath string) (*proto.Task, error) {
	// Create a task request for backing up the photo
	req := &proto.SubmitTaskRequest{
		Name: fmt.Sprintf("Photo Backup: %s", filepath.Base(photoPath)),
		Type: proto.TaskType_TASK_TYPE_PHOTO_SYNC,
		Requirements: &proto.ResourceRequirements{
			GpuRequired:      false,
			MinMemoryMb:      64,
			MinStorageMb:     10,
			MinBandwidthMbps: 1,
		},
		Properties: map[string]string{
			"source_device_id": sourceDeviceID,
			"photo_path":       photoPath,
			"operation":        "backup",
		},
		Priority:    2, // Medium priority
		InputFiles:  []string{photoPath},
		OutputFiles: []string{fmt.Sprintf("/backup/%s", filepath.Base(photoPath))},
	}

	// Submit the task
	ctx := context.Background()
	resp, err := tr.SubmitTask(ctx, req)
	if err != nil {
		return nil, fmt.Errorf("failed to submit photo backup task: %w", err)
	}

	return resp.Task, nil
}

// SubmitTask implements the SubmitTask RPC method
func (tr *TaskRouter) SubmitTask(ctx context.Context, req *proto.SubmitTaskRequest) (*proto.SubmitTaskResponse, error) {
	tr.mu.Lock()
	defer tr.mu.Unlock()

	// Generate a unique ID for the task
	taskID := uuid.New().String()
	now := time.Now().UnixMilli()

	// Create the task object
	task := &proto.Task{
		Id:           taskID,
		Name:         req.Name,
		Type:         req.Type,
		Status:       proto.TaskStatus_TASK_STATUS_PENDING,
		CreatedAt:    now,
		UpdatedAt:    now,
		Requirements: req.Requirements,
		Properties:   req.Properties,
		Priority:     req.Priority,
		InputFiles:   req.InputFiles,
		OutputFiles:  req.OutputFiles,
	}

	// Store the task
	tr.tasks[taskID] = task

	// Schedule the task in a goroutine
	go tr.scheduleTask(taskID)

	return &proto.SubmitTaskResponse{
		Task: task,
	}, nil
}

// GetTaskStatus implements the GetTaskStatus RPC method
func (tr *TaskRouter) GetTaskStatus(ctx context.Context, req *proto.GetTaskStatusRequest) (*proto.GetTaskStatusResponse, error) {
	tr.mu.RLock()
	defer tr.mu.RUnlock()

	taskID := req.TaskId
	task, exists := tr.tasks[taskID]
	if !exists {
		return nil, status.Errorf(codes.NotFound, "task with ID %s not found", taskID)
	}

	return &proto.GetTaskStatusResponse{
		Task: task,
	}, nil
}

// CancelTask implements the CancelTask RPC method
func (tr *TaskRouter) CancelTask(ctx context.Context, req *proto.CancelTaskRequest) (*proto.CancelTaskResponse, error) {
	tr.mu.Lock()
	defer tr.mu.Unlock()

	taskID := req.TaskId
	task, exists := tr.tasks[taskID]
	if !exists {
		return nil, status.Errorf(codes.NotFound, "task with ID %s not found", taskID)
	}

	// Only allow cancellation of non-completed tasks
	if task.Status == proto.TaskStatus_TASK_STATUS_COMPLETED ||
		task.Status == proto.TaskStatus_TASK_STATUS_FAILED ||
		task.Status == proto.TaskStatus_TASK_STATUS_CANCELED {
		return &proto.CancelTaskResponse{
			Success: false,
			Message: fmt.Sprintf("Task %s cannot be canceled in state %s", taskID, task.Status),
		}, nil
	}

	// Update task status
	task.Status = proto.TaskStatus_TASK_STATUS_CANCELED
	task.UpdatedAt = time.Now().UnixMilli()

	// Send update to subscribers
	tr.sendTaskUpdate(&proto.TaskUpdate{
		TaskId:    taskID,
		Status:    proto.TaskStatus_TASK_STATUS_CANCELED,
		Message:   "Task canceled by user",
		Timestamp: time.Now().UnixMilli(),
	})

	return &proto.CancelTaskResponse{
		Success: true,
		Message: fmt.Sprintf("Task %s canceled successfully", taskID),
	}, nil
}

// ListTasks implements the ListTasks RPC method
func (tr *TaskRouter) ListTasks(ctx context.Context, req *proto.ListTasksRequest) (*proto.ListTasksResponse, error) {
	tr.mu.RLock()
	defer tr.mu.RUnlock()

	var tasks []*proto.Task
	for _, task := range tr.tasks {
		// Apply status filters if specified
		if len(req.StatusFilter) > 0 {
			statusMatch := false
			for _, status := range req.StatusFilter {
				if task.Status == status {
					statusMatch = true
					break
				}
			}
			if !statusMatch {
				continue
			}
		}

		// Apply device filter if specified
		if req.DeviceIdFilter != "" && task.AssignedDeviceId != req.DeviceIdFilter {
			continue
		}

		// Apply type filter if specified
		if req.TypeFilter != proto.TaskType_TASK_TYPE_UNSPECIFIED && task.Type != req.TypeFilter {
			continue
		}

		// Task passes all filters, add to response
		tasks = append(tasks, task)
	}

	// Apply pagination
	var result []*proto.Task
	totalCount := len(tasks)

	offset := int(req.Offset)
	if offset >= totalCount {
		offset = 0
	}

	limit := int(req.Limit)
	if limit <= 0 {
		limit = 10 // Default limit
	}

	endIdx := offset + limit
	if endIdx > totalCount {
		endIdx = totalCount
	}

	if offset < totalCount {
		result = tasks[offset:endIdx]
	}

	return &proto.ListTasksResponse{
		Tasks:      result,
		TotalCount: int32(totalCount),
	}, nil
}

// StreamTaskUpdates implements the StreamTaskUpdates RPC method
func (tr *TaskRouter) StreamTaskUpdates(req *proto.StreamTaskUpdatesRequest, stream proto.TaskRouterService_StreamTaskUpdatesServer) error {
	// Create a channel for receiving task updates
	updateCh := make(chan *proto.TaskUpdate, 10)

	// Register the channel for specific tasks or all tasks
	tr.taskUpdatesMu.Lock()
	if len(req.TaskIds) > 0 {
		// Register for specific tasks
		for _, taskID := range req.TaskIds {
			tr.taskUpdates[taskID] = append(tr.taskUpdates[taskID], updateCh)
		}
	} else {
		// Register for all tasks with a special key
		tr.taskUpdates["*"] = append(tr.taskUpdates["*"], updateCh)
	}
	tr.taskUpdatesMu.Unlock()

	// Ensure cleanup when the stream ends
	defer func() {
		tr.taskUpdatesMu.Lock()
		defer tr.taskUpdatesMu.Unlock()

		// Remove channel from all registration lists
		for taskID, channels := range tr.taskUpdates {
			for i, ch := range channels {
				if ch == updateCh {
					// Remove this channel
					tr.taskUpdates[taskID] = append(channels[:i], channels[i+1:]...)
					break
				}
			}

			// Clean up empty slices
			if len(tr.taskUpdates[taskID]) == 0 {
				delete(tr.taskUpdates, taskID)
			}
		}

		// Close the channel
		close(updateCh)
	}()

	// Send initial status for requested tasks
	if !req.IncludeCompleted {
		tr.mu.RLock()
		for _, taskID := range req.TaskIds {
			if task, exists := tr.tasks[taskID]; exists {
				if task.Status != proto.TaskStatus_TASK_STATUS_COMPLETED &&
					task.Status != proto.TaskStatus_TASK_STATUS_FAILED &&
					task.Status != proto.TaskStatus_TASK_STATUS_CANCELED {
					// Send current status
					stream.Send(&proto.TaskUpdate{
						TaskId:    taskID,
						Status:    task.Status,
						Message:   fmt.Sprintf("Current status: %s", task.Status),
						Timestamp: time.Now().UnixMilli(),
					})
				}
			}
		}
		tr.mu.RUnlock()
	}

	// Stream updates until the client disconnects
	for {
		select {
		case update, ok := <-updateCh:
			if !ok {
				// Channel closed
				return nil
			}

			// Skip completed tasks if not requested
			if !req.IncludeCompleted &&
				(update.Status == proto.TaskStatus_TASK_STATUS_COMPLETED ||
					update.Status == proto.TaskStatus_TASK_STATUS_FAILED ||
					update.Status == proto.TaskStatus_TASK_STATUS_CANCELED) {
				continue
			}

			// Send the update
			if err := stream.Send(update); err != nil {
				return err
			}

		case <-stream.Context().Done():
			// Client disconnected
			return nil
		}
	}
}

// scheduleTask handles the scheduling and execution of a task
func (tr *TaskRouter) scheduleTask(taskID string) {
	tr.mu.Lock()
	task, exists := tr.tasks[taskID]
	if !exists {
		tr.mu.Unlock()
		return
	}

	// Mark task as scheduled
	task.Status = proto.TaskStatus_TASK_STATUS_SCHEDULED
	task.UpdatedAt = time.Now().UnixMilli()
	tr.mu.Unlock()

	// Send update
	tr.sendTaskUpdate(&proto.TaskUpdate{
		TaskId:    taskID,
		Status:    proto.TaskStatus_TASK_STATUS_SCHEDULED,
		Message:   "Task scheduled for execution",
		Timestamp: time.Now().UnixMilli(),
	})

	// Find a suitable device to run the task
	deviceID, err := tr.findSuitableDevice(task)
	if err != nil {
		tr.mu.Lock()
		task.Status = proto.TaskStatus_TASK_STATUS_FAILED
		task.UpdatedAt = time.Now().UnixMilli()
		tr.mu.Unlock()

		// Send failure update
		tr.sendTaskUpdate(&proto.TaskUpdate{
			TaskId:    taskID,
			Status:    proto.TaskStatus_TASK_STATUS_FAILED,
			Message:   fmt.Sprintf("Failed to schedule task: %v", err),
			Timestamp: time.Now().UnixMilli(),
			Update: &proto.TaskUpdate_FailedUpdate{
				FailedUpdate: &proto.TaskFailedUpdate{
					ErrorCode:    "SCHEDULING_FAILED",
					ErrorMessage: err.Error(),
					CanRetry:     true,
				},
			},
		})
		return
	}

	// Update task with assigned device
	tr.mu.Lock()
	task.AssignedDeviceId = deviceID
	task.Status = proto.TaskStatus_TASK_STATUS_RUNNING
	task.UpdatedAt = time.Now().UnixMilli()
	tr.mu.Unlock()

	// Send update
	tr.sendTaskUpdate(&proto.TaskUpdate{
		TaskId:    taskID,
		Status:    proto.TaskStatus_TASK_STATUS_RUNNING,
		Message:   fmt.Sprintf("Task assigned to device %s", deviceID),
		Timestamp: time.Now().UnixMilli(),
	})

	// Execute the task based on its type
	switch task.Type {
	case proto.TaskType_TASK_TYPE_PHOTO_SYNC:
		tr.executePhotoSyncTask(taskID)
	default:
		// For other task types or for simulation
		tr.simulateTaskExecution(taskID)
	}
}

// executePhotoSyncTask handles the execution of a photo sync task
func (tr *TaskRouter) executePhotoSyncTask(taskID string) {
	tr.mu.RLock()
	task, exists := tr.tasks[taskID]
	if !exists {
		tr.mu.RUnlock()
		return
	}

	// Get task information
	sourceDeviceID := task.Properties["source_device_id"]
	photoPath := task.Properties["photo_path"]
	deviceID := task.AssignedDeviceId
	tr.mu.RUnlock()

	// Log task execution start
	fmt.Printf("Executing photo sync task: %s - Moving %s from %s to %s\n",
		taskID, photoPath, sourceDeviceID, deviceID)

	// Create progress update
	tr.sendTaskUpdate(&proto.TaskUpdate{
		TaskId:    taskID,
		Status:    proto.TaskStatus_TASK_STATUS_RUNNING,
		Message:   "Starting photo sync",
		Timestamp: time.Now().UnixMilli(),
		Update: &proto.TaskUpdate_ProgressUpdate{
			ProgressUpdate: &proto.TaskProgressUpdate{
				PercentComplete:         10.0,
				CurrentOperation:        "Preparing to transfer photo",
				EstimatedCompletionTime: time.Now().Add(time.Second * 30).UnixMilli(),
			},
		},
	})

	// If we have a filesystem service, use it to transfer the file
	if tr.filesystemService != nil {
		// Create appropriate destination path
		destPath := filepath.Join("backup", filepath.Base(photoPath))

		// Get file data from source device
		readReq := &proto.ReadFileRequest{
			Path:     photoPath,
			DeviceId: sourceDeviceID,
		}

		// Read the file
		ctx := context.Background()
		readResp, err := tr.filesystemService.ReadFile(ctx, readReq)
		if err != nil {
			tr.handlePhotoSyncError(taskID, err)
			return
		}

		// Update progress
		tr.sendTaskUpdate(&proto.TaskUpdate{
			TaskId:    taskID,
			Status:    proto.TaskStatus_TASK_STATUS_RUNNING,
			Message:   "Transferring photo data",
			Timestamp: time.Now().UnixMilli(),
			Update: &proto.TaskUpdate_ProgressUpdate{
				ProgressUpdate: &proto.TaskProgressUpdate{
					PercentComplete:         50.0,
					CurrentOperation:        "Transferring photo data",
					EstimatedCompletionTime: time.Now().Add(time.Second * 10).UnixMilli(),
				},
			},
		})

		// Write to destination device
		writeReq := &proto.WriteFileRequest{
			Path:     destPath,
			Data:     readResp.Data,
			Append:   false,
			DeviceId: deviceID,
		}

		// Write the file
		_, err = tr.filesystemService.WriteFile(ctx, writeReq)
		if err != nil {
			tr.handlePhotoSyncError(taskID, err)
			return
		}

		// Complete the task successfully
		tr.mu.Lock()
		task.Status = proto.TaskStatus_TASK_STATUS_COMPLETED
		task.UpdatedAt = time.Now().UnixMilli()
		tr.mu.Unlock()

		// Send completion update
		tr.sendTaskUpdate(&proto.TaskUpdate{
			TaskId:    taskID,
			Status:    proto.TaskStatus_TASK_STATUS_COMPLETED,
			Message:   "Photo backup completed successfully",
			Timestamp: time.Now().UnixMilli(),
			Update: &proto.TaskUpdate_CompletedUpdate{
				CompletedUpdate: &proto.TaskCompletedUpdate{
					ResultFiles: []string{destPath},
					ResultData: map[string]string{
						"success":           "true",
						"bytes_transferred": fmt.Sprintf("%d", len(readResp.Data)),
						"source_device":     sourceDeviceID,
						"target_device":     deviceID,
					},
				},
			},
		})
	} else {
		// Simulate if filesystem service is not available
		time.Sleep(time.Second * 2)

		// Update progress
		tr.sendTaskUpdate(&proto.TaskUpdate{
			TaskId:    taskID,
			Status:    proto.TaskStatus_TASK_STATUS_RUNNING,
			Message:   "Simulating photo sync",
			Timestamp: time.Now().UnixMilli(),
			Update: &proto.TaskUpdate_ProgressUpdate{
				ProgressUpdate: &proto.TaskProgressUpdate{
					PercentComplete:         75.0,
					CurrentOperation:        "Processing photo data (simulated)",
					EstimatedCompletionTime: time.Now().Add(time.Second * 5).UnixMilli(),
				},
			},
		})

		time.Sleep(time.Second * 2)

		// Complete the task
		tr.mu.Lock()
		task.Status = proto.TaskStatus_TASK_STATUS_COMPLETED
		task.UpdatedAt = time.Now().UnixMilli()
		tr.mu.Unlock()

		// Send completion update
		tr.sendTaskUpdate(&proto.TaskUpdate{
			TaskId:    taskID,
			Status:    proto.TaskStatus_TASK_STATUS_COMPLETED,
			Message:   "Photo backup completed (simulated)",
			Timestamp: time.Now().UnixMilli(),
			Update: &proto.TaskUpdate_CompletedUpdate{
				CompletedUpdate: &proto.TaskCompletedUpdate{
					ResultFiles: task.OutputFiles,
					ResultData: map[string]string{
						"success":           "true",
						"bytes_transferred": "1024000", // Simulated 1MB
						"source_device":     sourceDeviceID,
						"target_device":     deviceID,
					},
				},
			},
		})
	}

	fmt.Printf("Photo sync task %s completed\n", taskID)
}

// handlePhotoSyncError handles errors during photo sync tasks
func (tr *TaskRouter) handlePhotoSyncError(taskID string, err error) {
	tr.mu.Lock()
	task, exists := tr.tasks[taskID]
	if exists {
		task.Status = proto.TaskStatus_TASK_STATUS_FAILED
		task.UpdatedAt = time.Now().UnixMilli()
	}
	tr.mu.Unlock()

	// Send failure update
	tr.sendTaskUpdate(&proto.TaskUpdate{
		TaskId:    taskID,
		Status:    proto.TaskStatus_TASK_STATUS_FAILED,
		Message:   fmt.Sprintf("Photo sync failed: %v", err),
		Timestamp: time.Now().UnixMilli(),
		Update: &proto.TaskUpdate_FailedUpdate{
			FailedUpdate: &proto.TaskFailedUpdate{
				ErrorCode:    "PHOTO_SYNC_FAILED",
				ErrorMessage: err.Error(),
				CanRetry:     true,
			},
		},
	})

	fmt.Printf("Photo sync task %s failed: %v\n", taskID, err)
}

// findSuitableDevice looks for storage devices when handling photo backup tasks
func (tr *TaskRouter) findSuitableDevice(task *proto.Task) (string, error) {
	if task.Type == proto.TaskType_TASK_TYPE_PHOTO_SYNC {
		// For photo sync tasks, find devices marked as storage
		devices, err := tr.deviceRegistry.ListDevices(context.Background(), &proto.ListDevicesRequest{
			OnlyOnline: true,
		})
		if err != nil {
			return "", fmt.Errorf("failed to list devices: %w", err)
		}

		// Get source device ID to avoid backing up to the same device
		sourceDeviceID := task.Properties["source_device_id"]

		for _, device := range devices.Devices {
			// Skip the source device
			if device.Id == sourceDeviceID {
				continue
			}

			// Look for storage capability
			if role, exists := device.Capabilities["role"]; exists && role == "storage" {
				// Found a storage device
				return device.Id, nil
			}

			// Alternative: check for large storage capacity
			if storageResource, ok := device.Resources["storage"]; ok {
				// If the device has > 100GB free, consider it suitable
				if storageResource.Total-storageResource.Used > 100*1024 {
					return device.Id, nil
				}
			}
		}

		return "", fmt.Errorf("no suitable storage device found for photo backup")
	}

	// For other task types, use the existing device selection logic
	return tr.defaultFindSuitableDevice(task)
}

// defaultFindSuitableDevice is the original device selection logic
func (tr *TaskRouter) defaultFindSuitableDevice(task *proto.Task) (string, error) {
	// Get list of devices from registry
	devices, err := tr.deviceRegistry.ListDevices(context.Background(), &proto.ListDevicesRequest{
		OnlyOnline: true,
	})
	if err != nil {
		return "", fmt.Errorf("failed to list devices: %w", err)
	}

	// Filter suitable devices based on task requirements
	var suitableDevices []string
	for _, device := range devices.Devices {
		if tr.deviceMeetsRequirements(device, task.Requirements) {
			suitableDevices = append(suitableDevices, device.Id)
		}
	}

	if len(suitableDevices) == 0 {
		return "", fmt.Errorf("no suitable device found for task requirements")
	}

	// Select a device (for now, just pick one randomly)
	return suitableDevices[rand.Intn(len(suitableDevices))], nil
}

// deviceMeetsRequirements checks if a device meets the requirements of a task
func (tr *TaskRouter) deviceMeetsRequirements(device *proto.Device, req *proto.ResourceRequirements) bool {
	// Check if GPU is required
	if req.GpuRequired {
		gpuResource, hasGPU := device.Resources["gpu"]
		if !hasGPU || gpuResource.Used >= gpuResource.Total {
			return false
		}
	}

	// Check memory requirements
	if req.MinMemoryMb > 0 {
		memResource, hasMem := device.Resources["memory"]
		if !hasMem || memResource.Total*1024 < float64(req.MinMemoryMb) {
			return false
		}
	}

	// Check storage requirements
	if req.MinStorageMb > 0 {
		storageResource, hasStorage := device.Resources["storage"]
		if !hasStorage || storageResource.Total*1024 < float64(req.MinStorageMb) {
			return false
		}
	}

	// Check required capabilities
	for _, capability := range req.RequiredCapabilities {
		if _, hasCapability := device.Capabilities[capability]; !hasCapability {
			return false
		}
	}

	return true
}

// simulateTaskExecution simulates a task running to completion
func (tr *TaskRouter) simulateTaskExecution(taskID string) {
	// Simulate task steps
	steps := []string{"initialize", "process", "finalize"}

	for i, stepName := range steps {
		// Create step ID
		stepID := fmt.Sprintf("%s-step-%d", taskID, i)

		// Simulate step starting
		tr.sendTaskUpdate(&proto.TaskUpdate{
			TaskId:    taskID,
			Status:    proto.TaskStatus_TASK_STATUS_RUNNING,
			Message:   fmt.Sprintf("Starting step: %s", stepName),
			Timestamp: time.Now().UnixMilli(),
			Update: &proto.TaskUpdate_StepUpdate{
				StepUpdate: &proto.TaskStepUpdate{
					StepId: stepID,
					Status: proto.TaskStepStatus_TASK_STEP_STATUS_RUNNING,
				},
			},
		})

		// Simulate progress updates
		for progress := 0.0; progress < 1.0; progress += 0.25 {
			tr.sendTaskUpdate(&proto.TaskUpdate{
				TaskId:    taskID,
				Status:    proto.TaskStatus_TASK_STATUS_RUNNING,
				Message:   fmt.Sprintf("Step %s in progress", stepName),
				Timestamp: time.Now().UnixMilli(),
				Update: &proto.TaskUpdate_ProgressUpdate{
					ProgressUpdate: &proto.TaskProgressUpdate{
						PercentComplete:         progress * 100,
						CurrentOperation:        fmt.Sprintf("Processing %s", stepName),
						EstimatedCompletionTime: time.Now().Add(time.Second * 10).UnixMilli(),
					},
				},
			})

			// Simulate work happening
			time.Sleep(time.Millisecond * 500)
		}

		// Step completed
		tr.sendTaskUpdate(&proto.TaskUpdate{
			TaskId:    taskID,
			Status:    proto.TaskStatus_TASK_STATUS_RUNNING,
			Message:   fmt.Sprintf("Completed step: %s", stepName),
			Timestamp: time.Now().UnixMilli(),
			Update: &proto.TaskUpdate_StepUpdate{
				StepUpdate: &proto.TaskStepUpdate{
					StepId: stepID,
					Status: proto.TaskStepStatus_TASK_STEP_STATUS_COMPLETED,
					Outputs: map[string]string{
						"duration_ms": "500",
						"result":      "success",
					},
				},
			},
		})
	}

	// Mark task as completed
	tr.mu.Lock()
	task, exists := tr.tasks[taskID]
	if exists {
		task.Status = proto.TaskStatus_TASK_STATUS_COMPLETED
		task.UpdatedAt = time.Now().UnixMilli()
	}
	tr.mu.Unlock()

	if exists {
		// Send completion update
		tr.sendTaskUpdate(&proto.TaskUpdate{
			TaskId:    taskID,
			Status:    proto.TaskStatus_TASK_STATUS_COMPLETED,
			Message:   "Task completed successfully",
			Timestamp: time.Now().UnixMilli(),
			Update: &proto.TaskUpdate_CompletedUpdate{
				CompletedUpdate: &proto.TaskCompletedUpdate{
					ResultFiles: task.OutputFiles,
					ResultData: map[string]string{
						"execution_time_ms": "1500",
						"steps_completed":   "3",
					},
				},
			},
		})
	}
}

// sendTaskUpdate distributes a task update to all registered listeners
func (tr *TaskRouter) sendTaskUpdate(update *proto.TaskUpdate) {
	tr.taskUpdatesMu.RLock()
	defer tr.taskUpdatesMu.RUnlock()

	// Send to specific task subscribers
	for _, ch := range tr.taskUpdates[update.TaskId] {
		select {
		case ch <- update:
			// Update sent
		default:
			// Channel buffer full, skip
		}
	}

	// Send to all-task subscribers
	for _, ch := range tr.taskUpdates["*"] {
		select {
		case ch <- update:
			// Update sent
		default:
			// Channel buffer full, skip
		}
	}
}
