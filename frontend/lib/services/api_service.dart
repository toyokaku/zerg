import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';
import '../models/node.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Job endpoints
  Future<Job> startJob(String name, String description, String jobType) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/job/start'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description,
        'job_type': jobType,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Job.fromJson(data['job']);
    } else {
      throw Exception('Failed to start job: ${response.statusCode}');
    }
  }

  Future<Job> getJobStatus(String jobId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/job/status/$jobId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Job.fromJson(data['job']);
    } else {
      throw Exception('Failed to get job status: ${response.statusCode}');
    }
  }

  Future<List<Job>> listJobs({int page = 1, int pageSize = 10, String? filter}) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (filter != null) 'filter': filter,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/jobs').replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['jobs'] as List).map((job) => Job.fromJson(job)).toList();
    } else {
      throw Exception('Failed to list jobs: ${response.statusCode}');
    }
  }

  // Node endpoints
  Future<Node> powerOnNode(String nodeId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/device/on'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': nodeId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Node.fromJson(data['device']);
    } else {
      throw Exception('Failed to power on node: ${response.statusCode}');
    }
  }

  Future<Node> powerOffNode(String nodeId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/device/off'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': nodeId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Node.fromJson(data['device']);
    } else {
      throw Exception('Failed to power off node: ${response.statusCode}');
    }
  }

  Future<List<Node>> listNodes({int page = 1, int pageSize = 10, String? filter}) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (filter != null) 'filter': filter,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/nodes').replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['nodes'] as List).map((node) => Node.fromJson(node)).toList();
    } else {
      throw Exception('Failed to list nodes: ${response.statusCode}');
    }
  }
}

// Provider for the API service
final apiServiceProvider = Provider<ApiService>((ref) {
  // In a real app, you might want to get this from environment variables or settings
  const baseUrl = 'http://localhost:8080';
  return ApiService(baseUrl: baseUrl);
}); 