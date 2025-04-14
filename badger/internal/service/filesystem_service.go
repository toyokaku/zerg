package service

import (
	"context"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/zerg/proto"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// FilesystemService manages distributed file operations
type FilesystemService struct {
	proto.UnimplementedFilesystemServiceServer
	deviceRegistry *DeviceRegistry
	taskRouter     *TaskRouter
	mu             sync.RWMutex
	rootPaths      map[string]string             // Map of deviceID to root path
	watchPatterns  map[string]map[string]bool    // Map of deviceID to watched patterns
	watchChannels  map[string][]chan *FileEvent  // Map of deviceID to file event channels
	notifiers      map[string]context.CancelFunc // Map of watchIDs to cancel functions
}

// FileEvent represents a file event captured during directory watching
type FileEvent struct {
	DeviceID   string
	Path       string
	Name       string
	ChangeType proto.FileChangeType
	Size       int64
	IsDir      bool
	Time       time.Time
}

// NewFilesystemService creates a new FilesystemService
func NewFilesystemService(deviceRegistry *DeviceRegistry) *FilesystemService {
	return &FilesystemService{
		deviceRegistry: deviceRegistry,
		rootPaths:      make(map[string]string),
		watchPatterns:  make(map[string]map[string]bool),
		watchChannels:  make(map[string][]chan *FileEvent),
		notifiers:      make(map[string]context.CancelFunc),
	}
}

// SetTaskRouter sets the task router service for file operations
func (fs *FilesystemService) SetTaskRouter(tr *TaskRouter) {
	fs.taskRouter = tr
}

// RegisterDeviceRootPath registers the root path for a device
func (fs *FilesystemService) RegisterDeviceRootPath(deviceID, rootPath string) {
	fs.mu.Lock()
	defer fs.mu.Unlock()
	fs.rootPaths[deviceID] = rootPath

	// Create standard directories if they don't exist
	stdDirs := []string{"photo", "backup"}
	for _, dir := range stdDirs {
		dirPath := filepath.Join(rootPath, dir)
		if _, err := os.Stat(dirPath); os.IsNotExist(err) {
			os.MkdirAll(dirPath, 0755)
		}
	}
}

// WatchDirectory starts watching a directory for file changes
// Detects file creation, modification, and deletion events
func (fs *FilesystemService) WatchDirectory(ctx context.Context, req *proto.WatchChangesRequest) (*proto.WatchChangesResponse, error) {
	deviceID := req.DeviceId
	if deviceID == "" {
		return nil, status.Error(codes.InvalidArgument, "device ID is required")
	}

	fs.mu.RLock()
	rootPath, exists := fs.rootPaths[deviceID]
	fs.mu.RUnlock()

	if !exists {
		return nil, status.Errorf(codes.NotFound, "device %s not registered", deviceID)
	}

	// Generate a unique watch ID
	watchID := fmt.Sprintf("%s-%d", deviceID, time.Now().UnixNano())

	// Create a cancelable context for this watch operation
	watchCtx, cancel := context.WithCancel(ctx)

	// Store the cancel function
	fs.mu.Lock()
	fs.notifiers[watchID] = cancel

	// Initialize watched patterns for this device if needed
	if _, exists := fs.watchPatterns[deviceID]; !exists {
		fs.watchPatterns[deviceID] = make(map[string]bool)
	}

	// Register the patterns to watch
	for _, pattern := range req.Paths {
		fs.watchPatterns[deviceID][pattern] = true
	}
	fs.mu.Unlock()

	// Start watching the directory in a goroutine
	go fs.watchDirectoryWorker(watchCtx, deviceID, rootPath, req.Paths, req.Recursive, req.ChangeTypes)

	return &proto.WatchChangesResponse{
		Success: true,
		Message: fmt.Sprintf("Started watching directories on device %s", deviceID),
		WatchId: watchID,
	}, nil
}

// StopWatching stops watching a directory
func (fs *FilesystemService) StopWatching(ctx context.Context, req *proto.StopWatchingRequest) (*proto.StopWatchingResponse, error) {
	fs.mu.Lock()
	defer fs.mu.Unlock()

	cancel, exists := fs.notifiers[req.WatchId]
	if !exists {
		return nil, status.Errorf(codes.NotFound, "watch ID %s not found", req.WatchId)
	}

	// Cancel the watch context
	cancel()
	delete(fs.notifiers, req.WatchId)

	return &proto.StopWatchingResponse{
		Success: true,
		Message: fmt.Sprintf("Stopped watching with ID %s", req.WatchId),
	}, nil
}

// watchDirectoryWorker is a worker function that watches a directory for changes
func (fs *FilesystemService) watchDirectoryWorker(ctx context.Context, deviceID, rootPath string, patterns []string, recursive bool, changeTypes []proto.FileChangeType) {
	// Create a map to track files we've seen before
	seenFiles := make(map[string]time.Time)

	// Initial scan to populate the map
	for _, pattern := range patterns {
		watchPath := filepath.Join(rootPath, pattern)

		walkFn := func(path string, info fs.FileInfo, err error) error {
			if err != nil {
				return nil // Skip errors
			}

			// Only track files, not directories
			if !info.IsDir() {
				seenFiles[path] = info.ModTime()
			}

			return nil
		}

		if recursive {
			filepath.Walk(watchPath, walkFn)
		} else {
			// For non-recursive watching, just check files in the directory
			items, err := os.ReadDir(watchPath)
			if err != nil {
				continue
			}

			for _, item := range items {
				if !item.IsDir() {
					info, err := item.Info()
					if err != nil {
						continue
					}

					fullPath := filepath.Join(watchPath, item.Name())
					seenFiles[fullPath] = info.ModTime()
				}
			}
		}
	}

	// Polling interval for checking changes
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			// Check for new or modified files
			for _, pattern := range patterns {
				watchPath := filepath.Join(rootPath, pattern)

				walkFn := func(path string, info fs.FileInfo, err error) error {
					if err != nil {
						return nil
					}

					// Skip directories unless we're specifically watching for directory changes
					if info.IsDir() {
						return nil
					}

					// For this application, we only care about photo files
					isPhoto := fs.isPhotoFile(path)
					if !isPhoto {
						return nil
					}

					// Check if we've seen this file before
					lastModTime, exists := seenFiles[path]

					if !exists {
						// New file
						seenFiles[path] = info.ModTime()

						// Should we notify about this type of event?
						if containsChangeType(changeTypes, proto.FileChangeType_FILE_CHANGE_TYPE_CREATED) {
							// Send notification that a new file was created
							relPath, _ := filepath.Rel(rootPath, path)

							fs.sendFileChangeEvent(deviceID, relPath, proto.FileChangeType_FILE_CHANGE_TYPE_CREATED)
						}
					} else if exists && info.ModTime().After(lastModTime) {
						// Modified file
						seenFiles[path] = info.ModTime()

						// Should we notify about this type of event?
						if containsChangeType(changeTypes, proto.FileChangeType_FILE_CHANGE_TYPE_MODIFIED) {
							// Send notification that a file was modified
							relPath, _ := filepath.Rel(rootPath, path)

							fs.sendFileChangeEvent(deviceID, relPath, proto.FileChangeType_FILE_CHANGE_TYPE_MODIFIED)
						}
					}

					return nil
				}

				if recursive {
					filepath.Walk(watchPath, walkFn)
				} else {
					// For non-recursive, just check the directory
					items, err := os.ReadDir(watchPath)
					if err != nil {
						continue
					}

					for _, item := range items {
						if item.IsDir() {
							continue
						}

						fullPath := filepath.Join(watchPath, item.Name())
						info, err := item.Info()
						if err != nil {
							continue
						}

						// Call our walk function with this file
						walkFn(fullPath, info, nil)
					}
				}
			}

			// Check for deleted files
			var deletedFiles []string
			for path := range seenFiles {
				_, err := os.Stat(path)
				if os.IsNotExist(err) {
					deletedFiles = append(deletedFiles, path)

					// Should we notify about deletion?
					if containsChangeType(changeTypes, proto.FileChangeType_FILE_CHANGE_TYPE_DELETED) {
						relPath, _ := filepath.Rel(rootPath, path)

						fs.sendFileChangeEvent(deviceID, relPath, proto.FileChangeType_FILE_CHANGE_TYPE_DELETED)
					}
				}
			}

			// Remove deleted files from our tracking map
			for _, path := range deletedFiles {
				delete(seenFiles, path)
			}
		}
	}
}

