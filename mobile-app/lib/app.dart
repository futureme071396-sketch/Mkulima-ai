// mobile-app/lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/views/home_screen.dart';
import 'src/utils/local_storage.dart';
import 'src/utils/constants.dart';

/// Main app class that sets up the theme and routing
class MkulimaApp extends StatefulWidget {
  const MkulimaApp({Key? key}) : super(key: key);

  @override
  State<MkulimaApp> createState() => _MkulimaAppState();
}

class _MkulimaAppState extends State<MkulimaApp> {
  // App state management
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize local storage
    await LocalStorage.init();
    
    // Check if first launch
    final isFirstLaunch = await LocalStorage.isFirstLaunch();
    if (isFirstLaunch) {
      await _setupFirstLaunch();
    }
    
    // Load user preferences
    await _appState.loadUserPreferences();
    
    // Notify listeners that app is ready
    _appState.setAppInitialized(true);
  }

  Future<void> _setupFirstLaunch() async {
    // Set default user
    final defaultUser = User(
      id: '1',
      name: 'Farmer',
      email: '',
      phone: '',
      preferredLanguage: 'sw',
      region: 'Nairobi',
      farmSize: 0.0,
      mainCrops: ['maize'],
      joinedAt: DateTime.now(),
      isPremium: false,
      totalScans: 0,
      successfulDetections: 0,
    );
    
    await LocalStorage.saveUser(defaultUser);
    await LocalStorage.setFirstLaunchCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appState,
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: _buildAppTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: appState.themeMode,
            debugShowCheckedModeBanner: false,
            home: _buildHomeScreen(appState),
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen(AppState appState) {
    if (!appState.isAppInitialized) {
      return const SplashScreen();
    }
    return const HomeScreen();
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: Color(AppConstants.appColors['primary']!),
        primaryContainer: Color(AppConstants.appColors['primaryDark']!),
        secondary: Color(AppConstants.appColors['accent']!),
        background: Color(AppConstants.appColors['background']!),
        surface: Color(AppConstants.appColors['surface']!),
        error: Color(AppConstants.appColors['error']!),
        onPrimary: Color(AppConstants.appColors['onPrimary']!),
        onBackground: Color(AppConstants.appColors['onBackground']!),
        onSurface: Color(AppConstants.appColors['onSurface']!),
      ),
      
      // Typography
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      
      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: Color(AppConstants.appColors['primary']!),
        foregroundColor: Color(AppConstants.appColors['onPrimary']!),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(AppConstants.appColors['primary']!),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(0),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Color(AppConstants.appColors['primary']!),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppConstants.appColors['primary']!),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(AppConstants.appColors['primary']!),
          side: BorderSide(
            color: Color(AppConstants.appColors['primary']!),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Layout
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData _buildDarkTheme() {
    final lightTheme = _buildAppTheme();
    return lightTheme.copyWith(
      colorScheme: ColorScheme.dark(
        primary: Color(AppConstants.appColors['primaryLight']!),
        primaryContainer: Color(AppConstants.appColors['primary']!),
        secondary: Color(AppConstants.appColors['accent']!),
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        error: Color(AppConstants.appColors['error']!),
        onPrimary: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
    );
  }
}

/// App state management
class AppState with ChangeNotifier {
  bool _isAppInitialized = false;
  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'sw';
  User? _currentUser;

  // Getters
  bool get isAppInitialized => _isAppInitialized;
  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  User? get currentUser => _currentUser;

  // Setters
  void setAppInitialized(bool initialized) {
    _isAppInitialized = initialized;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    LocalStorage.saveSetting('theme_mode', mode.index);
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    _language = languageCode;
    LocalStorage.setPreferredLanguage(languageCode);
    if (_currentUser != null) {
      LocalStorage.updateUserField('preferredLanguage', languageCode);
    }
    notifyListeners();
  }

  void setUser(User user) {
    _currentUser = user;
    _language = user.preferredLanguage;
    notifyListeners();
  }

  // Load user preferences
  Future<void> loadUserPreferences() async {
    // Load theme mode
    final themeIndex = await LocalStorage.getSetting('theme_mode', defaultValue: 0);
    _themeMode = ThemeMode.values[themeIndex as int? ?? 0];
    
    // Load language
    _language = await LocalStorage.getPreferredLanguage();
    
    // Load user data
    _currentUser = await LocalStorage.getUser();
    
    notifyListeners();
  }

  // Update user statistics
  Future<void> updateUserStats({int? totalScans, int? successfulDetections}) async {
    if (_currentUser == null) return;
    
    final updatedUser = User(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      phone: _currentUser!.phone,
      preferredLanguage: _currentUser!.preferredLanguage,
      region: _currentUser!.region,
      farmSize: _currentUser!.farmSize,
      mainCrops: _currentUser!.mainCrops,
      joinedAt: _currentUser!.joinedAt,
      isPremium: _currentUser!.isPremium,
      totalScans: totalScans ?? _currentUser!.totalScans,
      successfulDetections: successfulDetections ?? _currentUser!.successfulDetections,
    );
    
    await LocalStorage.saveUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }
}

/// Splash Screen shown during app initialization
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.appColors['primary']!),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.agriculture,
                size: 60,
                color: Color(AppConstants.appColors['primary']!),
              ),
            ),
            const SizedBox(height: 32),
            
            // App Name
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Plant Disease Detection',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            
            // Loading Text
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Import models (add this at the top of the file)
import 'src/models/user_model.dart';
