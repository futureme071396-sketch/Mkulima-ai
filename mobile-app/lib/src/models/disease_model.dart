// mobile-app/lib/src/models/disease_model.dart

class DiseaseDetection {
  final String id;
  final String diseaseName;
  final String plantType;
  final double confidence;
  final String severity; // 'Low', 'Medium', 'High'
  final List<String> treatments;
  final List<String> preventions;
  final DateTime detectedAt;
  final String? imagePath;
  final String? location;

  DiseaseDetection({
    required this.id,
    required this.diseaseName,
    required this.plantType,
    required this.confidence,
    required this.severity,
    required this.treatments,
    required this.preventions,
    required this.detectedAt,
    this.imagePath,
    this.location,
  });

  factory DiseaseDetection.fromJson(Map<String, dynamic> json) {
    return DiseaseDetection(
      id: json['id'] ?? '',
      diseaseName: json['disease_name'] ?? json['disease'] ?? 'Unknown',
      plantType: json['plant_type'] ?? 'maize',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      severity: json['severity'] ?? 'Low',
      treatments: List<String>.from(json['treatment'] ?? json['treatments'] ?? []),
      preventions: List<String>.from(json['prevention'] ?? json['preventions'] ?? []),
      detectedAt: DateTime.parse(json['detected_at'] ?? DateTime.now().toIso8601String()),
      imagePath: json['image_path'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disease_name': diseaseName,
      'plant_type': plantType,
      'confidence': confidence,
      'severity': severity,
      'treatment': treatments,
      'prevention': preventions,
      'detected_at': detectedAt.toIso8601String(),
      'image_path': imagePath,
      'location': location,
    };
  }

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  bool get isHighSeverity => severity.toLowerCase() == 'high';
  bool get isMediumSeverity => severity.toLowerCase() == 'medium';
  bool get isLowSeverity => severity.toLowerCase() == 'low';

  // Helper method to get severity color
  String get severityColor {
    switch (severity.toLowerCase()) {
      case 'high':
        return '#FF4444'; // Red
      case 'medium':
        return '#FFAA00'; // Orange
      case 'low':
        return '#00C851'; // Green
      default:
        return '#33B5E5'; // Blue
    }
  }
}

class DiseaseHistory {
  final List<DiseaseDetection> detections;
  final int totalDetections;
  final String mostCommonDisease;
  final DateTime lastDetection;

  DiseaseHistory({
    required this.detections,
    required this.totalDetections,
    required this.mostCommonDisease,
    required this.lastDetection,
  });

  factory DiseaseHistory.fromJson(Map<String, dynamic> json) {
    final detectionsJson = json['detections'] as List? ?? [];
    return DiseaseHistory(
      detections: detectionsJson.map((d) => DiseaseDetection.fromJson(d)).toList(),
      totalDetections: json['total_detections'] ?? 0,
      mostCommonDisease: json['most_common_disease'] ?? 'None',
      lastDetection: DateTime.parse(json['last_detection'] ?? DateTime.now().toIso8601String()),
    );
  }
}
