//
//  Generated code. Do not modify.
//  source: node_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'node_service.pb.dart' as $1;

export 'node_service.pb.dart';

@$pb.GrpcServiceName('proto.NodeService')
class NodeServiceClient extends $grpc.Client {
  static final _$getNodes = $grpc.ClientMethod<$1.GetNodesRequest, $1.GetNodesResponse>(
      '/proto.NodeService/GetNodes',
      ($1.GetNodesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.GetNodesResponse.fromBuffer(value));
  static final _$ping = $grpc.ClientMethod<$1.PingRequest, $1.PingResponse>(
      '/proto.NodeService/Ping',
      ($1.PingRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.PingResponse.fromBuffer(value));
  static final _$getStats = $grpc.ClientMethod<$1.StatsRequest, $1.StatsResponse>(
      '/proto.NodeService/GetStats',
      ($1.StatsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $1.StatsResponse.fromBuffer(value));

  NodeServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$1.GetNodesResponse> getNodes($1.GetNodesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNodes, request, options: options);
  }

  $grpc.ResponseFuture<$1.PingResponse> ping($1.PingRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ping, request, options: options);
  }

  $grpc.ResponseFuture<$1.StatsResponse> getStats($1.StatsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getStats, request, options: options);
  }
}

@$pb.GrpcServiceName('proto.NodeService')
abstract class NodeServiceBase extends $grpc.Service {
  $core.String get $name => 'proto.NodeService';

  NodeServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.GetNodesRequest, $1.GetNodesResponse>(
        'GetNodes',
        getNodes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetNodesRequest.fromBuffer(value),
        ($1.GetNodesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.PingRequest, $1.PingResponse>(
        'Ping',
        ping_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.PingRequest.fromBuffer(value),
        ($1.PingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.StatsRequest, $1.StatsResponse>(
        'GetStats',
        getStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.StatsRequest.fromBuffer(value),
        ($1.StatsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.GetNodesResponse> getNodes_Pre($grpc.ServiceCall call, $async.Future<$1.GetNodesRequest> request) async {
    return getNodes(call, await request);
  }

  $async.Future<$1.PingResponse> ping_Pre($grpc.ServiceCall call, $async.Future<$1.PingRequest> request) async {
    return ping(call, await request);
  }

  $async.Future<$1.StatsResponse> getStats_Pre($grpc.ServiceCall call, $async.Future<$1.StatsRequest> request) async {
    return getStats(call, await request);
  }

  $async.Future<$1.GetNodesResponse> getNodes($grpc.ServiceCall call, $1.GetNodesRequest request);
  $async.Future<$1.PingResponse> ping($grpc.ServiceCall call, $1.PingRequest request);
  $async.Future<$1.StatsResponse> getStats($grpc.ServiceCall call, $1.StatsRequest request);
}
