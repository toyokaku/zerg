//
//  Generated code. Do not modify.
//  source: api.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use jobStatusDescriptor instead')
const JobStatus$json = {
  '1': 'JobStatus',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'PENDING', '2': 1},
    {'1': 'RUNNING', '2': 2},
    {'1': 'COMPLETED', '2': 3},
    {'1': 'FAILED', '2': 4},
  ],
};

/// Descriptor for `JobStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List jobStatusDescriptor = $convert.base64Decode(
    'CglKb2JTdGF0dXMSCwoHVU5LTk9XThAAEgsKB1BFTkRJTkcQARILCgdSVU5OSU5HEAISDQoJQ0'
    '9NUExFVEVEEAMSCgoGRkFJTEVEEAQ=');

@$core.Deprecated('Use nodeRoleDescriptor instead')
const NodeRole$json = {
  '1': 'NodeRole',
  '2': [
    {'1': 'UNDEFINED', '2': 0},
    {'1': 'MASTER', '2': 1},
    {'1': 'WORKER', '2': 2},
  ],
};

/// Descriptor for `NodeRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nodeRoleDescriptor = $convert.base64Decode(
    'CghOb2RlUm9sZRINCglVTkRFRklORUQQABIKCgZNQVNURVIQARIKCgZXT1JLRVIQAg==');

@$core.Deprecated('Use nodeStatusDescriptor instead')
const NodeStatus$json = {
  '1': 'NodeStatus',
  '2': [
    {'1': 'NODE_UNKNOWN', '2': 0},
    {'1': 'NODE_ONLINE', '2': 1},
    {'1': 'NODE_OFFLINE', '2': 2},
    {'1': 'NODE_ERROR', '2': 3},
  ],
};

/// Descriptor for `NodeStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nodeStatusDescriptor = $convert.base64Decode(
    'CgpOb2RlU3RhdHVzEhAKDE5PREVfVU5LTk9XThAAEg8KC05PREVfT05MSU5FEAESEAoMTk9ERV'
    '9PRkZMSU5FEAISDgoKTk9ERV9FUlJPUhAD');

@$core.Deprecated('Use jobDescriptor instead')
const Job$json = {
  '1': 'Job',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'status', '3': 4, '4': 1, '5': 14, '6': '.api.JobStatus', '10': 'status'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 6, '4': 1, '5': 3, '10': 'updatedAt'},
    {'1': 'job_type', '3': 7, '4': 1, '5': 9, '10': 'jobType'},
    {'1': 'payload', '3': 8, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `Job`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List jobDescriptor = $convert.base64Decode(
    'CgNKb2ISDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb2'
    '4YAyABKAlSC2Rlc2NyaXB0aW9uEiYKBnN0YXR1cxgEIAEoDjIOLmFwaS5Kb2JTdGF0dXNSBnN0'
    'YXR1cxIdCgpjcmVhdGVkX2F0GAUgASgDUgljcmVhdGVkQXQSHQoKdXBkYXRlZF9hdBgGIAEoA1'
    'IJdXBkYXRlZEF0EhkKCGpvYl90eXBlGAcgASgJUgdqb2JUeXBlEhgKB3BheWxvYWQYCCABKAxS'
    'B3BheWxvYWQ=');

@$core.Deprecated('Use nodeDescriptor instead')
const Node$json = {
  '1': 'Node',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'ip_address', '3': 3, '4': 1, '5': 9, '10': 'ipAddress'},
    {'1': 'is_on', '3': 4, '4': 1, '5': 8, '10': 'isOn'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.api.NodeRole', '10': 'role'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.api.NodeStatus', '10': 'status'},
  ],
};

/// Descriptor for `Node`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeDescriptor = $convert.base64Decode(
    'CgROb2RlEg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh0KCmlwX2FkZHJlc3'
    'MYAyABKAlSCWlwQWRkcmVzcxITCgVpc19vbhgEIAEoCFIEaXNPbhIhCgRyb2xlGAUgASgOMg0u'
    'YXBpLk5vZGVSb2xlUgRyb2xlEicKBnN0YXR1cxgGIAEoDjIPLmFwaS5Ob2RlU3RhdHVzUgZzdG'
    'F0dXM=');

