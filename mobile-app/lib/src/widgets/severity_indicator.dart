// mobile-app/lib/src/widgets/severity_indicator.dart
import 'package:flutter/material.dart';

class SeverityIndicator extends StatelessWidget {
  final String severity;
  final double size;
  final bool showLabel;

  const SeverityIndicator({
    Key? key,
    required this.severity,
    this.size = 24.0,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final severityInfo = _getSeverityInfo(severity);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: severityInfo.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            severityInfo.icon,
            color: severityInfo.color,
            size: size * 0.6,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            severityInfo.label,
            style: TextStyle(
              color: severityInfo.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

// Circular severity indicator (for compact spaces)
class CircularSeverityIndicator extends StatelessWidget {
  final String severity;
  final double size;

  const CircularSeverityIndicator({
    Key? key,
    required this.severity,
    this.size = 32.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final severityInfo = _getSeverityInfo(severity);

    return Tooltip(
      message: severityInfo.label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: severityInfo.color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          severityInfo.icon,
          color: severityInfo.color,
          size: size * 0.6,
        ),
      ),
    );
  }
}

// Linear severity bar (for progress-style display)
class SeverityBar extends StatelessWidget {
  final String severity;
  final double width;
  final double height;

  const SeverityBar({
    Key? key,
    required this.severity,
    this.width = 100.0,
    this.height = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final severityInfo = _getSeverityInfo(severity);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        children: [
          Expanded(
            flex: _getSeverityWeight(severity),
            child: Container(
              decoration: BoxDecoration(
                color: severityInfo.color,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
          Expanded(
            flex: 3 - _getSeverityWeight(severity),
            child: const SizedBox(),
          ),
        ],
      ),
    );
  }

  int _getSeverityWeight(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 1;
    }
  }
}

// Severity badge (for chips and tags)
class SeverityBadge extends StatelessWidget {
  final String severity;
  final bool outlined;

  const SeverityBadge({
    Key? key,
    required this.severity,
    this.outlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final severityInfo = _getSeverityInfo(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: outlined
          ? BoxDecoration(
              border: Border.all(color: severityInfo.color),
              borderRadius: BorderRadius.circular(12),
            )
          : BoxDecoration(
              color: severityInfo.color,
              borderRadius: BorderRadius.circular(12),
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            severityInfo.icon,
            color: outlined ? severityInfo.color : Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            severityInfo.label,
            style: TextStyle(
              color: outlined ? severityInfo.color : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to get severity information
SeverityInfo _getSeverityInfo(String severity) {
  switch (severity.toLowerCase()) {
    case 'high':
      return SeverityInfo(
        label: 'High',
        color: Colors.red,
        icon: Icons.warning,
      );
    case 'medium':
      return SeverityInfo(
        label: 'Medium',
        color: Colors.orange,
        icon: Icons.info,
      );
    case 'low':
      return SeverityInfo(
        label: 'Low',
        color: Colors.green,
        icon: Icons.check_circle,
      );
    default:
      return SeverityInfo(
        label: 'Unknown',
        color: Colors.grey,
        icon: Icons.help,
      );
  }
}

class SeverityInfo {
  final String label;
  final Color color;
  final IconData icon;

  const SeverityInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}
