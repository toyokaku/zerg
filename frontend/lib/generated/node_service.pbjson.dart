//
//  Generated code. Do not modify.
//  source: node_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use getNodesRequestDescriptor instead')
const GetNodesRequest$json = {
  '1': 'GetNodesRequest',
};

/// Descriptor for `GetNodesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNodesRequestDescriptor = $convert.base64Decode(
    'Cg9HZXROb2Rlc1JlcXVlc3Q=');

@$core.Deprecated('Use getNodesResponseDescriptor instead')
const GetNodesResponse$json = {
  '1': 'GetNodesResponse',
  '2': [
    {'1': 'nodes', '3': 1, '4': 3, '5': 11, '6': '.proto.ClusterNode', '10': 'nodes'},
  ],
};

/// Descriptor for `GetNodesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNodesResponseDescriptor = $convert.base64Decode(
    'ChBHZXROb2Rlc1Jlc3BvbnNlEigKBW5vZGVzGAEgAygLMhIucHJvdG8uQ2x1c3Rlck5vZGVSBW'
    '5vZGVz');

@$core.Deprecated('Use clusterNodeDescriptor instead')
const ClusterNode$json = {
  '1': 'ClusterNode',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'is_online', '3': 2, '4': 1, '5': 8, '10': 'isOnline'},
    {'1': 'role', '3': 3, '4': 1, '5': 9, '10': 'role'},
    {'1': 'resources', '3': 4, '4': 3, '5': 11, '6': '.proto.ClusterNode.ResourcesEntry', '10': 'resources'},
    {'1': 'last_seen', '3': 5, '4': 1, '5': 9, '10': 'lastSeen'},
  ],
  '3': [ClusterNode_ResourcesEntry$json],
};

@$core.Deprecated('Use clusterNodeDescriptor instead')
const ClusterNode_ResourcesEntry$json = {
  '1': 'ResourcesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.proto.ResourceInfo', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ClusterNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clusterNodeDescriptor = $convert.base64Decode(
    'CgtDbHVzdGVyTm9kZRISCgRuYW1lGAEgASgJUgRuYW1lEhsKCWlzX29ubGluZRgCIAEoCFIIaX'
    'NPbmxpbmUSEgoEcm9sZRgDIAEoCVIEcm9sZRI/CglyZXNvdXJjZXMYBCADKAsyIS5wcm90by5D'
    'bHVzdGVyTm9kZS5SZXNvdXJjZXNFbnRyeVIJcmVzb3VyY2VzEhsKCWxhc3Rfc2VlbhgFIAEoCV'
    'IIbGFzdFNlZW4aUQoOUmVzb3VyY2VzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSKQoFdmFsdWUY'
    'AiABKAsyEy5wcm90by5SZXNvdXJjZUluZm9SBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use resourceInfoDescriptor instead')
const ResourceInfo$json = {
  '1': 'ResourceInfo',
  '2': [
    {'1': 'used', '3': 1, '4': 1, '5': 1, '10': 'used'},
    {'1': 'total', '3': 2, '4': 1, '5': 1, '10': 'total'},
  ],
};

/// Descriptor for `ResourceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resourceInfoDescriptor = $convert.base64Decode(
    'CgxSZXNvdXJjZUluZm8SEgoEdXNlZBgBIAEoAVIEdXNlZBIUCgV0b3RhbBgCIAEoAVIFdG90YW'
    'w=');

@$core.Deprecated('Use pingRequestDescriptor instead')
const PingRequest$json = {
  '1': 'PingRequest',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `PingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingRequestDescriptor = $convert.base64Decode(
    'CgtQaW5nUmVxdWVzdBIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use pingResponseDescriptor instead')
const PingResponse$json = {
  '1': 'PingResponse',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'ping_count', '3': 3, '4': 1, '5': 5, '10': 'pingCount'},
  ],
};

/// Descriptor for `PingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingResponseDescriptor = $convert.base64Decode(
    'CgxQaW5nUmVzcG9uc2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZRIcCgl0aW1lc3RhbXAYAi'
    'ABKANSCXRpbWVzdGFtcBIdCgpwaW5nX2NvdW50GAMgASgFUglwaW5nQ291bnQ=');

@$core.Deprecated('Use statsRequestDescriptor instead')
const StatsRequest$json = {
  '1': 'StatsRequest',
};

/// Descriptor for `StatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statsRequestDescriptor = $convert.base64Decode(
    'CgxTdGF0c1JlcXVlc3Q=');

@$core.Deprecated('Use statsResponseDescriptor instead')
const StatsResponse$json = {
  '1': 'StatsResponse',
  '2': [
    {'1': 'server_name', '3': 1, '4': 1, '5': 9, '10': 'serverName'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {'1': 'uptime_seconds', '3': 3, '4': 1, '5': 3, '10': 'uptimeSeconds'},
    {'1': 'stats', '3': 4, '4': 3, '5': 11, '6': '.proto.SystemStat', '10': 'stats'},
  ],
};

/// Descriptor for `StatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statsResponseDescriptor = $convert.base64Decode(
    'Cg1TdGF0c1Jlc3BvbnNlEh8KC3NlcnZlcl9uYW1lGAEgASgJUgpzZXJ2ZXJOYW1lEhgKB3Zlcn'
    'Npb24YAiABKAlSB3ZlcnNpb24SJQoOdXB0aW1lX3NlY29uZHMYAyABKANSDXVwdGltZVNlY29u'
    'ZHMSJwoFc3RhdHMYBCADKAsyES5wcm90by5TeXN0ZW1TdGF0UgVzdGF0cw==');

@$core.Deprecated('Use systemStatDescriptor instead')
const SystemStat$json = {
  '1': 'SystemStat',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
    {'1': 'unit', '3': 3, '4': 1, '5': 9, '10': 'unit'},
  ],
};

/// Descriptor for `SystemStat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemStatDescriptor = $convert.base64Decode(
    'CgpTeXN0ZW1TdGF0EhIKBG5hbWUYASABKAlSBG5hbWUSFAoFdmFsdWUYAiABKAFSBXZhbHVlEh'
    'IKBHVuaXQYAyABKAlSBHVuaXQ=');

