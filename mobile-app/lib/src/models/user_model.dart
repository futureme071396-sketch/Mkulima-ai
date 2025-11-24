// mobile-app/lib/src/models/user_model.dart

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String preferredLanguage; // 'sw', 'en', 'kik', 'luo'
  final String region;
  final double farmSize; // in acres
  final List<String> mainCrops;
  final DateTime joinedAt;
  final bool isPremium;
  final int totalScans;
  final int successfulDetections;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.preferredLanguage = 'sw',
    this.region = 'Nairobi',
    this.farmSize = 0.0,
    this.mainCrops = const ['maize'],
    required this.joinedAt,
    this.isPremium = false,
    this.totalScans = 0,
    this.successfulDetections = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Farmer',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      preferredLanguage: json['preferred_language'] ?? 'sw',
      region: json['region'] ?? 'Nairobi',
      farmSize: (json['farm_size'] ?? 0.0).toDouble(),
      mainCrops: List<String>.from(json['main_crops'] ?? ['maize']),
      joinedAt: DateTime.parse(json['joined_at'] ?? DateTime.now().toIso8601String()),
      isPremium: json['is_premium'] ?? false,
      totalScans: json['total_scans'] ?? 0,
      successfulDetections: json['successful_detections'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'preferred_language': preferredLanguage,
      'region': region,
      'farm_size': farmSize,
      'main_crops': mainCrops,
      'joined_at': joinedAt.toIso8601String(),
      'is_premium': isPremium,
      'total_scans': totalScans,
      'successful_detections': successfulDetections,
    };
  }

  double get detectionSuccessRate {
    if (totalScans == 0) return 0.0;
    return successfulDetections / totalScans;
  }

  String get successRatePercentage => '${(detectionSuccessRate * 100).toStringAsFixed(1)}%';

  // Language display names
  String get languageDisplayName {
    switch (preferredLanguage) {
      case 'sw':
        return 'Kiswahili';
      case 'en':
        return 'English';
      case 'kik':
        return 'Gikuyu';
      case 'luo':
        return 'Dholuo';
      default:
        return 'Kiswahili';
    }
  }
}

class UserPreferences {
  final bool offlineMode;
  final bool voiceFeedback;
  final bool saveScanHistory;
  final bool shareAnonymousData;
  final String theme; // 'light', 'dark', 'auto'

  UserPreferences({
    this.offlineMode = true,
    this.voiceFeedback = true,
    this.saveScanHistory = true,
    this.shareAnonymousData = false,
    this.theme = 'light',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      offlineMode: json['offline_mode'] ?? true,
      voiceFeedback: json['voice_feedback'] ?? true,
      saveScanHistory: json['save_scan_history'] ?? true,
      shareAnonymousData: json['share_anonymous_data'] ?? false,
      theme: json['theme'] ?? 'light',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offline_mode': offlineMode,
      'voice_feedback': voiceFeedback,
      'save_scan_history': saveScanHistory,
      'share_anonymous_data': shareAnonymousData,
      'theme': theme,
    };
  }
}
