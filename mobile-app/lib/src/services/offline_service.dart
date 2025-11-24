// mobile-app/lib/src/services/offline_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/disease_model.dart';
import '../models/user_model.dart';
import '../models/plant_model.dart';

class OfflineService {
  static const String _detectionsKey = 'disease_detections';
  static const String _userKey = 'current_user';
  static const String _pendingSyncKey = 'pending_sync_detections';
  
  /// Save disease detection locally
  Future<void> saveDetection(DiseaseDetection detection) async {
    final prefs = await SharedPreferences.getInstance();
    final detections = await getDetectionHistory();
    
    // Add new detection
    detections.insert(0, detection);
    
    // Save updated list (limit to 100 most recent)
    final limitedDetections = detections.take(100).toList();
    final jsonList = limitedDetections.map((d) => d.toJson()).toList();
    
    await prefs.setString(_detectionsKey, json.encode(jsonList));
    
    // Mark for sync if needed
    await _addToPendingSync(detection);
  }
  
  /// Get detection history from local storage
  Future<List<DiseaseDetection>> getDetectionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_detectionsKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((item) => DiseaseDetection.fromJson(item)).toList();
    } catch (e) {
      print('Error parsing detection history: $e');
      return [];
    }
  }
  
  /// Save user data locally
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
  
  /// Get user data from local storage
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    
    if (jsonString == null) return null;
    
    try {
      final userJson = json.decode(jsonString);
      return User.fromJson(userJson);
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }
  
  /// Get detections pending sync
  Future<List<DiseaseDetection>> getPendingSyncDetections() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pendingSyncKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((item) => DiseaseDetection.fromJson(item)).toList();
    } catch (e) {
      print('Error parsing pending sync detections: $e');
      return [];
    }
  }
  
  /// Add detection to pending sync list
  Future<void> _addToPendingSync(DiseaseDetection detection) async {
    final pending = await getPendingSyncDetections();
    pending.add(detection);
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = pending.map((d) => d.toJson()).toList();
    await prefs.setString(_pendingSyncKey, json.encode(jsonList));
  }
  
  /// Mark detection as synced
  Future<void> markAsSynced(String detectionId) async {
    final pending = await getPendingSyncDetections();
    final updated = pending.where((d) => d.id != detectionId).toList();
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = updated.map((d) => d.toJson()).toList();
    await prefs.setString(_pendingSyncKey, json.encode(jsonList));
  }
  
  /// Clear all local data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_detectionsKey);
    await prefs.remove(_pendingSyncKey);
    // Note: We don't clear user data as user might want to stay logged in
  }
  
  /// Get storage usage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    final detections = await getDetectionHistory();
    final pendingSync = await getPendingSyncDetections();
    
    // Estimate storage size (rough calculation)
    final detectionsJson = json.encode(detections.map((d) => d.toJson()).toList());
    final storageSize = detectionsJson.length / (1024 * 1024); // MB
    
    return {
      'totalDetections': detections.length,
      'pendingSync': pendingSync.length,
      'storageUsedMB': storageSize.toStringAsFixed(2),
      'lastDetection': detections.isNotEmpty ? detections.first.detectedAt : null,
    };
  }
}
