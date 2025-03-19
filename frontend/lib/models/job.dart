import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job.g.dart';

enum JobStatus {
  unknown,
  pending,
  running,
  completed,
  failed
}

@JsonSerializable()
class Job {
  final String id;
  final String name;
  final String description;
  final JobStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'job_type')
  final String jobType;

  Job({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.jobType,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
  Map<String, dynamic> toJson() => _$JobToJson(this);

  String get statusText {
    switch (status) {
      case JobStatus.unknown:
        return 'Unknown';
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.running:
        return 'Running';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.failed:
        return 'Failed';
    }
  }

  Color get statusColor {
    switch (status) {
      case JobStatus.unknown:
        return Colors.grey;
      case JobStatus.pending:
        return Colors.orange;
      case JobStatus.running:
        return Colors.blue;
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.failed:
        return Colors.red;
    }
  }
}

// Note: Run 'flutter pub run build_runner build' to generate the job.g.dart file