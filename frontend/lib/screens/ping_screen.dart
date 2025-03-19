import 'package:flutter/material.dart';
import '../services/grpc_client.dart';
import '../generated/node_service.pb.dart';
import 'package:fixnum/fixnum.dart';

class PingScreen extends StatefulWidget {
  const PingScreen({Key? key}) : super(key: key);

  @override
  State<PingScreen> createState() => _PingScreenState();
}

class _PingScreenState extends State<PingScreen> {
  final _grpcClient = GrpcClient();
  
  bool _isLoading = false;
  PingResponse? _lastResponse;
  StatsResponse? _statsResponse;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadStats();
  }
  
  Future<void> _sendPing() async {
    if (!_grpcClient.isInitialized) {
      setState(() {
        _errorMessage = 'gRPC client not initialized';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final response = await _grpcClient.ping('Ping from Flutter at ${DateTime.now()}');
      setState(() {
        _lastResponse = response;
        _isLoading = false;
      });
      
      // Refresh stats after ping
      await _loadStats();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadStats() async {
    if (!_grpcClient.isInitialized) {
      setState(() {
        _errorMessage = 'gRPC client not initialized';
      });
      return;
    }
    
    try {
      final response = await _grpcClient.getStats();
      setState(() {
        _statsResponse = response;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading stats: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badger Ping Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server info card
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
                    const SizedBox(height: 8.0),
                    if (_statsResponse != null) ...[
                      _infoRow('Server Name', _statsResponse!.serverName),
                      _infoRow('Version', _statsResponse!.version),
                      _infoRow('Uptime', '${_statsResponse!.uptimeSeconds} seconds'),
                      const SizedBox(height: 8.0),
                      const Text('System Stats:'),
                      ...(_statsResponse!.stats.map((stat) => 
                        _infoRow(stat.name, '${stat.value} ${stat.unit}')
                      )),
                    ] else
                      const Text('No server stats available'),
                  ],
                ),
              ),
            ),
            
            // Ping button
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendPing,
                icon: const Icon(Icons.send),
                label: Text(_isLoading ? 'Sending...' : 'Send Ping'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 24.0),
            
            // Response
            if (_lastResponse != null) ...[
              const Text(
                'Last Response:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('Message', _lastResponse!.message),
                      _infoRow('Timestamp', DateTime.fromMillisecondsSinceEpoch(
                        _lastResponse!.timestamp.toInt()).toString()),
                      _infoRow('Ping Count', _lastResponse!.pingCount.toString()),
                    ],
                  ),
                ),
              ),
            ],
            
            // Error message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
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
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 