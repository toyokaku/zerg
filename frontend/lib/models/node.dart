import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'node.g.dart';

enum NodeRole {
  undefined,
  master,
  worker
}

enum NodeStatus {
  unknown,
  online,
  offline,
  error
}

@JsonSerializable()
class Node {
  final String id;
  final String name;
  @JsonKey(name: 'ip_address')
  final String ipAddress;
  @JsonKey(name: 'is_on')
  final bool isOn;
  final NodeRole role;
  final NodeStatus status;

  Node({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.isOn,
    required this.role,
    required this.status,
  });

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
  Map<String, dynamic> toJson() => _$NodeToJson(this);

  String get roleText {
    switch (role) {
      case NodeRole.undefined:
        return 'Undefined';
      case NodeRole.master:
        return 'Master';
      case NodeRole.worker:
        return 'Worker';
    }
  }

  String get statusText {
    switch (status) {
      case NodeStatus.unknown:
        return 'Unknown';
      case NodeStatus.online:
        return 'Online';
      case NodeStatus.offline:
        return 'Offline';
      case NodeStatus.error:
        return 'Error';
    }
  }

  Color get statusColor {
    switch (status) {
      case NodeStatus.unknown:
        return Colors.grey;
      case NodeStatus.online:
        return Colors.green;
      case NodeStatus.offline:
        return Colors.red;
      case NodeStatus.error:
        return Colors.orange;
    }
  }
}

class K3sNode {
  final String name;
  final bool isOnline;
  final String role;
  final Map<String, dynamic> resources;
  final DateTime lastSeen;

  K3sNode({
    required this.name,
    required this.isOnline,
    required this.role,
    required this.resources,
    required this.lastSeen,
  });

  factory K3sNode.fromJson(Map<String, dynamic> json) {
    return K3sNode(
      name: json['name'] as String,
      isOnline: json['isOnline'] as bool,
      role: json['role'] as String,
      resources: json['resources'] as Map<String, dynamic>,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isOnline': isOnline,
      'role': role,
      'resources': resources,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }
}

// Note: Run 'flutter pub run build_runner build' to generate the node.g.dart file 