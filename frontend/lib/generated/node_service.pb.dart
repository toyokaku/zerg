//
//  Generated code. Do not modify.
//  source: node_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

/// Empty request for getting nodes
class GetNodesRequest extends $pb.GeneratedMessage {
  factory GetNodesRequest() => create();
  GetNodesRequest._() : super();
  factory GetNodesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNodesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNodesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'proto'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNodesRequest clone() => GetNodesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNodesRequest copyWith(void Function(GetNodesRequest) updates) => super.copyWith((message) => updates(message as GetNodesRequest)) as GetNodesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNodesRequest create() => GetNodesRequest._();
  GetNodesRequest createEmptyInstance() => create();
  static $pb.PbList<GetNodesRequest> createRepeated() => $pb.PbList<GetNodesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNodesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNodesRequest>(create);
  static GetNodesRequest? _defaultInstance;
}

/// Response containing a list of nodes
class GetNodesResponse extends $pb.GeneratedMessage {
  factory GetNodesResponse({
    $core.Iterable<ClusterNode>? nodes,
  }) {
    final $result = create();
    if (nodes != null) {
      $result.nodes.addAll(nodes);
    }
    return $result;
  }
  GetNodesResponse._() : super();
  factory GetNodesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNodesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNodesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'proto'), createEmptyInstance: create)
    ..pc<ClusterNode>(1, _omitFieldNames ? '' : 'nodes', $pb.PbFieldType.PM, subBuilder: ClusterNode.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNodesResponse clone() => GetNodesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNodesResponse copyWith(void Function(GetNodesResponse) updates) => super.copyWith((message) => updates(message as GetNodesResponse)) as GetNodesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNodesResponse create() => GetNodesResponse._();
  GetNodesResponse createEmptyInstance() => create();
  static $pb.PbList<GetNodesResponse> createRepeated() => $pb.PbList<GetNodesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNodesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNodesResponse>(create);
  static GetNodesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ClusterNode> get nodes => $_getList(0);
}

