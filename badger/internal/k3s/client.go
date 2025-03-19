package k3s

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
	metricsv "k8s.io/metrics/pkg/client/clientset/versioned"
)

// Client represents a K3s client
type Client struct {
	clientset     *kubernetes.Clientset
	metricsClient *metricsv.Clientset
	Disabled      bool
}

// NewClient creates a new K3s client
func NewClient() (*Client, error) {
	// Skip K8s initialization if NO_K8S environment variable is set
	if os.Getenv("NO_K8S") != "" || os.Getenv("DISABLE_K8S") != "" || os.Getenv("LOCAL_MODE") != "" {
		fmt.Println("K8s client is disabled by environment variable")
		return &Client{
			Disabled: true,
		}, nil
	}

	// Try in-cluster config first
	config, err := rest.InClusterConfig()
	if err != nil {
		// Fall back to kubeconfig
		home := homedir.HomeDir()
		kubeconfig := filepath.Join(home, ".kube", "config")
		config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)
		if err != nil {
			return nil, fmt.Errorf("failed to create K8s config: %w", err)
		}
	}

	// Create clientset
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		return nil, fmt.Errorf("failed to create K8s clientset: %w", err)
	}

	// Create metrics client
	metricsClient, err := metricsv.NewForConfig(config)
	if err != nil {
		return nil, fmt.Errorf("failed to create K8s metrics client: %w", err)
	}

	return &Client{
		clientset:     clientset,
		metricsClient: metricsClient,
		Disabled:      false,
	}, nil
}

// NodeInfo contains information about a K3s node
type NodeInfo struct {
	Name      string
	IsOnline  bool
	Role      string
	Resources map[string]ResourceInfo
	LastSeen  time.Time
}

// ResourceInfo contains usage information for a resource
type ResourceInfo struct {
	Used  float64
	Total float64
}

// GetNodes returns information about all nodes in the K3s cluster
func (c *Client) GetNodes(ctx context.Context) ([]NodeInfo, error) {
	// Return empty list if client is disabled
	if c.Disabled {
		return []NodeInfo{}, nil
	}

	// Get nodes
	nodes, err := c.clientset.CoreV1().Nodes().List(ctx, metav1.ListOptions{})
	if err != nil {
		return nil, fmt.Errorf("failed to list nodes: %w", err)
	}

	// Get node metrics
	nodeMetrics, err := c.metricsClient.MetricsV1beta1().NodeMetricses().List(ctx, metav1.ListOptions{})
	if err != nil {
		return nil, fmt.Errorf("failed to get node metrics: %w", err)
	}

	// Create a map of node name to metrics
	metricsMap := make(map[string]metav1.ObjectMeta)
	for _, metric := range nodeMetrics.Items {
		metricsMap[metric.Name] = metric.ObjectMeta
	}

	// Convert to NodeInfo
	var nodeInfos []NodeInfo
	for _, node := range nodes.Items {
		// Determine if node is online
		isOnline := true
		for _, condition := range node.Status.Conditions {
			if condition.Type == "Ready" {
				isOnline = condition.Status == "True"
				break
			}
		}

		// Determine node role
		role := "worker"
		if _, isMaster := node.Labels["node-role.kubernetes.io/master"]; isMaster {
			role = "master"
		} else if _, isControlPlane := node.Labels["node-role.kubernetes.io/control-plane"]; isControlPlane {
			role = "master"
		}

		// Get resource usage
		resources := make(map[string]ResourceInfo)

		// CPU
		cpuCapacity := node.Status.Capacity.Cpu().AsApproximateFloat64()
		cpuUsed := 0.0
		if _, ok := metricsMap[node.Name]; ok {
			cpuUsed = nodeMetrics.Items[0].Usage.Cpu().AsApproximateFloat64()
		}
		resources["cpu"] = ResourceInfo{
			Used:  cpuUsed,
			Total: cpuCapacity,
		}

		// Memory
		memoryCapacity := float64(node.Status.Capacity.Memory().Value()) / (1024 * 1024 * 1024) // Convert to GB
		memoryUsed := 0.0
		if _, ok := metricsMap[node.Name]; ok {
			memoryUsed = float64(nodeMetrics.Items[0].Usage.Memory().Value()) / (1024 * 1024 * 1024) // Convert to GB
		}
		resources["memory"] = ResourceInfo{
			Used:  memoryUsed,
			Total: memoryCapacity,
		}

		// GPU if available
		if gpuCapacity, ok := node.Status.Capacity["nvidia.com/gpu"]; ok {
			resources["gpu"] = ResourceInfo{
				Used:  0, // We don't have GPU usage metrics by default
				Total: gpuCapacity.AsApproximateFloat64(),
			}
		}

		// Create NodeInfo
		nodeInfo := NodeInfo{
			Name:      node.Name,
			IsOnline:  isOnline,
			Role:      role,
			Resources: resources,
			LastSeen:  node.Status.Conditions[0].LastHeartbeatTime.Time,
		}

		nodeInfos = append(nodeInfos, nodeInfo)
	}

	return nodeInfos, nil
}
