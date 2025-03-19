import 'package:flutter/material.dart';
import '../models/node.dart';

class NodeStatusCard extends StatelessWidget {
  final K3sNode node;

  const NodeStatusCard({Key? key, required this.node}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  node.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _buildStatusIndicator(),
              ],
            ),
            const SizedBox(height: 8),
            Text('Role: ${node.role}'),
            const SizedBox(height: 16),
            _buildResourcesSection(),
            const SizedBox(height: 8),
            Text(
              'Last seen: ${_formatDateTime(node.lastSeen)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: node.isOnline ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(node.isOnline ? 'Online' : 'Offline'),
      ],
    );
  }

  Widget _buildResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resources:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...node.resources.entries.map((entry) {
          final resourceName = entry.key;
          final resourceData = entry.value;
          final used = resourceData['used'];
          final total = resourceData['total'];
          final percentage = (used / total * 100).toStringAsFixed(1);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$resourceName: $used / $total ${_getUnit(resourceName)} ($percentage%)'),
                LinearProgressIndicator(
                  value: used / total,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForUsage(used / total),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getUnit(String resourceName) {
    switch (resourceName) {
      case 'cpu':
        return 'cores';
      case 'memory':
        return 'GB';
      case 'storage':
        return 'GB';
      case 'gpu':
        return 'units';
      default:
        return '';
    }
  }

  Color _getColorForUsage(double ratio) {
    if (ratio < 0.6) return Colors.green;
    if (ratio < 0.8) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
} 