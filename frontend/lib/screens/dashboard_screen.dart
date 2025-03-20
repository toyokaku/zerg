import 'dart:async';
import 'package:flutter/material.dart';
import '../services/grpc_client.dart';
import '../generated/node_service.pb.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GrpcClient _grpcClient = GrpcClient();
  List<ClusterNode> _nodes = [];
  bool _isLoadingNodes = true;
  bool _isLoadingPing = false;
  bool _isLoadingStats = true;
  String _errorMessage = '';
  PingResponse? _lastResponse;
  StatsResponse? _statsResponse;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadNodes();
    _loadStats();
    
    // Refresh data every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadNodes();
      _loadStats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNodes() async {
    if (!_grpcClient.isInitialized) {
      setState(() {
        _errorMessage = 'gRPC client not initialized';
        _isLoadingNodes = false;
      });
      return;
    }
    
    setState(() {
      _isLoadingNodes = true;
      _errorMessage = '';
    });
    
    int retries = 0;
    const maxRetries = 3;
    
    Future<bool> tryLoadNodes() async {
      try {
        debugPrint('Attempting to load nodes (attempt ${retries + 1})');
        final response = await _grpcClient.getNodes();
        
        setState(() {
          _nodes = response.nodes;
          _isLoadingNodes = false;
          _errorMessage = '';
        });
        
        debugPrint('Successfully loaded ${_nodes.length} nodes');
        return true;
      } catch (e) {
        retries++;
        if (retries < maxRetries) {
          debugPrint('Loading nodes attempt $retries failed: $e. Retrying in 1 second...');
          await Future.delayed(const Duration(seconds: 1));
          return tryLoadNodes();
        } else {
          setState(() {
            _errorMessage = 'Error loading nodes after $maxRetries attempts: $e';
            _isLoadingNodes = false;
          });
          debugPrint('Failed to load nodes after $maxRetries attempts: $e');
          return false;
        }
      }
    }
    
    await tryLoadNodes();
  }

  Future<void> _loadStats() async {
    if (!_grpcClient.isInitialized) {
      setState(() {
        _isLoadingStats = false;
      });
      return;
    }
    
    try {
      final response = await _grpcClient.getStats();
      setState(() {
        _statsResponse = response;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _sendPing() async {
    if (!_grpcClient.isInitialized) {
      setState(() {
        _errorMessage = 'gRPC client not initialized';
      });
      return;
    }
    
    setState(() {
      _isLoadingPing = true;
    });
    
    try {
      final response = await _grpcClient.ping('Ping from Flutter at ${DateTime.now()}');
      setState(() {
        _lastResponse = response;
        _isLoadingPing = false;
      });
      
      // Refresh stats after ping
      await _loadStats();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending ping: $e';
        _isLoadingPing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zerg Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoadingNodes ? null : () {
              _loadNodes();
              _loadStats();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadNodes();
          await _loadStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage.isNotEmpty)
                Card(
                  color: Colors.red.shade50,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Error',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Server info and ping card
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Server Information',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      _isLoadingStats
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow('Server Name', _statsResponse?.serverName ?? 'N/A'),
                                _infoRow('Version', _statsResponse?.version ?? 'N/A'),
                                _infoRow('Uptime', _statsResponse != null 
                                    ? '${_statsResponse!.uptimeSeconds} seconds' 
                                    : 'N/A'),
                                const SizedBox(height: 8.0),
                                const Text('System Stats:'),
                                ...(_statsResponse?.stats.map((stat) => 
                                  _infoRow(stat.name, '${stat.value} ${stat.unit}')
                                ) ?? [_infoRow('No stats', 'available')]),
                              ],
                            ),
                      const SizedBox(height: 16.0),
                      const Divider(),
                      const SizedBox(height: 16.0),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _isLoadingPing ? null : _sendPing,
                          icon: const Icon(Icons.send),
                          label: Text(_isLoadingPing ? 'Sending...' : 'Send Ping'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ),
                      if (_lastResponse != null) ...[
                        const SizedBox(height: 16.0),
                        const Text(
                          'Last Ping Response:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        _infoRow('Message', _lastResponse!.message),
                        _infoRow('Timestamp', DateTime.fromMillisecondsSinceEpoch(
                          _lastResponse!.timestamp.toInt()).toString()),
                        _infoRow('Ping Count', _lastResponse!.pingCount.toString()),
                      ],
                    ],
                  ),
                ),
              ),
              
              _buildClusterOverview(),
              const SizedBox(height: 24),
              
              // Node cards
              const Text(
                'Nodes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _isLoadingNodes
                  ? const Center(child: CircularProgressIndicator())
                  : _nodes.isEmpty 
                      ? _buildEmptyNodeCard()
                      : Column(
                          children: _nodes.map((node) => _buildNodeCard(node)).toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClusterOverview() {
    final nodesCount = _nodes.length;
    final onlineCount = _nodes.where((n) => n.isOnline).length;
    final offlineCount = nodesCount - onlineCount;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cluster Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildOverviewItem(
                  Icons.dns,
                  'Total Nodes',
                  _isLoadingNodes ? '...' : nodesCount.toString(),
                ),
                _buildOverviewItem(
                  Icons.check_circle,
                  'Online',
                  _isLoadingNodes ? '...' : onlineCount.toString(),
                ),
                _buildOverviewItem(
                  Icons.cancel,
                  'Offline',
                  _isLoadingNodes ? '...' : offlineCount.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNodeCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 8),
                const Text(
                  'No Nodes Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'No nodes were retrieved from the server. This could be due to:',
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• No nodes are registered with the cluster'),
                  Text('• The server is running in local mode'),
                  Text('• Connection issues with the gRPC server'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Try refreshing or check the server status.'),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeCard(ClusterNode node) {
    // Get resources
    final cpuInfo = node.resources['cpu'];
    final memoryInfo = node.resources['memory'];
    final storageInfo = node.resources['storage'];
    final gpuInfo = node.resources['gpu'];

    final Color statusColor = node.isOnline ? Colors.green : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  node.isOnline ? Icons.check_circle : Icons.error,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(node.role).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    node.role,
                    style: TextStyle(
                      color: _getRoleColor(node.role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Resources',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (cpuInfo != null)
              _buildResourceBar('CPU', cpuInfo.used, cpuInfo.total),
            if (memoryInfo != null)
              _buildResourceBar('Memory', memoryInfo.used, memoryInfo.total, 'GB'),
            if (storageInfo != null)
              _buildResourceBar('Storage', storageInfo.used, storageInfo.total, 'GB'),
            if (gpuInfo != null)
              _buildResourceBar('GPU', gpuInfo.used, gpuInfo.total, 'units'),
            const SizedBox(height: 8),
            Text(
              'Last Seen: ${node.lastSeen}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'master':
        return Colors.blue;
      case 'worker':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildResourceBar(String label, double used, double total, [String unit = '']) {
    final percentage = (used / total).clamp(0.0, 1.0);
    final Color barColor = percentage > 0.8 
        ? Colors.red 
        : percentage > 0.6 
            ? Colors.orange 
            : Colors.green;
            
    final formattedUnit = unit.isNotEmpty ? ' $unit' : '';
    final formattedUsage = '${used.toStringAsFixed(1)}/${total.toStringAsFixed(1)}$formattedUnit';
    final percentageText = '${(percentage * 100).toStringAsFixed(1)}%';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$formattedUsage ($percentageText)'),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }
} 