// isPhotoFile determines if a file is a photo based on its extension
func (fs *FilesystemService) isPhotoFile(path string) bool {
	ext := strings.ToLower(filepath.Ext(path))
	photoExts := map[string]bool{
		".jpg":  true,
		".jpeg": true,
		".png":  true,
		".gif":  true,
		".bmp":  true,
		".heic": true,
		".heif": true,
		".raw":  true,
		".tiff": true,
		".webp": true,
	}

	return photoExts[ext]
}

// containsChangeType checks if a change type is in the list of types to watch
func containsChangeType(types []proto.FileChangeType, t proto.FileChangeType) bool {
	// If no specific types are specified, consider all types
	if len(types) == 0 {
		return true
	}

	for _, ct := range types {
		if ct == t {
			return true
		}
	}

	return false
}

// sendFileChangeEvent notifies watchers of file changes
func (fs *FilesystemService) sendFileChangeEvent(deviceID, path string, changeType proto.FileChangeType) {
	// Create file info for the event
	var fileInfo *proto.FileInfo

	// Get full path
	fs.mu.RLock()
	rootPath, exists := fs.rootPaths[deviceID]
	fs.mu.RUnlock()

	if exists {
		fullPath := filepath.Join(rootPath, path)
		stat, err := os.Stat(fullPath)

		if err == nil {
			// File exists, gather info
			fileInfo = &proto.FileInfo{
				Path:         path,
				Name:         filepath.Base(path),
				Size:         stat.Size(),
				IsDirectory:  stat.IsDir(),
				ModifiedTime: stat.ModTime().UnixMilli(),
				DeviceId:     deviceID,
				MimeType:     detectMimeType(path),
			}
		} else {
			// For deleted files or other errors, provide basic info
			fileInfo = &proto.FileInfo{
				Path:     path,
				Name:     filepath.Base(path),
				DeviceId: deviceID,
			}
		}
	} else {
		// Basic info if device not found
		fileInfo = &proto.FileInfo{
			Path:     path,
			Name:     filepath.Base(path),
			DeviceId: deviceID,
		}
	}

	// Create the change event
	event := &proto.FileChangeEvent{
		Path:       path,
		ChangeType: changeType,
		FileInfo:   fileInfo,
		DeviceId:   deviceID,
		Timestamp:  time.Now().UnixMilli(),
	}

	// If this is a new photo, create a task to back it up to storage devices
	if changeType == proto.FileChangeType_FILE_CHANGE_TYPE_CREATED && fs.isPhotoFile(path) {
		// Create a photo backup task
		fs.createPhotoBackupTask(deviceID, path)
	}
}

