// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ip_address'] as String,
      isOn: json['is_on'] as bool,
      role: $enumDecode(_$NodeRoleEnumMap, json['role']),
      status: $enumDecode(_$NodeStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ip_address': instance.ipAddress,
      'is_on': instance.isOn,
      'role': _$NodeRoleEnumMap[instance.role]!,
      'status': _$NodeStatusEnumMap[instance.status]!,
    };

const _$NodeRoleEnumMap = {
  NodeRole.undefined: 'undefined',
  NodeRole.master: 'master',
  NodeRole.worker: 'worker',
};

const _$NodeStatusEnumMap = {
  NodeStatus.unknown: 'unknown',
  NodeStatus.online: 'online',
  NodeStatus.offline: 'offline',
  NodeStatus.error: 'error',
};
