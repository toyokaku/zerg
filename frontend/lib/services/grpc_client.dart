import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:http/http.dart' as http;
import 'package:fixnum/fixnum.dart';

import '../generated/node_service.pbgrpc.dart';
import '../generated/node_service.pb.dart' as node_proto;

/// GrpcClient provides access to the badger gRPC services
class GrpcClient {
  static final GrpcClient _instance = GrpcClient._internal();
  
  factory GrpcClient() => _instance;
  
  GrpcClient._internal();
  
  // Use dynamic type to support both channel types
  dynamic _channel;
  NodeServiceClient? _nodeClient;
  String? _webBaseUrl;
  
  bool get isInitialized => _channel != null || _webBaseUrl != null;
  
  /// Initialize the gRPC client with the badger server address
  void initialize(String serverAddress) {
    if (_channel != null) {
      _channel!.shutdown();
    }
    
    // For web clients, store the address for HTTP requests
    if (kIsWeb) {
      _webBaseUrl = 'http://$serverAddress';
      debugPrint('Initialized for web with server address: $_webBaseUrl');
      return;
    }
    
    // For native platforms, create gRPC channel
    final parts = serverAddress.split(':');
    final host = parts[0];
    final port = parts.length > 1 ? int.parse(parts[1]) : 9090;
    
    _channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        idleTimeout: Duration(minutes: 1),
        connectTimeout: Duration(seconds: 20),
      ),
    );
    
    // Create service clients
    _nodeClient = NodeServiceClient(_channel);
    
    debugPrint('gRPC client initialized with server: $serverAddress');
  }
  
  /// Close the gRPC channel
  void dispose() {
    _channel?.shutdown();
    _channel = null;
    _nodeClient = null;
    _webBaseUrl = null;
  }
  
  /// Send a ping message and get a response
  Future<PingResponse> ping(String message) async {
    try {
      debugPrint('Sending ping message: $message');
      
      // For web, use HTTP
      if (kIsWeb) {
        if (_webBaseUrl == null) {
          throw StateError('GrpcClient not initialized. Call initialize() first.');
        }
        
        final response = await http.post(
          Uri.parse('$_webBaseUrl/proto.NodeService/Ping'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': message}),
        );
        
        if (response.statusCode != 200) {
          throw Exception('Failed to ping: ${response.statusCode}');
        }
        
        final jsonData = jsonDecode(response.body);
        
        // Create response object from JSON
        final pingResponse = PingResponse()
          ..message = jsonData['message']
          ..timestamp = Int64(jsonData['timestamp'])
          ..pingCount = jsonData['pingCount'];
        
        debugPrint('Received ping response: ${pingResponse.message}');
        return pingResponse;
      }
      
      // For native platforms, use gRPC
      final request = PingRequest()..message = message;
      final response = await nodeService.ping(
        request,
        options: CallOptions(timeout: const Duration(seconds: 10)),
      );
      
      debugPrint('Received ping response: ${response.message}');
      return response;
    } catch (e) {
      debugPrint('Error sending ping: $e');
      rethrow;
    }
  }
  
  /// Get server stats
  Future<StatsResponse> getStats() async {
    try {
      debugPrint('Getting server stats');
      
      // For web, use HTTP
      if (kIsWeb) {
        if (_webBaseUrl == null) {
          throw StateError('GrpcClient not initialized. Call initialize() first.');
        }
        
        final response = await http.post(
          Uri.parse('$_webBaseUrl/proto.NodeService/GetStats'),
          headers: {'Content-Type': 'application/json'},
          body: '{}',
        );
        
        if (response.statusCode != 200) {
          throw Exception('Failed to get stats: ${response.statusCode}');
        }
        
        final jsonData = jsonDecode(response.body);
        
        // Create response object from JSON
        final statsResponse = StatsResponse()
          ..serverName = jsonData['serverName']
          ..version = jsonData['version']
          ..uptimeSeconds = jsonData['uptimeSeconds'];
        
        if (jsonData['stats'] != null) {
          for (var statJson in jsonData['stats']) {
            final stat = SystemStat()
              ..name = statJson['name']
              ..value = statJson['value'].toDouble()
              ..unit = statJson['unit'];
            
            statsResponse.stats.add(stat);
          }
        }
        
        debugPrint('Received stats: ${statsResponse.serverName}, ${statsResponse.version}');
        return statsResponse;
      }
      
      // For native platforms, use gRPC
      final request = StatsRequest();
      final response = await nodeService.getStats(
        request,
        options: CallOptions(timeout: const Duration(seconds: 10)),
      );
      
      debugPrint('Received stats: ${response.serverName}, ${response.version}');
      return response;
    } catch (e) {
      debugPrint('Error getting stats: $e');
      rethrow;
    }
  }
  
  /// Get nodes from the server
  Future<GetNodesResponse> getNodes() async {
    try {
      debugPrint('Getting nodes from server');
      
      // For web, use HTTP
      if (kIsWeb) {
        if (_webBaseUrl == null) {
          throw StateError('GrpcClient not initialized. Call initialize() first.');
        }
        
        final response = await http.post(
          Uri.parse('$_webBaseUrl/proto.NodeService/GetNodes'),
          headers: {'Content-Type': 'application/json'},
          body: '{}',
        );
        
        if (response.statusCode != 200) {
          throw Exception('Failed to get nodes: ${response.statusCode}');
        }
        
        final jsonData = jsonDecode(response.body);
        
        // Create response object from JSON
        final nodesResponse = GetNodesResponse();
        if (jsonData['nodes'] != null) {
          for (var nodeJson in jsonData['nodes']) {
            final node = Node()
              ..name = nodeJson['name']
              ..isOnline = nodeJson['isOnline']
              ..role = nodeJson['role']
              ..lastSeen = nodeJson['lastSeen'];
            
            // Process resources
            if (nodeJson['resources'] != null) {
              nodeJson['resources'].forEach((key, value) {
                node.resources[key] = node_proto.ResourceInfo()
                  ..used = value['used'].toDouble()
                  ..total = value['total'].toDouble();
              });
            }
            
            nodesResponse.nodes.add(node);
          }
        }
        
        debugPrint('Received ${nodesResponse.nodes.length} nodes');
        return nodesResponse;
      }
      
      // For native platforms, use gRPC
      final request = GetNodesRequest();
      final response = await nodeService.getNodes(
        request,
        options: CallOptions(timeout: const Duration(seconds: 10)),
      );
      
      debugPrint('Received ${response.nodes.length} nodes');
      return response;
    } catch (e) {
      debugPrint('Error getting nodes: $e');
      rethrow;
    }
  }
  
  /// Get the node service client
  NodeServiceClient get nodeService {
    if (_nodeClient == null) {
      throw StateError('GrpcClient not initialized or running in web mode. Call initialize() first.');
    }
    return _nodeClient!;
  }
}