// createPhotoBackupTask creates a new task to back up a photo to storage devices
func (fs *FilesystemService) createPhotoBackupTask(sourceDeviceID, photoPath string) {
	// Check if we have a task router service
	if fs.taskRouter == nil {
		fmt.Printf("No task router available, cannot create backup task for photo: %s on device %s\n",
			photoPath, sourceDeviceID)
		return
	}

	// Create a backup task for the photo
	task, err := fs.taskRouter.CreatePhotoBackupTask(sourceDeviceID, photoPath)
	if err != nil {
		fmt.Printf("Failed to create backup task for photo %s: %v\n", photoPath, err)
		return
	}

	fmt.Printf("Created backup task %s for photo %s from device %s\n",
		task.Id, photoPath, sourceDeviceID)
}

// ListFiles implements the ListFiles RPC method
func (fs *FilesystemService) ListFiles(ctx context.Context, req *proto.ListFilesRequest) (*proto.ListFilesResponse, error) {
	// If device ID is specified, list files from that device
	if req.DeviceId != "" {
		return fs.listFilesFromDevice(ctx, req)
	}

	// Otherwise, list files from all devices (union view)
	return fs.listFilesFromAllDevices(ctx, req)
}

// listFilesFromDevice lists files from a specific device
func (fs *FilesystemService) listFilesFromDevice(ctx context.Context, req *proto.ListFilesRequest) (*proto.ListFilesResponse, error) {
	fs.mu.RLock()
	rootPath, exists := fs.rootPaths[req.DeviceId]
	fs.mu.RUnlock()

	if !exists {
		return nil, status.Errorf(codes.NotFound, "device with ID %s not registered", req.DeviceId)
	}

	// Resolve the full path
	fullPath := filepath.Join(rootPath, req.Path)

	// Ensure path is under root path (security check)
	if !isPathSafe(rootPath, fullPath) {
		return nil, status.Errorf(codes.InvalidArgument, "path is outside of root directory")
	}

	// Check if directory exists
	fileInfo, err := os.Stat(fullPath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, status.Errorf(codes.NotFound, "path does not exist")
		}
		return nil, status.Errorf(codes.Internal, "failed to access path: %v", err)
	}

	// Ensure it's a directory
	if !fileInfo.IsDir() {
		return nil, status.Errorf(codes.InvalidArgument, "path is not a directory")
	}

	// Read directory contents
	entries, err := ioutil.ReadDir(fullPath)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to read directory: %v", err)
	}

	// Convert to FileInfo proto
	var files []*proto.FileInfo
	for _, entry := range entries {
		// Skip hidden files unless requested
		if entry.Name()[0] == '.' && !req.IncludeHidden {
			continue
		}

		// Create file info
		fileInfo := &proto.FileInfo{
			Path:         filepath.Join(req.Path, entry.Name()),
			Name:         entry.Name(),
			Size:         entry.Size(),
			IsDirectory:  entry.IsDir(),
			ModifiedTime: entry.ModTime().UnixMilli(),
			DeviceId:     req.DeviceId,
		}

		// Add basic MIME type detection
		if !entry.IsDir() {
			fileInfo.MimeType = detectMimeType(entry.Name())
		}

		files = append(files, fileInfo)
	}

	// Apply pagination
	var result []*proto.FileInfo
	totalCount := len(files)

	offset := int(req.Offset)
	if offset >= totalCount {
		offset = 0
	}

	limit := int(req.Limit)
	if limit <= 0 {
		limit = 100 // Default limit
	}

	endIdx := offset + limit
	if endIdx > totalCount {
		endIdx = totalCount
	}

	if offset < totalCount {
		result = files[offset:endIdx]
	}

	return &proto.ListFilesResponse{
		Files:      result,
		TotalCount: int32(totalCount),
	}, nil
}

