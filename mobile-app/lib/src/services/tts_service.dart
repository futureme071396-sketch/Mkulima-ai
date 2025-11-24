// mobile-app/lib/src/services/tts_service.dart
import 'package:flutter_tts/flutter_tts.dart';
import '../models/disease_model.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  
  /// Initialize TTS engine
  Future<void> initialize() async {
    try {
      // Set common TTS settings
      await _flutterTts.setSpeechRate(0.5); // Slower for better understanding
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }
  
  /// Speak disease detection results in selected language
  Future<void> speakDetectionResult(
    DiseaseDetection detection, 
    String language
  ) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final message = _buildDetectionMessage(detection, language);
    
    try {
      // Set language based on selection
      await _setLanguage(language);
      await _flutterTts.speak(message);
    } catch (e) {
      print('Error speaking message: $e');
    }
  }
  
  /// Build localized message for TTS
  String _buildDetectionMessage(DiseaseDetection detection, String language) {
    switch (language) {
      case 'sw': // Kiswahili
        return '''
Umegundua ugonjwa: ${detection.diseaseName}.
Uwezo wa kuaminika: ${(detection.confidence * 100).toStringAsFixed(0)} asilimia.
Ukali: ${_getSeverityInSwahili(detection.severity)}.
Tafadhali tumia matibabu yafuatayo...
${detection.treatments.take(2).join('. ')}
''';
        
      case 'kik': // Gikuyu
        return '''
Nīūmenye ūremi: ${detection.diseaseName}.
Ūhoteri: ${(detection.confidence * 100).toStringAsFixed(0)} asilimia.
Ūremi mūnene: ${_getSeverityInKikuyu(detection.severity)}.
Thikira ūū ūgīria wīra...
${detection.treatments.take(2).join('. ')}
''';
        
      case 'luo': // Dholuo
        return '''
Inyalo ng'ado: ${detection.diseaseName}.
Kit mar her: ${(detection.confidence * 100).toStringAsFixed(0)} asilimia.
Yore maber: ${_getSeverityInLuo(detection.severity)}.
Tiyo gi gima machielo...
${detection.treatments.take(2).join('. ')}
''';
        
      default: // English
        return '''
Detected disease: ${detection.diseaseName}.
Confidence: ${(detection.confidence * 100).toStringAsFixed(0)} percent.
Severity: ${detection.severity}.
Please use the following treatments...
${detection.treatments.take(2).join('. ')}
''';
    }
  }
  
  /// Set TTS language
  Future<void> _setLanguage(String language) async {
    final languageMap = {
      'en': 'en-US',
      'sw': 'sw-KE',
      'kik': 'en-US', // Fallback to English for unsupported languages
      'luo': 'en-US', // Fallback to English for unsupported languages
    };
    
    final ttsLanguage = languageMap[language] ?? 'en-US';
    await _flutterTts.setLanguage(ttsLanguage);
  }
  
  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }
  
  /// Check if TTS is speaking
  Future<bool> get isSpeaking async {
    return await _flutterTts.isSpeaking();
  }
  
  // Helper methods for localizing severity
  String _getSeverityInSwahili(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return 'Kubwa';
      case 'medium': return 'Wastani';
      case 'low': return 'Ndogo';
      default: return severity;
    }
  }
  
  String _getSeverityInKikuyu(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return 'Mūnene';
      case 'medium': return 'Wa gatagatī';
      case 'low': return 'Mūno';
      default: return severity;
    }
  }
  
  String _getSeverityInLuo(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return 'Moko madongo';
      case 'medium': return 'Magero';
      case 'low': return 'Matin';
      default: return severity;
    }
  }
}
