// mobile-app/lib/src/widgets/disease_card.dart
import 'package:flutter/material.dart';
import '../models/disease_model.dart';

class DiseaseCard extends StatelessWidget {
  final DiseaseDetection detection;
  final VoidCallback? onTap;
  final bool showDate;
  final bool compact;

  const DiseaseCard({
    Key? key,
    required this.detection,
    this.onTap,
    this.showDate = true,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: compact ? const EdgeInsets.only(bottom: 8) : const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: compact ? _buildCompactContent() : _buildExpandedContent(),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              SeverityIndicator(severity: detection.severity),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detection.diseaseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${detection.plantType} • ${detection.confidencePercentage} confidence',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Treatments Preview
          if (detection.treatments.isNotEmpty) ...[
            Text(
              'Recommended: ${detection.treatments.first}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showDate) ...[
                Text(
                  _formatDate(detection.detectedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
              if (detection.location != null) ...[
                Text(
                  detection.location!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getSeverityColor(detection.severity).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getSeverityIcon(detection.severity),
              color: _getSeverityColor(detection.severity),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detection.diseaseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${detection.plantType} • ${detection.confidencePercentage}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              detection.severity,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: _getSeverityColor(detection.severity),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Compact disease list item for use in lists
class DiseaseListItem extends StatelessWidget {
  final DiseaseDetection detection;
  final VoidCallback? onTap;

  const DiseaseListItem({
    Key? key,
    required this.detection,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getSeverityColor(detection.severity).withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          _getSeverityIcon(detection.severity),
          color: _getSeverityColor(detection.severity),
          size: 20,
        ),
      ),
      title: Text(
        detection.diseaseName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${detection.plantType} • ${detection.confidencePercentage}',
        style: TextStyle(fontSize: 12),
      ),
      trailing: Chip(
        label: Text(
          detection.severity,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: _getSeverityColor(detection.severity),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onTap: onTap,
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }
}