// listFilesFromAllDevices combines file listings from all devices
func (fs *FilesystemService) listFilesFromAllDevices(ctx context.Context, req *proto.ListFilesRequest) (*proto.ListFilesResponse, error) {
	// Get list of devices
	devicesResp, err := fs.deviceRegistry.ListDevices(ctx, &proto.ListDevicesRequest{
		OnlyOnline: true,
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to list devices: %v", err)
	}

	var allFiles []*proto.FileInfo
	var mu sync.Mutex
	var wg sync.WaitGroup

	// Query each device concurrently
	for _, device := range devicesResp.Devices {
		wg.Add(1)
		go func(deviceID string) {
			defer wg.Done()

			// Copy request but target specific device
			deviceReq := &proto.ListFilesRequest{
				Path:          req.Path,
				DeviceId:      deviceID,
				Recursive:     req.Recursive,
				MaxDepth:      req.MaxDepth,
				IncludeHidden: req.IncludeHidden,
				// Skip pagination params for individual devices
			}

			// Get files from this device
			resp, err := fs.listFilesFromDevice(ctx, deviceReq)
			if err != nil {
				// Skip devices with errors
				return
			}

			// Add files to combined result
			mu.Lock()
			allFiles = append(allFiles, resp.Files...)
			mu.Unlock()
		}(device.Id)
	}

	// Wait for all queries to complete
	wg.Wait()

	// Apply pagination to combined results
	var result []*proto.FileInfo
	totalCount := len(allFiles)

	offset := int(req.Offset)
	if offset >= totalCount {
		offset = 0
	}

	limit := int(req.Limit)
	if limit <= 0 {
		limit = 100 // Default limit
	}

	endIdx := offset + limit
	if endIdx > totalCount {
		endIdx = totalCount
	}

	if offset < totalCount {
		result = allFiles[offset:endIdx]
	}

	return &proto.ListFilesResponse{
		Files:      result,
		TotalCount: int32(totalCount),
	}, nil
}

// GetFileInfo implements the GetFileInfo RPC method
func (fs *FilesystemService) GetFileInfo(ctx context.Context, req *proto.GetFileInfoRequest) (*proto.GetFileInfoResponse, error) {
	// If device ID is specified, get file info from that device
	if req.DeviceId != "" {
		return fs.getFileInfoFromDevice(ctx, req)
	}

	// If no device ID, try to find the file on any device
	devicesResp, err := fs.deviceRegistry.ListDevices(ctx, &proto.ListDevicesRequest{
		OnlyOnline: true,
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to list devices: %v", err)
	}

	// Try each device until we find the file
	for _, device := range devicesResp.Devices {
		deviceReq := &proto.GetFileInfoRequest{
			Path:     req.Path,
			DeviceId: device.Id,
		}

		resp, err := fs.getFileInfoFromDevice(ctx, deviceReq)
		if err == nil {
			// Found the file on this device
			return resp, nil
		}
	}

	return nil, status.Errorf(codes.NotFound, "file not found on any device")
}

// getFileInfoFromDevice gets file info from a specific device
func (fs *FilesystemService) getFileInfoFromDevice(ctx context.Context, req *proto.GetFileInfoRequest) (*proto.GetFileInfoResponse, error) {
	fs.mu.RLock()
	rootPath, exists := fs.rootPaths[req.DeviceId]
	fs.mu.RUnlock()

	if !exists {
		return nil, status.Errorf(codes.NotFound, "device with ID %s not registered", req.DeviceId)
	}

	// Resolve the full path
	fullPath := filepath.Join(rootPath, req.Path)

	// Ensure path is under root path (security check)
	if !isPathSafe(rootPath, fullPath) {
		return nil, status.Errorf(codes.InvalidArgument, "path is outside of root directory")
	}

	// Get file info
	fileInfo, err := os.Stat(fullPath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, status.Errorf(codes.NotFound, "file does not exist")
		}
		return nil, status.Errorf(codes.Internal, "failed to access file: %v", err)
	}

	// Create FileInfo proto
	result := &proto.FileInfo{
		Path:         req.Path,
		Name:         filepath.Base(req.Path),
		Size:         fileInfo.Size(),
		IsDirectory:  fileInfo.IsDir(),
		ModifiedTime: fileInfo.ModTime().UnixMilli(),
		DeviceId:     req.DeviceId,
	}

	// Add MIME type for files
	if !fileInfo.IsDir() {
		result.MimeType = detectMimeType(fileInfo.Name())
	}

	return &proto.GetFileInfoResponse{
		FileInfo: result,
	}, nil
}

// ReadFile implements the ReadFile RPC method
func (fs *FilesystemService) ReadFile(ctx context.Context, req *proto.ReadFileRequest) (*proto.ReadFileResponse, error) {
	// If device ID is specified, read from that device
	if req.DeviceId != "" {
		return fs.readFileFromDevice(ctx, req)
	}

	// If no device ID, try to find the file on any device
	devicesResp, err := fs.deviceRegistry.ListDevices(ctx, &proto.ListDevicesRequest{
		OnlyOnline: true,
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to list devices: %v", err)
	}

	// Try each device until we find the file
	for _, device := range devicesResp.Devices {
		deviceReq := &proto.ReadFileRequest{
			Path:     req.Path,
			DeviceId: device.Id,
			Offset:   req.Offset,
			MaxSize:  req.MaxSize,
		}

		resp, err := fs.readFileFromDevice(ctx, deviceReq)
		if err == nil {
			// Found and read the file from this device
			return resp, nil
		}
	}

	return nil, status.Errorf(codes.NotFound, "file not found on any device")
}

// readFileFromDevice reads a file from a specific device
func (fs *FilesystemService) readFileFromDevice(ctx context.Context, req *proto.ReadFileRequest) (*proto.ReadFileResponse, error) {
	fs.mu.RLock()
	rootPath, exists := fs.rootPaths[req.DeviceId]
	fs.mu.RUnlock()

	if !exists {
		return nil, status.Errorf(codes.NotFound, "device with ID %s not registered", req.DeviceId)
	}

	// Resolve the full path
	fullPath := filepath.Join(rootPath, req.Path)

	// Ensure path is under root path (security check)
	if !isPathSafe(rootPath, fullPath) {
		return nil, status.Errorf(codes.InvalidArgument, "path is outside of root directory")
	}

	// Get file info
	fileInfo, err := os.Stat(fullPath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, status.Errorf(codes.NotFound, "file does not exist")
		}
		return nil, status.Errorf(codes.Internal, "failed to access file: %v", err)
	}

	// Ensure it's a file
	if fileInfo.IsDir() {
		return nil, status.Errorf(codes.InvalidArgument, "path is a directory, not a file")
	}

	// Open the file
	file, err := os.Open(fullPath)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to open file: %v", err)
	}
	defer file.Close()

	// Handle offset
	if req.Offset > 0 {
		_, err = file.Seek(req.Offset, 0)
		if err != nil {
			return nil, status.Errorf(codes.Internal, "failed to seek to offset: %v", err)
		}
	}

	// Determine read size
	readSize := int(req.MaxSize)
	if readSize <= 0 || readSize > 10*1024*1024 { // Limit to 10MB
		readSize = 10 * 1024 * 1024
	}

	// Read the file
	data := make([]byte, readSize)
	n, err := file.Read(data)
	if err != nil && err.Error() != "EOF" {
		return nil, status.Errorf(codes.Internal, "failed to read file: %v", err)
	}

	// Truncate data to actual bytes read
	data = data[:n]

	return &proto.ReadFileResponse{
		Data:      data,
		TotalSize: fileInfo.Size(),
	}, nil
}

