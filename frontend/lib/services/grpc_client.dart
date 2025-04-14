import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
// Import the right client based on platform
// ignore: undefined_symbol
import 'web_grpc_client.dart' if (dart.library.io) 'empty_web_client.dart';
import 'package:fixnum/fixnum.dart';

import '../generated/node_service.pbgrpc.dart';
import '../generated/node_service.pb.dart' as node_proto;

/// GrpcClient provides access to the badger gRPC services
class GrpcClient {
  static final GrpcClient _instance = GrpcClient._internal();
  
  factory GrpcClient() => _instance;
  
  GrpcClient._internal();
  
  // Default host settings - will be determined at runtime
  String _host = 'localhost';
  static const int _defaultPort = 8090;
  
  // For native clients
  ClientChannel? _channel;
  
  NodeServiceClient? _nodeClient;
  bool _initialized = false;
  
  bool get isInitialized => _initialized;
  
  /// Initialize the gRPC client
  Future<void> initialize() async {
    try {
      if (_initialized) {
        debugPrint('GrpcClient already initialized');
        return;
      }

      // Determine appropriate host based on platform
      _configureHostForPlatform();
      
      if (kIsWeb) {
        debugPrint('Initializing GrpcClient for Web using gRPC-Web');
        
        // Web implementation is handled by web_grpc_client.dart
        _nodeClient = createWebNodeClient(_host, _defaultPort);
      } else {
        debugPrint('Initializing GrpcClient for Native on ${_getPlatformName()}');
        
        // Native platforms use ClientChannel
        _channel = ClientChannel(
          _host,
          port: _defaultPort,
          options: const ChannelOptions(
            credentials: ChannelCredentials.insecure(),
            idleTimeout: Duration(minutes: 1),
          ),
        );
        
        _nodeClient = NodeServiceClient(_channel!);
      }
      
      // Test the connection with retries
      int retries = 0;
      const maxRetries = 3;
      bool connected = false;
      
      while (retries < maxRetries && !connected) {
        try {
          debugPrint('Testing connection attempt ${retries + 1}/$maxRetries to $_host:$_defaultPort');
          
          final request = node_proto.PingRequest()..message = 'Test connection';
          final pingResponse = await _nodeClient!.ping(
            request,
            options: CallOptions(timeout: const Duration(seconds: 5)),
          );
          
          debugPrint('Connection successful: ${pingResponse.message}');
          connected = true;
        } catch (e, stackTrace) {
          retries++;
          debugPrint('Connection attempt $retries failed: $e');
          debugPrint('Stack trace: $stackTrace');
          
          if (retries < maxRetries) {
            debugPrint('Retrying in 1 second...');
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }
      
      if (!connected) {
        debugPrint('Failed to connect after $maxRetries attempts, but continuing anyway');
        // Continue anyway, as the user might be in an environment where the server
        // isn't available but we still want the app to load
      }
      
      _initialized = true;
    } catch (e, stackTrace) {
      debugPrint('Error initializing GrpcClient: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  // Configure the appropriate host based on the platform
  void _configureHostForPlatform() {
    if (kIsWeb) {
      // Web client typically connects to the origin server
      _host = 'localhost';
    } else {
      if (!kIsWeb) {
        // Platform-specific host configurations
        try {
          if (Platform.isAndroid) {
            // Android emulator needs special IP to access host machine
            _host = '10.0.2.2'; // Special IP for Android emulator to access host machine
            debugPrint('Configured for Android: Using emulator host $_host');
          } else if (Platform.isLinux) {
            // Linux just uses localhost
            _host = 'localhost';
            debugPrint('Configured for Linux: Using host $_host');
          } else {
            // Default fallback
            _host = 'localhost';
            debugPrint('Using default host $_host for ${_getPlatformName()}');
          }
        } catch (e) {
          // In case Platform is not available
          _host = 'localhost';
          debugPrint('Platform detection failed, using default host $_host');
        }
      }
    }
  }
  
  // Helper to get a readable platform name for logs
  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isLinux) return 'Linux';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isFuchsia) return 'Fuchsia';
    } catch (e) {
      return 'Unknown (Platform detection failed)';
    }
    return 'Unknown';
  }
  
  /// Close the gRPC channel
  void dispose() {
    _channel?.shutdown();
    _channel = null;
    _nodeClient = null;
    _initialized = false;
  }
  
  /// Send a ping message and get a response
  Future<node_proto.PingResponse> ping(String message) async {
    _checkInitialized();
    
    try {
      debugPrint('Sending ping message: $message');
      
      final request = node_proto.PingRequest()..message = message;
      final response = await _nodeClient!.ping(
        request,
        options: CallOptions(timeout: const Duration(seconds: 10)),
      );
      
      debugPrint('Received ping response: ${response.message}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('Error sending ping: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // For demo/dev purposes only, return mock data if real service fails
      if (kDebugMode) {
        debugPrint('Returning mock ping response for debugging');
        return node_proto.PingResponse()
          ..message = 'Pong: $message (mock)'
          ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
          ..pingCount = 1;
      }
      
      rethrow;
    }
  }
  
  /// Get server stats
  Future<node_proto.StatsResponse> getStats() async {
    _checkInitialized();
    
    try {
      debugPrint('Getting server stats');
      
      final request = node_proto.StatsRequest();
      final response = await _nodeClient!.getStats(
        request,
        options: CallOptions(timeout: const Duration(seconds: 10)),
      );
      
      debugPrint('Received stats: ${response.serverName}, ${response.version}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('Error getting stats: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // For demo/dev purposes only, return mock data if real service fails
      if (kDebugMode) {
        debugPrint('Returning mock stats response for debugging');
        final mockResponse = node_proto.StatsResponse()
          ..serverName = 'Badger Service (mock)'
          ..version = '1.0.0'
          ..uptimeSeconds = Int64(300);
        
        mockResponse.stats.add(
          node_proto.SystemStat()
            ..name = 'Ping Count'
            ..value = 1.0
            ..unit = 'requests'
        );
        
        return mockResponse;
      }
      
      rethrow;
    }
  }
  
  /// Get nodes from the server
  Future<node_proto.GetNodesResponse> getNodes() async {
    _checkInitialized();
    
    try {
      debugPrint('Getting nodes from server');
      
      final request = node_proto.GetNodesRequest();
      final response = await _nodeClient!.getNodes(
        request,
        options: CallOptions(timeout: const Duration(seconds: 15)),
      );
      
      debugPrint('Received ${response.nodes.length} nodes');
      return response;
    } catch (e, stackTrace) {
      debugPrint('Error getting nodes: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // For demo/dev purposes only, return mock data if real service fails
      if (kDebugMode) {
        debugPrint('Returning mock nodes response for debugging');
        return _createMockNodesResponse();
      }
      
      rethrow;
    }
  }
  
  // Check if the client is initialized
  void _checkInitialized() {
    if (!_initialized) {
      throw Exception('GrpcClient not initialized. Call initialize() first.');
    }
  }
  
  // Helper method to create mock nodes response for testing
  node_proto.GetNodesResponse _createMockNodesResponse() {
    final response = node_proto.GetNodesResponse();
    
    // Create first mock node
    final node1 = node_proto.ClusterNode()
      ..name = 'node1'
      ..isOnline = true
      ..role = 'worker'
      ..lastSeen = DateTime.now().toIso8601String();
      
    // Add resource data
    final cpuResource1 = node_proto.ResourceInfo()
      ..used = 2.0
      ..total = 8.0;
    
    final memResource1 = node_proto.ResourceInfo()
      ..used = 4.0
      ..total = 16.0;
      
    node1.resources['cpu'] = cpuResource1;
    node1.resources['memory'] = memResource1;
    
    // Create second mock node
    final node2 = node_proto.ClusterNode()
      ..name = 'node2'
      ..isOnline = true
      ..role = 'master'
      ..lastSeen = DateTime.now().toIso8601String();
    
    // Add resource data
    final cpuResource2 = node_proto.ResourceInfo()
      ..used = 1.0
      ..total = 4.0;
    
    final memResource2 = node_proto.ResourceInfo()
      ..used = 2.0
      ..total = 8.0;
      
    node2.resources['cpu'] = cpuResource2;
    node2.resources['memory'] = memResource2;
    
    // Add nodes to response
    response.nodes.add(node1);
    response.nodes.add(node2);
    
    return response;
  }
}
