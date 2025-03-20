//
//  Generated code. Do not modify.
//  source: api.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// JobStatus represents the status of a job
class JobStatus extends $pb.ProtobufEnum {
  static const JobStatus UNKNOWN = JobStatus._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const JobStatus PENDING = JobStatus._(1, _omitEnumNames ? '' : 'PENDING');
  static const JobStatus RUNNING = JobStatus._(2, _omitEnumNames ? '' : 'RUNNING');
  static const JobStatus COMPLETED = JobStatus._(3, _omitEnumNames ? '' : 'COMPLETED');
  static const JobStatus FAILED = JobStatus._(4, _omitEnumNames ? '' : 'FAILED');

  static const $core.List<JobStatus> values = <JobStatus> [
    UNKNOWN,
    PENDING,
    RUNNING,
    COMPLETED,
    FAILED,
  ];

  static final $core.Map<$core.int, JobStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static JobStatus? valueOf($core.int value) => _byValue[value];

  const JobStatus._($core.int v, $core.String n) : super(v, n);
}

/// NodeRole represents the role of a node in the cluster
class NodeRole extends $pb.ProtobufEnum {
  static const NodeRole UNDEFINED = NodeRole._(0, _omitEnumNames ? '' : 'UNDEFINED');
  static const NodeRole MASTER = NodeRole._(1, _omitEnumNames ? '' : 'MASTER');
  static const NodeRole WORKER = NodeRole._(2, _omitEnumNames ? '' : 'WORKER');

  static const $core.List<NodeRole> values = <NodeRole> [
    UNDEFINED,
    MASTER,
    WORKER,
  ];

  static final $core.Map<$core.int, NodeRole> _byValue = $pb.ProtobufEnum.initByValue(values);
  static NodeRole? valueOf($core.int value) => _byValue[value];

  const NodeRole._($core.int v, $core.String n) : super(v, n);
}

/// NodeStatus represents the status of a node
class NodeStatus extends $pb.ProtobufEnum {
  static const NodeStatus NODE_UNKNOWN = NodeStatus._(0, _omitEnumNames ? '' : 'NODE_UNKNOWN');
  static const NodeStatus NODE_ONLINE = NodeStatus._(1, _omitEnumNames ? '' : 'NODE_ONLINE');
  static const NodeStatus NODE_OFFLINE = NodeStatus._(2, _omitEnumNames ? '' : 'NODE_OFFLINE');
  static const NodeStatus NODE_ERROR = NodeStatus._(3, _omitEnumNames ? '' : 'NODE_ERROR');

  static const $core.List<NodeStatus> values = <NodeStatus> [
    NODE_UNKNOWN,
    NODE_ONLINE,
    NODE_OFFLINE,
    NODE_ERROR,
  ];

  static final $core.Map<$core.int, NodeStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static NodeStatus? valueOf($core.int value) => _byValue[value];

  const NodeStatus._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