// WriteFile implements the WriteFile RPC method
func (fs *FilesystemService) WriteFile(ctx context.Context, req *proto.WriteFileRequest) (*proto.WriteFileResponse, error) {
	// Get device ID
	deviceID := req.DeviceId
	if deviceID == "" {
		// If no device ID provided, use the local device
		// In a real implementation, you might have logic to select the best device
		deviceID = "local" // Placeholder
	}

	fs.mu.RLock()
	rootPath, exists := fs.rootPaths[deviceID]
	fs.mu.RUnlock()

	if !exists {
		return nil, status.Errorf(codes.NotFound, "device with ID %s not registered", deviceID)
	}

	// Resolve the full path
	fullPath := filepath.Join(rootPath, req.Path)

	// Ensure path is under root path (security check)
	if !isPathSafe(rootPath, fullPath) {
		return nil, status.Errorf(codes.InvalidArgument, "path is outside of root directory")
	}

	// Ensure directory exists
	dir := filepath.Dir(fullPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return nil, status.Errorf(codes.Internal, "failed to create directory: %v", err)
	}

	// Determine write mode
	flag := os.O_CREATE | os.O_WRONLY
	if req.Append {
		flag |= os.O_APPEND
	} else {
		flag |= os.O_TRUNC
	}

	// Open file for writing
	file, err := os.OpenFile(fullPath, flag, 0644)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to open file for writing: %v", err)
	}
	defer file.Close()

	// Write data
	n, err := file.Write(req.Data)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to write to file: %v", err)
	}

	// If this is a new file or has been modified, send a file change event
	fs.sendFileChangeEvent(deviceID, req.Path, proto.FileChangeType_FILE_CHANGE_TYPE_MODIFIED)

	return &proto.WriteFileResponse{
		Success:      true,
		Message:      fmt.Sprintf("Successfully wrote %d bytes", n),
		BytesWritten: int64(n),
	}, nil
}

