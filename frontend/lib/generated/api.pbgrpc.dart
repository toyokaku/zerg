//
//  Generated code. Do not modify.
//  source: api.proto
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

import 'api.pb.dart' as $0;

export 'api.pb.dart';

@$pb.GrpcServiceName('api.BadgerService')
class BadgerServiceClient extends $grpc.Client {
  static final _$startJob = $grpc.ClientMethod<$0.StartJobRequest, $0.StartJobResponse>(
      '/api.BadgerService/StartJob',
      ($0.StartJobRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.StartJobResponse.fromBuffer(value));
  static final _$getJobStatus = $grpc.ClientMethod<$0.GetJobStatusRequest, $0.GetJobStatusResponse>(
      '/api.BadgerService/GetJobStatus',
      ($0.GetJobStatusRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetJobStatusResponse.fromBuffer(value));
  static final _$listJobs = $grpc.ClientMethod<$0.ListJobsRequest, $0.ListJobsResponse>(
      '/api.BadgerService/ListJobs',
      ($0.ListJobsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListJobsResponse.fromBuffer(value));
  static final _$powerOnNode = $grpc.ClientMethod<$0.NodeControlRequest, $0.NodeControlResponse>(
      '/api.BadgerService/PowerOnNode',
      ($0.NodeControlRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.NodeControlResponse.fromBuffer(value));
  static final _$powerOffNode = $grpc.ClientMethod<$0.NodeControlRequest, $0.NodeControlResponse>(
      '/api.BadgerService/PowerOffNode',
      ($0.NodeControlRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.NodeControlResponse.fromBuffer(value));
  static final _$listNodes = $grpc.ClientMethod<$0.ListNodesRequest, $0.ListNodesResponse>(
      '/api.BadgerService/ListNodes',
      ($0.ListNodesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListNodesResponse.fromBuffer(value));

  BadgerServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.StartJobResponse> startJob($0.StartJobRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$startJob, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetJobStatusResponse> getJobStatus($0.GetJobStatusRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getJobStatus, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListJobsResponse> listJobs($0.ListJobsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listJobs, request, options: options);
  }

  $grpc.ResponseFuture<$0.NodeControlResponse> powerOnNode($0.NodeControlRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$powerOnNode, request, options: options);
  }

  $grpc.ResponseFuture<$0.NodeControlResponse> powerOffNode($0.NodeControlRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$powerOffNode, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListNodesResponse> listNodes($0.ListNodesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listNodes, request, options: options);
  }
}

@$pb.GrpcServiceName('api.BadgerService')
abstract class BadgerServiceBase extends $grpc.Service {
  $core.String get $name => 'api.BadgerService';

  BadgerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.StartJobRequest, $0.StartJobResponse>(
        'StartJob',
        startJob_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StartJobRequest.fromBuffer(value),
        ($0.StartJobResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetJobStatusRequest, $0.GetJobStatusResponse>(
        'GetJobStatus',
        getJobStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetJobStatusRequest.fromBuffer(value),
        ($0.GetJobStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListJobsRequest, $0.ListJobsResponse>(
        'ListJobs',
        listJobs_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListJobsRequest.fromBuffer(value),
        ($0.ListJobsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.NodeControlRequest, $0.NodeControlResponse>(
        'PowerOnNode',
        powerOnNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.NodeControlRequest.fromBuffer(value),
        ($0.NodeControlResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.NodeControlRequest, $0.NodeControlResponse>(
        'PowerOffNode',
        powerOffNode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.NodeControlRequest.fromBuffer(value),
        ($0.NodeControlResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListNodesRequest, $0.ListNodesResponse>(
        'ListNodes',
        listNodes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListNodesRequest.fromBuffer(value),
        ($0.ListNodesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.StartJobResponse> startJob_Pre($grpc.ServiceCall call, $async.Future<$0.StartJobRequest> request) async {
    return startJob(call, await request);
  }

  $async.Future<$0.GetJobStatusResponse> getJobStatus_Pre($grpc.ServiceCall call, $async.Future<$0.GetJobStatusRequest> request) async {
    return getJobStatus(call, await request);
  }

  $async.Future<$0.ListJobsResponse> listJobs_Pre($grpc.ServiceCall call, $async.Future<$0.ListJobsRequest> request) async {
    return listJobs(call, await request);
  }

  $async.Future<$0.NodeControlResponse> powerOnNode_Pre($grpc.ServiceCall call, $async.Future<$0.NodeControlRequest> request) async {
    return powerOnNode(call, await request);
  }

  $async.Future<$0.NodeControlResponse> powerOffNode_Pre($grpc.ServiceCall call, $async.Future<$0.NodeControlRequest> request) async {
    return powerOffNode(call, await request);
  }

  $async.Future<$0.ListNodesResponse> listNodes_Pre($grpc.ServiceCall call, $async.Future<$0.ListNodesRequest> request) async {
    return listNodes(call, await request);
  }

  $async.Future<$0.StartJobResponse> startJob($grpc.ServiceCall call, $0.StartJobRequest request);
  $async.Future<$0.GetJobStatusResponse> getJobStatus($grpc.ServiceCall call, $0.GetJobStatusRequest request);
  $async.Future<$0.ListJobsResponse> listJobs($grpc.ServiceCall call, $0.ListJobsRequest request);
  $async.Future<$0.NodeControlResponse> powerOnNode($grpc.ServiceCall call, $0.NodeControlRequest request);
  $async.Future<$0.NodeControlResponse> powerOffNode($grpc.ServiceCall call, $0.NodeControlRequest request);
  $async.Future<$0.ListNodesResponse> listNodes($grpc.ServiceCall call, $0.ListNodesRequest request);
}
@$pb.GrpcServiceName('api.OvermindService')
class OvermindServiceClient extends $grpc.Client {
  static final _$executeJob = $grpc.ClientMethod<$0.Job, $0.Job>(
      '/api.OvermindService/ExecuteJob',
      ($0.Job value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Job.fromBuffer(value));
  static final _$cancelJob = $grpc.ClientMethod<$0.GetJobStatusRequest, $0.GetJobStatusResponse>(
      '/api.OvermindService/CancelJob',
      ($0.GetJobStatusRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetJobStatusResponse.fromBuffer(value));
  static final _$getJobDetails = $grpc.ClientMethod<$0.GetJobStatusRequest, $0.GetJobStatusResponse>(
      '/api.OvermindService/GetJobDetails',
      ($0.GetJobStatusRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetJobStatusResponse.fromBuffer(value));
  static final _$getClusterStatus = $grpc.ClientMethod<$0.ListNodesRequest, $0.ListNodesResponse>(
      '/api.OvermindService/GetClusterStatus',
      ($0.ListNodesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListNodesResponse.fromBuffer(value));

  OvermindServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.Job> executeJob($0.Job request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$executeJob, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetJobStatusResponse> cancelJob($0.GetJobStatusRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$cancelJob, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetJobStatusResponse> getJobDetails($0.GetJobStatusRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getJobDetails, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListNodesResponse> getClusterStatus($0.ListNodesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getClusterStatus, request, options: options);
  }
}

@$pb.GrpcServiceName('api.OvermindService')
abstract class OvermindServiceBase extends $grpc.Service {
  $core.String get $name => 'api.OvermindService';

  OvermindServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Job, $0.Job>(
        'ExecuteJob',
        executeJob_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Job.fromBuffer(value),
        ($0.Job value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetJobStatusRequest, $0.GetJobStatusResponse>(
        'CancelJob',
        cancelJob_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetJobStatusRequest.fromBuffer(value),
        ($0.GetJobStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetJobStatusRequest, $0.GetJobStatusResponse>(
        'GetJobDetails',
        getJobDetails_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetJobStatusRequest.fromBuffer(value),
        ($0.GetJobStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListNodesRequest, $0.ListNodesResponse>(
        'GetClusterStatus',
        getClusterStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListNodesRequest.fromBuffer(value),
        ($0.ListNodesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.Job> executeJob_Pre($grpc.ServiceCall call, $async.Future<$0.Job> request) async {
    return executeJob(call, await request);
  }

  $async.Future<$0.GetJobStatusResponse> cancelJob_Pre($grpc.ServiceCall call, $async.Future<$0.GetJobStatusRequest> request) async {
    return cancelJob(call, await request);
  }

  $async.Future<$0.GetJobStatusResponse> getJobDetails_Pre($grpc.ServiceCall call, $async.Future<$0.GetJobStatusRequest> request) async {
    return getJobDetails(call, await request);
  }

  $async.Future<$0.ListNodesResponse> getClusterStatus_Pre($grpc.ServiceCall call, $async.Future<$0.ListNodesRequest> request) async {
    return getClusterStatus(call, await request);
  }

  $async.Future<$0.Job> executeJob($grpc.ServiceCall call, $0.Job request);
  $async.Future<$0.GetJobStatusResponse> cancelJob($grpc.ServiceCall call, $0.GetJobStatusRequest request);
  $async.Future<$0.GetJobStatusResponse> getJobDetails($grpc.ServiceCall call, $0.GetJobStatusRequest request);
  $async.Future<$0.ListNodesResponse> getClusterStatus($grpc.ServiceCall call, $0.ListNodesRequest request);
}
