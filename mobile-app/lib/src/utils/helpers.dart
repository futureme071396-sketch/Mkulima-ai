// mobile-app/lib/src/utils/helpers.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

/// Utility functions for the app
class AppHelpers {
  /// Format date to relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
  
  /// Format date to full string
  static String formatDateFull(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }
  
  /// Format time only
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  /// Get color from hex code
  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  
  /// Get severity color
  static Color getSeverityColor(String severity) {
    final severityInfo = AppConstants.severityLevels[severity.toLowerCase()];
    if (severityInfo != null) {
      return Color(severityInfo['color'] as int);
    }
    return Colors.grey;
  }
  
  /// Get severity icon
  static IconData getSeverityIcon(String severity) {
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
  
  /// Get plant emoji by type
  static String getPlantEmoji(String plantType) {
    final plant = AppConstants.supportedPlants.firstWhere(
      (p) => p['value'] == plantType.toLowerCase(),
      orElse: () => {'emoji': '🌱'},
    );
    return plant['emoji']!;
  }
  
  /// Get plant display name
  static String getPlantDisplayName(String plantType) {
    final plant = AppConstants.supportedPlants.firstWhere(
      (p) => p['value'] == plantType.toLowerCase(),
      orElse: () => {'label': plantType, 'localName': plantType},
    );
    return '${plant['emoji']} ${plant['label']} (${plant['localName']})';
  }
  
  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }
  
  /// Validate phone number (Kenyan format)
  static bool isValidKenyanPhone(String phone) {
    final phoneRegex = RegExp(
      r'^(?:\+254|0)[17]\d{8}$',
    );
    return phoneRegex.hasMatch(phone.replaceAll(' ', ''));
  }
  
  /// Format Kenyan phone number
  static String formatKenyanPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleaned.startsWith('0')) {
      return '+254${cleaned.substring(1)}';
    } else if (cleaned.startsWith('254')) {
      return '+$cleaned';
    } else if (!cleaned.startsWith('+')) {
      return '+254$cleaned';
    }
    
    return cleaned;
  }
  
  /// Calculate confidence percentage with formatting
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }
  
  /// Get file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
  
  /// Validate image file
  static String? validateImageFile(File file) {
    final size = file.lengthSync();
    
    if (size > AppConstants.maxImageSize) {
      return 'Image too large. Maximum size is ${AppHelpers.formatFileSize(AppConstants.maxImageSize)}';
    }
    
    // Check file extension
    final path = file.path.toLowerCase();
    if (!path.endsWith('.jpg') && 
        !path.endsWith('.jpeg') && 
        !path.endsWith('.png')) {
      return 'Please select a JPG or PNG image';
    }
    
    return null;
  }
  
  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Get random color (for placeholders)
  static Color getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }
  
  /// Show snackbar with consistent styling
  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600;
  }
  
  /// Get responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1200 && desktop != null) {
      return desktop;
    } else if (width >= 600 && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

/// Extension methods for common types
extension StringExtensions on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
  
  String get toTitleCase {
    return split(' ').map((word) => word.capitalizeFirst).join(' ');
  }
  
  bool get isNullOrEmpty => isEmpty;
  
  String? get nullIfEmpty => isEmpty ? null : this;
}

extension DateTimeExtensions on DateTime {
  String get toRelativeTime => AppHelpers.formatRelativeTime(this);
  String get toFullDate => AppHelpers.formatDateFull(this);
  String get toTimeOnly => AppHelpers.formatTime(this);
  
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }
}

extension DoubleExtensions on double {
  String get toPercentage => AppHelpers.formatConfidence(this);
  String get toRoundedString => toStringAsFixed(1);
}

extension IntExtensions on int {
  String get toFileSize => AppHelpers.formatFileSize(this);
}