// isPathSafe ensures a path is within the root directory (security check)
func isPathSafe(rootPath, path string) bool {
	absRoot, err := filepath.Abs(rootPath)
	if err != nil {
		return false
	}

	absPath, err := filepath.Abs(path)
	if err != nil {
		return false
	}

	return absRoot == absPath || isSubPath(absRoot, absPath)
}

// isSubPath checks if childPath is a subdirectory of parentPath
func isSubPath(parentPath, childPath string) bool {
	rel, err := filepath.Rel(parentPath, childPath)
	if err != nil {
		return false
	}

	return rel != ".." && !strings.HasPrefix(rel, "..")
}

// detectMimeType provides basic MIME type detection based on file extension
func detectMimeType(filename string) string {
	ext := strings.ToLower(filepath.Ext(filename))

	// Simple mapping of extensions to MIME types
	mimeTypes := map[string]string{
		".jpg":  "image/jpeg",
		".jpeg": "image/jpeg",
		".png":  "image/png",
		".gif":  "image/gif",
		".bmp":  "image/bmp",
		".webp": "image/webp",
		".mp4":  "video/mp4",
		".mov":  "video/quicktime",
		".avi":  "video/x-msvideo",
		".wmv":  "video/x-ms-wmv",
		".mkv":  "video/x-matroska",
		".mp3":  "audio/mpeg",
		".wav":  "audio/wav",
		".ogg":  "audio/ogg",
		".txt":  "text/plain",
		".pdf":  "application/pdf",
		".doc":  "application/msword",
		".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
		".xls":  "application/vnd.ms-excel",
		".xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
		".zip":  "application/zip",
		".tar":  "application/x-tar",
		".gz":   "application/gzip",
	}

	if mime, ok := mimeTypes[ext]; ok {
		return mime
	}

	// Default to binary data
	return "application/octet-stream"
}
