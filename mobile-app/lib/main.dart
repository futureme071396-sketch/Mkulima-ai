// mobile-app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  // Error handling setup
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // In production, you might want to send this to a logging service
    debugPrint('Flutter Error: ${details.exception}');
  };
  
  // Run the app
  runApp(const MkulimaApp());
}

/// Development main function with additional debugging
void developmentMain() {
  // Enable more verbose logging in development
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null && message.isNotEmpty) {
      // ignore: avoid_print
      print('🌱 Mkulima AI: $message');
    }
  };
  
  // Run the main app
  main();
}

/// Production main function with error reporting
void productionMain() {
  // Set up error reporting service (e.g., Sentry, Firebase Crashlytics)
  _setupErrorReporting();
  
  // Run the main app
  main();
}

void _setupErrorReporting() {
  // Initialize your error reporting service here
  // Example: Sentry.init(...);
  debugPrint('Error reporting service initialized');
}

/// Test main function for integration tests
void testMain() {
  // Additional setup for testing environment
  main();
}