@$core.Deprecated('Use startJobRequestDescriptor instead')
const StartJobRequest$json = {
  '1': 'StartJobRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'job_type', '3': 3, '4': 1, '5': 9, '10': 'jobType'},
    {'1': 'payload', '3': 4, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `StartJobRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startJobRequestDescriptor = $convert.base64Decode(
    'Cg9TdGFydEpvYlJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgCIA'
    'EoCVILZGVzY3JpcHRpb24SGQoIam9iX3R5cGUYAyABKAlSB2pvYlR5cGUSGAoHcGF5bG9hZBgE'
    'IAEoDFIHcGF5bG9hZA==');

@$core.Deprecated('Use startJobResponseDescriptor instead')
const StartJobResponse$json = {
  '1': 'StartJobResponse',
  '2': [
    {'1': 'job', '3': 1, '4': 1, '5': 11, '6': '.api.Job', '10': 'job'},
  ],
};

/// Descriptor for `StartJobResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startJobResponseDescriptor = $convert.base64Decode(
    'ChBTdGFydEpvYlJlc3BvbnNlEhoKA2pvYhgBIAEoCzIILmFwaS5Kb2JSA2pvYg==');

@$core.Deprecated('Use getJobStatusRequestDescriptor instead')
const GetJobStatusRequest$json = {
  '1': 'GetJobStatusRequest',
  '2': [
    {'1': 'job_id', '3': 1, '4': 1, '5': 9, '10': 'jobId'},
  ],
};

/// Descriptor for `GetJobStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getJobStatusRequestDescriptor = $convert.base64Decode(
    'ChNHZXRKb2JTdGF0dXNSZXF1ZXN0EhUKBmpvYl9pZBgBIAEoCVIFam9iSWQ=');

@$core.Deprecated('Use getJobStatusResponseDescriptor instead')
const GetJobStatusResponse$json = {
  '1': 'GetJobStatusResponse',
  '2': [
    {'1': 'job', '3': 1, '4': 1, '5': 11, '6': '.api.Job', '10': 'job'},
  ],
};

/// Descriptor for `GetJobStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getJobStatusResponseDescriptor = $convert.base64Decode(
    'ChRHZXRKb2JTdGF0dXNSZXNwb25zZRIaCgNqb2IYASABKAsyCC5hcGkuSm9iUgNqb2I=');

@$core.Deprecated('Use listJobsRequestDescriptor instead')
const ListJobsRequest$json = {
  '1': 'ListJobsRequest',
  '2': [
    {'1': 'page', '3': 1, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'filter', '3': 3, '4': 1, '5': 9, '10': 'filter'},
  ],
};

/// Descriptor for `ListJobsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listJobsRequestDescriptor = $convert.base64Decode(
    'Cg9MaXN0Sm9ic1JlcXVlc3QSEgoEcGFnZRgBIAEoBVIEcGFnZRIbCglwYWdlX3NpemUYAiABKA'
    'VSCHBhZ2VTaXplEhYKBmZpbHRlchgDIAEoCVIGZmlsdGVy');

@$core.Deprecated('Use listJobsResponseDescriptor instead')
const ListJobsResponse$json = {
  '1': 'ListJobsResponse',
  '2': [
    {'1': 'jobs', '3': 1, '4': 3, '5': 11, '6': '.api.Job', '10': 'jobs'},
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `ListJobsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listJobsResponseDescriptor = $convert.base64Decode(
    'ChBMaXN0Sm9ic1Jlc3BvbnNlEhwKBGpvYnMYASADKAsyCC5hcGkuSm9iUgRqb2JzEhQKBXRvdG'
    'FsGAIgASgFUgV0b3RhbA==');

@$core.Deprecated('Use nodeControlRequestDescriptor instead')
const NodeControlRequest$json = {
  '1': 'NodeControlRequest',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 9, '10': 'nodeId'},
  ],
};

/// Descriptor for `NodeControlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeControlRequestDescriptor = $convert.base64Decode(
    'ChJOb2RlQ29udHJvbFJlcXVlc3QSFwoHbm9kZV9pZBgBIAEoCVIGbm9kZUlk');

@$core.Deprecated('Use nodeControlResponseDescriptor instead')
const NodeControlResponse$json = {
  '1': 'NodeControlResponse',
  '2': [
    {'1': 'node', '3': 1, '4': 1, '5': 11, '6': '.api.Node', '10': 'node'},
  ],
};

/// Descriptor for `NodeControlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeControlResponseDescriptor = $convert.base64Decode(
    'ChNOb2RlQ29udHJvbFJlc3BvbnNlEh0KBG5vZGUYASABKAsyCS5hcGkuTm9kZVIEbm9kZQ==');

@$core.Deprecated('Use listNodesRequestDescriptor instead')
const ListNodesRequest$json = {
  '1': 'ListNodesRequest',
  '2': [
    {'1': 'page', '3': 1, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'filter', '3': 3, '4': 1, '5': 9, '10': 'filter'},
  ],
};

/// Descriptor for `ListNodesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNodesRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0Tm9kZXNSZXF1ZXN0EhIKBHBhZ2UYASABKAVSBHBhZ2USGwoJcGFnZV9zaXplGAIgAS'
    'gFUghwYWdlU2l6ZRIWCgZmaWx0ZXIYAyABKAlSBmZpbHRlcg==');

@$core.Deprecated('Use listNodesResponseDescriptor instead')
const ListNodesResponse$json = {
  '1': 'ListNodesResponse',
  '2': [
    {'1': 'nodes', '3': 1, '4': 3, '5': 11, '6': '.api.Node', '10': 'nodes'},
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `ListNodesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listNodesResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0Tm9kZXNSZXNwb25zZRIfCgVub2RlcxgBIAMoCzIJLmFwaS5Ob2RlUgVub2RlcxIUCg'
    'V0b3RhbBgCIAEoBVIFdG90YWw=');

