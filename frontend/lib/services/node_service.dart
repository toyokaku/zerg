import 'dart:convert';
import 'package:grpc/grpc_web.dart';
import 'package:http/http.dart' as http;
import '../models/node.dart';
import '../generated/node_service.pbgrpc.dart';

class NodeService {
  final String host;
  final int port;
  late GrpcWebClientChannel _channel;
  late NodeServiceClient _client;
  bool _useHttp = false;

  NodeService({
    required this.host,
    required this.port,
    bool useHttp = false,
  }) {
    _useHttp = useHttp;
    
    if (!_useHttp) {
      _channel = GrpcWebClientChannel.xhr(
        Uri(scheme: 'http', host: host, port: port),
      );
      _client = NodeServiceClient(_channel);
    }
  }

  Future<List<K3sNode>> getNodes() async {
    if (_useHttp) {
      return _getNodesViaHttp();
    } else {
      return _getNodesViaGrpc();
    }
  }

  Future<List<K3sNode>> _getNodesViaGrpc() async {
    try {
      final request = GetNodesRequest();
      final response = await _client.getNodes(request);
      
      return response.nodes.map((node) {
        // Convert proto resources to the format expected by K3sNode
        final resources = <String, dynamic>{};
        node.resources.forEach((key, value) {
          resources[key] = {
            'used': value.used,
            'total': value.total,
          };
        });
        
        return K3sNode(
          name: node.name,
          isOnline: node.isOnline,
          role: node.role,
          resources: resources,
          lastSeen: DateTime.parse(node.lastSeen),
        );
      }).toList();
    } catch (e) {
      print('Error fetching nodes via gRPC: $e');
      // Re-throw the error to be handled by the caller
      rethrow;
    }
  }

  Future<List<K3sNode>> _getNodesViaHttp() async {
    try {
      final response = await http.get(
        Uri(
          scheme: 'http',
          host: host,
          port: port,
          path: '/api/nodes',
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => K3sNode.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load nodes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nodes via HTTP: $e');
      rethrow;
    }
  }
} 