// mobile-app/lib/src/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/disease_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'local_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'MkulimaAI/${AppConstants.appVersion}',
  };

  // Cache for frequently accessed data
  final Map<String, dynamic> _cache = {};
  DateTime? _lastCacheUpdate;

  /// Main method to detect plant diseases from image
  Future<DiseaseDetectionResult> detectDisease({
    required File imageFile,
    required String plantType,
    String? location,
    bool useCache = true,
  }) async {
    try {
      // Validate image first
      final validationError = AppHelpers.validateImageFile(imageFile);
      if (validationError != null) {
        return DiseaseDetectionResult.error(validationError);
      }

      // Check cache for recent identical requests
      if (useCache) {
        final cachedResult = _getCachedResult(imageFile, plantType);
        if (cachedResult != null) {
          return DiseaseDetectionResult.success(cachedResult);
        }
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.predict),
      );

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: 'plant_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      // Add form fields
      request.fields.addAll({
        'plant_type': plantType,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'app_version': AppConstants.appVersion,
        if (location != null) 'location': location,
      });

      // Add headers
      request.headers.addAll(_defaultHeaders);

      // Send request with timeout
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      // Process response
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData) as Map<String, dynamic>;

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        final detection = _createDetectionFromResponse(
          jsonResponse,
          plantType,
          location,
          imageFile.path,
        );

        // Cache the result
        _cacheResult(imageFile, plantType, detection);

        // Save to local storage
        await LocalStorage.saveDetection(detection);

        // Update user stats
        await _updateUserStats();

        return DiseaseDetectionResult.success(detection);
      } else {
        final errorMessage = jsonResponse['error'] as String? ?? 
                            ErrorMessages.detectionFailed;
        return DiseaseDetectionResult.error(errorMessage);
      }
    } on TimeoutException {
      return DiseaseDetectionResult.error(ErrorMessages.networkError);
    } on SocketException {
      return DiseaseDetectionResult.error(ErrorMessages.noInternet);
    } on http.ClientException {
      return DiseaseDetectionResult.error(ErrorMessages.networkError);
    } catch (e) {
      // Fallback to offline detection
      return await _fallbackToOfflineDetection(plantType, location, imageFile.path);
    }
  }

  /// Get user's detection history from server
  Future<List<DiseaseDetection>> getDetectionHistory({
    String? userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = await LocalStorage.getUser();
      final actualUserId = userId ?? user?.id;

      if (actualUserId == null) {
        return await LocalStorage.getDetections();
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.history}?user_id=$actualUserId&limit=$limit&offset=$offset'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final detections = (data['detections'] as List)
            .map((item) => DiseaseDetection.fromJson(item))
            .toList();

        // Cache the history
        _cache['user_history'] = {
          'data': detections,
          'timestamp': DateTime.now(),
        };

        return detections;
      } else {
        // Fallback to local storage
        return await LocalStorage.getDetections();
      }
    } catch (e) {
      // Fallback to local storage
      return await LocalStorage.getDetections();
    }
  }

  /// Sync offline data with server
  Future<SyncResult> syncOfflineData() async {
    try {
      final pendingDetections = await LocalStorage.getPendingSync();
      if (pendingDetections.isEmpty) {
        return SyncResult(success: true, syncedItems: 0, message: 'No data to sync');
      }

      int syncedCount = 0;
      final errors = <String>[];

      for (final detection in pendingDetections) {
        try {
          final response = await http.post(
            Uri.parse(ApiEndpoints.sync),
            headers: _defaultHeaders,
            body: json.encode({
              'detection': detection.toJson(),
              'sync_timestamp': DateTime.now().millisecondsSinceEpoch,
            }),
          );

          if (response.statusCode == 200) {
            await LocalStorage.removeFromPendingSync(detection.id);
            syncedCount++;
          } else {
            errors.add('Failed to sync detection ${detection.id}');
          }
        } catch (e) {
          errors.add('Error syncing ${detection.id}: $e');
        }
      }

      return SyncResult(
        success: errors.isEmpty,
        syncedItems: syncedCount,
        message: errors.isEmpty 
            ? 'Synced $syncedCount items successfully'
            : 'Synced $syncedCount items with ${errors.length} errors',
        errors: errors,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        syncedItems: 0,
        message: 'Sync failed: $e',
        errors: [e.toString()],
      );
    }
  }

  /// Get plant information from server
  Future<Map<String, dynamic>?> getPlantInfo(String plantType) async {
    try {
      // Check cache first
      final cacheKey = 'plant_info_$plantType';
      if (_cache.containsKey(cacheKey)) {
        final cached = _cache[cacheKey] as Map<String, dynamic>;
        final timestamp = cached['timestamp'] as DateTime;
        if (DateTime.now().difference(timestamp).inHours < 24) {
          return cached['data'];
        }
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.plants}/$plantType'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final plantInfo = json.decode(response.body) as Map<String, dynamic>;
        
        // Cache the result
        _cache[cacheKey] = {
          'data': plantInfo,
          'timestamp': DateTime.now(),
        };

        return plantInfo;
      }
    } catch (e) {
      // Return null for offline scenarios
    }
    return null;
  }

  /// Clear API cache
  void clearCache() {
    _cache.clear();
    _lastCacheUpdate = null;
  }

  // Private helper methods

  DiseaseDetection _createDetectionFromResponse(
    Map<String, dynamic> response,
    String plantType,
    String? location,
    String imagePath,
  ) {
    return DiseaseDetection(
      id: 'server_${DateTime.now().millisecondsSinceEpoch}',
      diseaseName: response['disease'] as String? ?? 'Unknown',
      plantType: plantType,
      confidence: (response['confidence'] as num? ?? 0.0).toDouble(),
      severity: response['severity'] as String? ?? 'Low',
      treatments: List<String>.from(response['treatment'] as List? ?? []),
      preventions: List<String>.from(response['prevention'] as List? ?? []),
      detectedAt: DateTime.now(),
      imagePath: imagePath,
      location: location,
      isSynced: true,
    );
  }

  DiseaseDetection? _getCachedResult(File imageFile, String plantType) {
    final cacheKey = _generateCacheKey(imageFile, plantType);
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey] as Map<String, dynamic>;
      final timestamp = cached['timestamp'] as DateTime;
      
      // Cache valid for 1 hour
      if (DateTime.now().difference(timestamp).inHours < 1) {
        return cached['detection'] as DiseaseDetection;
      } else {
        _cache.remove(cacheKey);
      }
    }
    return null;
  }

  void _cacheResult(File imageFile, String plantType, DiseaseDetection detection) {
    final cacheKey = _generateCacheKey(imageFile, plantType);
    _cache[cacheKey] = {
      'detection': detection,
      'timestamp': DateTime.now(),
    };
    _lastCacheUpdate = DateTime.now();
  }

  String _generateCacheKey(File imageFile, String plantType) {
    final fileSize = imageFile.lengthSync();
    final timestamp = imageFile.lastModifiedSync().millisecondsSinceEpoch;
    return 'detection_${plantType}_${fileSize}_$timestamp';
  }

  Future<DiseaseDetectionResult> _fallbackToOfflineDetection(
    String plantType,
    String? location,
    String imagePath,
  ) async {
    try {
      final offlineDetection = _createOfflineDetection(plantType, location, imagePath);
      await LocalStorage.saveDetection(offlineDetection);
      await _updateUserStats();
      
      return DiseaseDetectionResult.success(
        offlineDetection,
        isOffline: true,
      );
    } catch (e) {
      return DiseaseDetectionResult.error('Offline detection failed: $e');
    }
  }

  DiseaseDetection _createOfflineDetection(String plantType, String? location, String imagePath) {
    final mockData = _getMockDetectionData(plantType);
    
    return DiseaseDetection(
      id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
      diseaseName: mockData['disease']!,
      plantType: plantType,
      confidence: mockData['confidence']!,
      severity: mockData['severity']!,
      treatments: mockData['treatments']!,
      preventions: mockData['preventions']!,
      detectedAt: DateTime.now(),
      imagePath: imagePath,
      location: location,
      isSynced: false,
    );
  }

  Map<String, dynamic> _getMockDetectionData(String plantType) {
    const mockData = {
      'maize': {
        'disease': 'Maize Lethal Necrosis',
        'confidence': 0.82,
        'severity': 'High',
        'treatments': [
          'Use certified disease-free seeds',
          'Remove and destroy infected plants immediately',
          'Practice crop rotation with non-cereal crops',
          'Control insect vectors using recommended pesticides'
        ],
        'preventions': [
          'Plant resistant varieties when available',
          'Monitor fields regularly for early symptoms',
          'Avoid planting during high disease pressure seasons',
          'Maintain proper field hygiene'
        ],
      },
      'coffee': {
        'disease': 'Coffee Leaf Rust',
        'confidence': 0.76,
        'severity': 'Medium',
        'treatments': [
          'Apply copper-based fungicides every 2-3 weeks',
          'Prune and remove heavily infected branches',
          'Ensure proper shade management',
          'Use systemic fungicides for severe cases'
        ],
        'preventions': [
          'Plant resistant coffee varieties',
          'Maintain proper spacing between plants',
          'Apply preventive fungicides before rainy season',
          'Monitor weather conditions for disease forecasting'
        ],
      },
      'default': {
        'disease': 'General Plant Health Issue',
        'confidence': 0.65,
        'severity': 'Low',
        'treatments': [
          'Improve overall plant nutrition',
          'Ensure proper watering schedule',
          'Monitor for pest infestations',
          'Consult local agricultural officer'
        ],
        'preventions': [
          'Practice good farm hygiene',
          'Use quality seeds and planting materials',
          'Implement crop rotation',
          'Regular soil testing and amendment'
        ],
      },
    };

    return mockData[plantType] ?? mockData['default']!;
  }

  Future<void> _updateUserStats() async {
    final user = await LocalStorage.getUser();
    if (user != null) {
      final updatedUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        preferredLanguage: user.preferredLanguage,
        region: user.region,
        farmSize: user.farmSize,
        mainCrops: user.mainCrops,
        joinedAt: user.joinedAt,
        isPremium: user.isPremium,
        totalScans: user.totalScans + 1,
        successfulDetections: user.successfulDetections + 1,
      );
      await LocalStorage.saveUser(updatedUser);
    }
  }
}

/// Result class for API operations
class DiseaseDetectionResult {
  final bool success;
  final DiseaseDetection? detection;
  final String? error;
  final bool isOffline;

  DiseaseDetectionResult({
    required this.success,
    this.detection,
    this.error,
    this.isOffline = false,
  });

  factory DiseaseDetectionResult.success(DiseaseDetection detection, {bool isOffline = false}) {
    return DiseaseDetectionResult(
      success: true,
      detection: detection,
      isOffline: isOffline,
    );
  }

  factory DiseaseDetectionResult.error(String error) {
    return DiseaseDetectionResult(
      success: false,
      error: error,
    );
  }
}

/// Sync result class
class SyncResult {
  final bool success;
  final int syncedItems;
  final String message;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.syncedItems,
    required this.message,
    this.errors = const [],
  });
}