/// ClusterNode represents a K3s node
class ClusterNode extends $pb.GeneratedMessage {
  factory ClusterNode({
    $core.String? name,
    $core.bool? isOnline,
    $core.String? role,
    $core.Map<$core.String, ResourceInfo>? resources,
    $core.String? lastSeen,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (isOnline != null) {
      $result.isOnline = isOnline;
    }
    if (role != null) {
      $result.role = role;
    }
    if (resources != null) {
      $result.resources.addAll(resources);
    }
    if (lastSeen != null) {
      $result.lastSeen = lastSeen;
    }
    return $result;
  }
  ClusterNode._() : super();
  factory ClusterNode.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClusterNode.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClusterNode', package: const $pb.PackageName(_omitMessageNames ? '' : 'proto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'isOnline')
    ..aOS(3, _omitFieldNames ? '' : 'role')
    ..m<$core.String, ResourceInfo>(4, _omitFieldNames ? '' : 'resources', entryClassName: 'ClusterNode.ResourcesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: ResourceInfo.create, valueDefaultOrMaker: ResourceInfo.getDefault, packageName: const $pb.PackageName('proto'))
    ..aOS(5, _omitFieldNames ? '' : 'lastSeen')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClusterNode clone() => ClusterNode()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClusterNode copyWith(void Function(ClusterNode) updates) => super.copyWith((message) => updates(message as ClusterNode)) as ClusterNode;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClusterNode create() => ClusterNode._();
  ClusterNode createEmptyInstance() => create();
  static $pb.PbList<ClusterNode> createRepeated() => $pb.PbList<ClusterNode>();
  @$core.pragma('dart2js:noInline')
  static ClusterNode getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClusterNode>(create);
  static ClusterNode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isOnline => $_getBF(1);
  @$pb.TagNumber(2)
  set isOnline($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsOnline() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsOnline() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get role => $_getSZ(2);
  @$pb.TagNumber(3)
  set role($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearRole() => clearField(3);

  @$pb.TagNumber(4)
  $core.Map<$core.String, ResourceInfo> get resources => $_getMap(3);

  @$pb.TagNumber(5)
  $core.String get lastSeen => $_getSZ(4);
  @$pb.TagNumber(5)
  set lastSeen($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLastSeen() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastSeen() => clearField(5);
}

/// ResourceInfo contains usage information for a resource
class ResourceInfo extends $pb.GeneratedMessage {
  factory ResourceInfo({
    $core.double? used,
    $core.double? total,
  }) {
    final $result = create();
    if (used != null) {
      $result.used = used;
    }
    if (total != null) {
      $result.total = total;
    }
    return $result;
  }
  ResourceInfo._() : super();
  factory ResourceInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResourceInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResourceInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'proto'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'used', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'total', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ResourceInfo clone() => ResourceInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ResourceInfo copyWith(void Function(ResourceInfo) updates) => super.copyWith((message) => updates(message as ResourceInfo)) as ResourceInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResourceInfo create() => ResourceInfo._();
  ResourceInfo createEmptyInstance() => create();
  static $pb.PbList<ResourceInfo> createRepeated() => $pb.PbList<ResourceInfo>();
  @$core.pragma('dart2js:noInline')
  static ResourceInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResourceInfo>(create);
  static ResourceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get used => $_getN(0);
  @$pb.TagNumber(1)
  set used($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUsed() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsed() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get total => $_getN(1);
  @$pb.TagNumber(2)
  set total($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => clearField(2);
}

/// Simple ping request with a message
class PingRequest extends $pb.GeneratedMessage {
  factory PingRequest({
    $core.String? message,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  PingRequest._() : super();
  factory PingRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PingRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PingRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'proto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PingRequest clone() => PingRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PingRequest copyWith(void Function(PingRequest) updates) => super.copyWith((message) => updates(message as PingRequest)) as PingRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingRequest create() => PingRequest._();
  PingRequest createEmptyInstance() => create();
  static $pb.PbList<PingRequest> createRepeated() => $pb.PbList<PingRequest>();
  @$core.pragma('dart2js:noInline')
  static PingRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PingRequest>(create);
  static PingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
}

/// Ping response with server timestamp
class PingResponse extends $pb.GeneratedMessage {
  factory PingResponse({
    $core.String? message,
    $fixnum.Int64? timestamp,
    $core.int? pingCount,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (pingCount != null) {
      $result.pingCount = pingCount;
    }
    return $result;
  }
  PingResponse._() : super();
  factory PingResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PingResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PingResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'proto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'pingCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PingResponse clone() => PingResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PingResponse copyWith(void Function(PingResponse) updates) => super.copyWith((message) => updates(message as PingResponse)) as PingResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingResponse create() => PingResponse._();
  PingResponse createEmptyInstance() => create();
  static $pb.PbList<PingResponse> createRepeated() => $pb.PbList<PingResponse>();
  @$core.pragma('dart2js:noInline')
  static PingResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PingResponse>(create);
  static PingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get pingCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set pingCount($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPingCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearPingCount() => clearField(3);
}

/// StatsRequest is a request for backend stats
class StatsRequest extends $pb.GeneratedMessage {
  factory StatsRequest() => create();
  StatsRequest._() : super();
  factory StatsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StatsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StatsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'proto'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StatsRequest clone() => StatsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StatsRequest copyWith(void Function(StatsRequest) updates) => super.copyWith((message) => updates(message as StatsRequest)) as StatsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatsRequest create() => StatsRequest._();
  StatsRequest createEmptyInstance() => create();
  static $pb.PbList<StatsRequest> createRepeated() => $pb.PbList<StatsRequest>();
  @$core.pragma('dart2js:noInline')
  static StatsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StatsRequest>(create);
  static StatsRequest? _defaultInstance;
}

/// StatsResponse contains backend stats
class StatsResponse extends $pb.GeneratedMessage {
  factory StatsResponse({
    $core.String? serverName,
    $core.String? version,
    $fixnum.Int64? uptimeSeconds,
    $core.Iterable<SystemStat>? stats,
  }) {
    final $result = create();
    if (serverName != null) {
      $result.serverName = serverName;
    }
    if (version != null) {
      $result.version = version;
    }
    if (uptimeSeconds != null) {
      $result.uptimeSeconds = uptimeSeconds;
    }
    if (stats != null) {
      $result.stats.addAll(stats);
    }
    return $result;
  }
  StatsResponse._() : super();
  factory StatsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StatsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StatsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'proto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'serverName')
    ..aOS(2, _omitFieldNames ? '' : 'version')
    ..aInt64(3, _omitFieldNames ? '' : 'uptimeSeconds')
    ..pc<SystemStat>(4, _omitFieldNames ? '' : 'stats', $pb.PbFieldType.PM, subBuilder: SystemStat.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StatsResponse clone() => StatsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StatsResponse copyWith(void Function(StatsResponse) updates) => super.copyWith((message) => updates(message as StatsResponse)) as StatsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatsResponse create() => StatsResponse._();
  StatsResponse createEmptyInstance() => create();
  static $pb.PbList<StatsResponse> createRepeated() => $pb.PbList<StatsResponse>();
  @$core.pragma('dart2js:noInline')
  static StatsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StatsResponse>(create);
  static StatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serverName => $_getSZ(0);
  @$pb.TagNumber(1)
  set serverName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasServerName() => $_has(0);
  @$pb.TagNumber(1)
  void clearServerName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get version => $_getSZ(1);
  @$pb.TagNumber(2)
  set version($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get uptimeSeconds => $_getI64(2);
  @$pb.TagNumber(3)
  set uptimeSeconds($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUptimeSeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearUptimeSeconds() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<SystemStat> get stats => $_getList(3);
}

/// SystemStat represents a system metric
class SystemStat extends $pb.GeneratedMessage {
  factory SystemStat({
    $core.String? name,
    $core.double? value,
    $core.String? unit,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (value != null) {
      $result.value = value;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    return $result;
  }
  SystemStat._() : super();
  factory SystemStat.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SystemStat.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemStat', package: const $pb.PackageName(_omitMessageNames ? '' : 'proto'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OD)
    ..aOS(3, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SystemStat clone() => SystemStat()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SystemStat copyWith(void Function(SystemStat) updates) => super.copyWith((message) => updates(message as SystemStat)) as SystemStat;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemStat create() => SystemStat._();
  SystemStat createEmptyInstance() => create();
  static $pb.PbList<SystemStat> createRepeated() => $pb.PbList<SystemStat>();
  @$core.pragma('dart2js:noInline')
  static SystemStat getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SystemStat>(create);
  static SystemStat? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get unit => $_getSZ(2);
  @$pb.TagNumber(3)
  set unit($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnit() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
