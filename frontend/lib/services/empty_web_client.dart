// This file is used as a stub for non-web platforms
// Do not import web-specific packages here
import '../generated/node_service.pbgrpc.dart';

// This function is never actually called in non-web platforms
// It's just a stub to satisfy the import in grpc_client.dart
NodeServiceClient createWebNodeClient(String host, int port) {
  throw UnsupportedError('Web gRPC client is not supported on this platform');
} 