// mobile-app/lib/src/utils/local_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/disease_model.dart';
import '../models/user_model.dart';
import 'constants.dart';

/// Enhanced local storage service with type safety and error handling
class LocalStorage {
  static SharedPreferences? _prefs;
  
  /// Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Ensure preferences are initialized
  static Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
  
  // ============ USER DATA ============ //
  
  /// Save user data
  static Future<bool> saveUser(User user) async {
    await _ensureInitialized();
    try {
      return await _prefs!.setString(
        AppConstants.storageKeys['user']!,
        json.encode(user.toJson()),
      );
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }
  
  /// Get user data
  static Future<User?> getUser() async {
    await _ensureInitialized();
    try {
      final userJson = _prefs!.getString(AppConstants.storageKeys['user']!);
      if (userJson == null) return null;
      
      final userData = json.decode(userJson);
      return User.fromJson(userData);
    } catch (e) {
      print('Error loading user: $e');
      return null;
    }
  }
  
  /// Update user field
  static Future<bool> updateUserField(String field, dynamic value) async {
    final user = await getUser();
    if (user == null) return false;
    
    final updatedUser = User(
      id: user.id,
      name: field == 'name' ? value as String : user.name,
      email: field == 'email' ? value as String : user.email,
      phone: field == 'phone' ? value as String : user.phone,
      preferredLanguage: field == 'preferredLanguage' ? value as String : user.preferredLanguage,
      region: field == 'region' ? value as String : user.region,
      farmSize: field == 'farmSize' ? value as double : user.farmSize,
      mainCrops: field == 'mainCrops' ? value as List<String> : user.mainCrops,
      joinedAt: user.joinedAt,
      isPremium: field == 'isPremium' ? value as bool : user.isPremium,
      totalScans: field == 'totalScans' ? value as int : user.totalScans,
      successfulDetections: field == 'successfulDetections' ? value as int : user.successfulDetections,
    );
    
    return await saveUser(updatedUser);
  }
  
  // ============ DETECTION DATA ============ //
  
  /// Save disease detection
  static Future<bool> saveDetection(DiseaseDetection detection) async {
    await _ensureInitialized();
    try {
      final detections = await getDetections();
      detections.insert(0, detection);
      
      // Keep only last 100 detections to prevent storage bloat
      final limitedDetections = detections.take(100).toList();
      final jsonList = limitedDetections.map((d) => d.toJson()).toList();
      
      return await _prefs!.setString(
        AppConstants.storageKeys['detections']!,
        json.encode(jsonList),
      );
    } catch (e) {
      print('Error saving detection: $e');
      return false;
    }
  }
  
  /// Get all disease detections
  static Future<List<DiseaseDetection>> getDetections() async {
    await _ensureInitialized();
    try {
      final detectionsJson = _prefs!.getString(AppConstants.storageKeys['detections']!);
      if (detectionsJson == null) return [];
      
      final jsonList = json.decode(detectionsJson) as List;
      return jsonList.map((item) => DiseaseDetection.fromJson(item)).toList();
    } catch (e) {
      print('Error loading detections: $e');
      return [];
    }
  }
  
  /// Get detections by plant type
  static Future<List<DiseaseDetection>> getDetectionsByPlant(String plantType) async {
    final detections = await getDetections();
    return detections.where((d) => d.plantType.toLowerCase() == plantType.toLowerCase()).toList();
  }
  
  /// Get detections by severity
  static Future<List<DiseaseDetection>> getDetectionsBySeverity(String severity) async {
    final detections = await getDetections();
    return detections.where((d) => d.severity.toLowerCase() == severity.toLowerCase()).toList();
  }
  
  /// Delete a specific detection
  static Future<bool> deleteDetection(String detectionId) async {
    final detections = await getDetections();
    final updatedDetections = detections.where((d) => d.id != detectionId).toList();
    
    return await _prefs!.setString(
      AppConstants.storageKeys['detections']!,
      json.encode(updatedDetections.map((d) => d.toJson()).toList()),
    );
  }
  
  // ============ PENDING SYNC ============ //
  
  /// Add detection to pending sync
  static Future<bool> addToPendingSync(DiseaseDetection detection) async {
    await _ensureInitialized();
    try {
      final pending = await getPendingSync();
      pending.add(detection);
      
      final jsonList = pending.map((d) => d.toJson()).toList();
      return await _prefs!.setString(
        AppConstants.storageKeys['pendingSync']!,
        json.encode(jsonList),
      );
    } catch (e) {
      print('Error adding to pending sync: $e');
      return false;
    }
  }
  
  /// Get pending sync detections
  static Future<List<DiseaseDetection>> getPendingSync() async {
    await _ensureInitialized();
    try {
      final pendingJson = _prefs!.getString(AppConstants.storageKeys['pendingSync']!);
      if (pendingJson == null) return [];
      
      final jsonList = json.decode(pendingJson) as List;
      return jsonList.map((item) => DiseaseDetection.fromJson(item)).toList();
    } catch (e) {
      print('Error loading pending sync: $e');
      return [];
    }
  }
  
  /// Remove detection from pending sync (after successful sync)
  static Future<bool> removeFromPendingSync(String detectionId) async {
    final pending = await getPendingSync();
    final updatedPending = pending.where((d) => d.id != detectionId).toList();
    
    return await _prefs!.setString(
      AppConstants.storageKeys['pendingSync']!,
      json.encode(updatedPending.map((d) => d.toJson()).toList()),
    );
  }
  
  // ============ APP SETTINGS ============ //
  
  /// Save app setting
  static Future<bool> saveSetting(String key, dynamic value) async {
    await _ensureInitialized();
    try {
      final settings = await getSettings();
      settings[key] = value;
      
      return await _prefs!.setString(
        AppConstants.storageKeys['settings']!,
        json.encode(settings),
      );
    } catch (e) {
      print('Error saving setting: $e');
      return false;
    }
  }
  
  /// Get app settings
  static Future<Map<String, dynamic>> getSettings() async {
    await _ensureInitialized();
    try {
      final settingsJson = _prefs!.getString(AppConstants.storageKeys['settings']!);
      if (settingsJson == null) return {};
      
      final settings = json.decode(settingsJson);
      return Map<String, dynamic>.from(settings);
    } catch (e) {
      print('Error loading settings: $e');
      return {};
    }
  }
  
  /// Get specific setting
  static Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    final settings = await getSettings();
    return settings[key] ?? defaultValue;
  }
  
