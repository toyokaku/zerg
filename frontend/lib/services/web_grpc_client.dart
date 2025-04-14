// This file is only imported in web platform
import 'package:grpc/grpc_web.dart';
import '../generated/node_service.pbgrpc.dart';

// Creates a NodeServiceClient for web platform
NodeServiceClient createWebNodeClient(String host, int port) {
  final channel = GrpcWebClientChannel.xhr(
    Uri.parse('http://$host:$port'),
  );
  
  return NodeServiceClient(channel);
} 