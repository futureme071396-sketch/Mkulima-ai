// mobile-app/lib/src/utils/constants.dart

/// App-wide constants and configuration
class AppConstants {
  // App Information
  static const String appName = 'Mkulima AI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-Powered Plant Disease Detection';
  
  // API Configuration
  static const String baseUrl = 'https://mkulima-api.railway.app';
  static const String apiVersion = '/api/v1';
  static const int apiTimeout = 30000; // 30 seconds
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // Supported Plants
  static const List<Map<String, String>> supportedPlants = [
    {
      'value': 'maize',
      'label': 'Maize',
      'localName': 'Mahindi',
      'emoji': '🌽',
      'scientificName': 'Zea mays'
    },
    {
      'value': 'coffee', 
      'label': 'Coffee',
      'localName': 'Kahawa',
      'emoji': '☕',
      'scientificName': 'Coffea arabica'
    },
    {
      'value': 'tea',
      'label': 'Tea', 
      'localName': 'Chai',
      'emoji': '🍃',
      'scientificName': 'Camellia sinensis'
    },
    {
      'value': 'tomato',
      'label': 'Tomato',
      'localName': 'Nyanya', 
      'emoji': '🍅',
      'scientificName': 'Solanum lycopersicum'
    },
    {
      'value': 'banana',
      'label': 'Banana',
      'localName': 'Ndizi',
      'emoji': '🍌',
      'scientificName': 'Musa spp.'
    },
    {
      'value': 'beans',
      'label': 'Beans',
      'localName': 'Maharage',
      'emoji': '🫘', 
      'scientificName': 'Phaseolus vulgaris'
    },
    {
      'value': 'potato',
      'label': 'Potato',
      'localName': 'Viazi',
      'emoji': '🥔',
      'scientificName': 'Solanum tuberosum'
    },
    {
      'value': 'cassava',
      'label': 'Cassava',
      'localName': 'Muhogo',
      'emoji': '🌿',
      'scientificName': 'Manihot esculenta'
    },
  ];
  
  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {
      'code': 'sw',
      'name': 'Swahili',
      'nativeName': 'Kiswahili',
      'flag': '🇹🇿'
    },
    {
      'code': 'en',
      'name': 'English', 
      'nativeName': 'English',
      'flag': '🇺🇸'
    },
    {
      'code': 'kik',
      'name': 'Kikuyu',
      'nativeName': 'Gikuyu',
      'flag': '🇰🇪'
    },
    {
      'code': 'luo',
      'name': 'Luo',
      'nativeName': 'Dholuo',
      'flag': '🇰🇪'
    },
  ];
  
  // Disease Severity Levels
  static const Map<String, Map<String, dynamic>> severityLevels = {
    'high': {
      'label': 'High',
      'color': 0xFFFF4444, // Red
      'icon': 'warning',
      'description': 'Immediate action required'
    },
    'medium': {
      'label': 'Medium', 
      'color': 0xFFFFAA00, // Orange
      'icon': 'info',
      'description': 'Monitor closely and treat'
    },
    'low': {
      'label': 'Low',
      'color': 0xFF00C851, // Green
      'icon': 'check_circle',
      'description': 'Minor issue, preventive care'
    },
  };
  
  // App Colors
  static const Map<String, int> appColors = {
    'primary': 0xFF2E7D32,      // Green
    'primaryDark': 0xFF1B5E20,  // Dark Green
    'primaryLight': 0xFF4CAF50, // Light Green
    'accent': 0xFFFF9800,       // Orange
    'background': 0xFFFAFAFA,   // Light Gray
    'surface': 0xFFFFFFFF,      // White
    'error': 0xFFB00020,        // Red
    'onPrimary': 0xFFFFFFFF,    // White
    'onBackground': 0xFF000000, // Black
    'onSurface': 0xFF000000,    // Black
  };
  
  // Text Styles
  static const Map<String, double> textSizes = {
    'displayLarge': 32.0,
    'displayMedium': 28.0,
    'displaySmall': 24.0,
    'headlineMedium': 20.0,
    'headlineSmall': 18.0,
    'titleLarge': 16.0,
    'titleMedium': 14.0,
    'titleSmall': 12.0,
    'bodyLarge': 16.0,
    'bodyMedium': 14.0,
    'bodySmall': 12.0,
    'labelLarge': 14.0,
    'labelMedium': 12.0,
    'labelSmall': 10.0,
  };
  
  // Spacing
  static const Map<String, double> spacing = {
    'xs': 4.0,
    's': 8.0,
    'm': 16.0,
    'l': 24.0,
    'xl': 32.0,
    'xxl': 48.0,
  };
  
  // Animation Durations
  static const Map<String, Duration> animationDurations = {
    'short': Duration(milliseconds: 200),
    'medium': Duration(milliseconds: 300),
    'long': Duration(milliseconds: 500),
  };
  
  // Storage Keys
  static const Map<String, String> storageKeys = {
    'user': 'mkulima_user',
    'detections': 'mkulima_detections',
    'pendingSync': 'mkulima_pending_sync',
    'settings': 'mkulima_settings',
    'firstLaunch': 'mkulima_first_launch',
    'language': 'mkulima_language',
  };
}

/// API Endpoints
class ApiEndpoints {
  static const String base = AppConstants.baseUrl + AppConstants.apiVersion;
  static const String predict = '$base/predict';
  static const String history = '$base/detections';
  static const String users = '$base/users';
  static const String plants = '$base/plants';
  static const String diseases = '$base/diseases';
  static const String sync = '$base/sync';
}

/// Error Messages
class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String imageTooLarge = 'Image too large. Please select image smaller than 5MB.';
  static const String cameraError = 'Camera error. Please check permissions.';
  static const String detectionFailed = 'Detection failed. Please try again.';
  static const String noInternet = 'No internet connection. Working offline.';
  static const String unknownError = 'An unknown error occurred.';
  
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'NETWORK_ERROR':
        return networkError;
      case 'SERVER_ERROR':
        return serverError;
      case 'IMAGE_TOO_LARGE':
        return imageTooLarge;
      case 'CAMERA_ERROR':
        return cameraError;
      case 'DETECTION_FAILED':
        return detectionFailed;
      case 'NO_INTERNET':
        return noInternet;
      default:
        return unknownError;
    }
  }
}

/// Success Messages
class SuccessMessages {
  static const String detectionSuccess = 'Disease detected successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String historyCleared = 'History cleared successfully!';
  static const String settingsSaved = 'Settings saved successfully!';
  static const String syncCompleted = 'Data synced successfully!';
}