  // ============ APP STATE ============ //
  
  /// Check if first launch
  static Future<bool> isFirstLaunch() async {
    await _ensureInitialized();
    return _prefs!.getBool(AppConstants.storageKeys['firstLaunch']!) ?? true;
  }
  
  /// Mark first launch as completed
  static Future<bool> setFirstLaunchCompleted() async {
    await _ensureInitialized();
    return await _prefs!.setBool(AppConstants.storageKeys['firstLaunch']!, false);
  }
  
  /// Get preferred language
  static Future<String> getPreferredLanguage() async {
    await _ensureInitialized();
    return _prefs!.getString(AppConstants.storageKeys['language']!) ?? 'sw';
  }
  
  /// Set preferred language
  static Future<bool> setPreferredLanguage(String languageCode) async {
    await _ensureInitialized();
    return await _prefs!.setString(AppConstants.storageKeys['language']!, languageCode);
  }
  
  // ============ STATISTICS ============ //
  
  /// Get detection statistics
  static Future<Map<String, dynamic>> getDetectionStats() async {
    final detections = await getDetections();
    
    if (detections.isEmpty) {
      return {
        'total': 0,
        'highSeverity': 0,
        'mediumSeverity': 0,
        'lowSeverity': 0,
        'mostCommonDisease': 'None',
        'mostCommonPlant': 'None',
        'successRate': 0.0,
      };
    }
    
    // Count by severity
    final severityCount = <String, int>{};
    final diseaseCount = <String, int>{};
    final plantCount = <String, int>{};
    
    for (final detection in detections) {
      severityCount[detection.severity] = (severityCount[detection.severity] ?? 0) + 1;
      diseaseCount[detection.diseaseName] = (diseaseCount[detection.diseaseName] ?? 0) + 1;
      plantCount[detection.plantType] = (plantCount[detection.plantType] ?? 0) + 1;
    }
    
    // Find most common
    final mostCommonDisease = diseaseCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final mostCommonPlant = plantCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    // Calculate success rate (detections with confidence > 0.7)
    final successfulDetections = detections.where((d) => d.confidence > 0.7).length;
    final successRate = successfulDetections / detections.length;
    
    return {
      'total': detections.length,
      'highSeverity': severityCount['high'] ?? 0,
      'mediumSeverity': severityCount['medium'] ?? 0,
      'lowSeverity': severityCount['low'] ?? 0,
      'mostCommonDisease': mostCommonDisease,
      'mostCommonPlant': mostCommonPlant,
      'successRate': successRate,
      'lastDetection': detections.isNotEmpty ? detections.first.detectedAt : null,
    };
  }
  
  // ============ CLEANUP ============ //
  
  /// Clear all app data
  static Future<void> clearAllData() async {
    await _ensureInitialized();
    await _prefs!.remove(AppConstants.storageKeys['detections']!);
    await _prefs!.remove(AppConstants.storageKeys['pendingSync']!);
    await _prefs!.remove(AppConstants.storageKeys['settings']!);
    // Note: We don't clear user data and first launch flag
  }
  
  /// Clear only detection data
  static Future<void> clearDetectionData() async {
    await _ensureInitialized();
    await _prefs!.remove(AppConstants.storageKeys['detections']!);
    await _prefs!.remove(AppConstants.storageKeys['pendingSync']!);
  }
  
  /// Get storage usage information
  static Future<Map<String, dynamic>> getStorageInfo() async {
    await _ensureInitialized();
    
    int totalSize = 0;
    
    for (final key in AppConstants.storageKeys.values) {
      final value = _prefs!.getString(key);
      if (value != null) {
        totalSize += value.length;
      }
    }
    
    return {
      'totalSizeBytes': totalSize,
      'totalSizeFormatted': AppHelpers.formatFileSize(totalSize),
      'detectionCount': (await getDetections()).length,
      'pendingSyncCount': (await getPendingSync()).length,
    };
  }
}
