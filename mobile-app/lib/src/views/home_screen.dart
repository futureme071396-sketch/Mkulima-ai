// mobile-app/lib/src/views/home_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/disease_model.dart';
import '../services/tts_service.dart';
import '../services/offline_service.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TtsService _ttsService = TtsService();
  final OfflineService _offlineService = OfflineService();
  User? _currentUser;
  List<DiseaseDetection> _recentDetections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _ttsService.initialize();
  }

  Future<void> _loadData() async {
    final user = await _offlineService.getUser();
    final detections = await _offlineService.getDetectionHistory();
    
    setState(() {
      _currentUser = user;
      _recentDetections = detections.take(3).toList(); // Last 3 detections
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mkulima AI 🌱'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildHomeContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraScreen()),
        ),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Plant'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          
          // Quick Stats
          _buildStatsSection(),
          const SizedBox(height: 24),
          
          // Recent Scans
          _buildRecentScansSection(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habari, ${_currentUser?.name ?? 'Farmer'}! 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan your plants for diseases and get instant treatment advice in your language.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip('Maize', Icons.grass),
                _buildChip('Coffee', Icons.local_cafe),
                _buildChip('Tomato', Icons.eco),
                _buildChip('Banana', Icons.forest),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      backgroundColor: Colors.green[50],
    );
  }

  Widget _buildStatsSection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Scans',
          _currentUser?.totalScans.toString() ?? '0',
          Icons.photo_camera,
          Colors.blue,
        ),
        _buildStatCard(
          'Success Rate',
          _currentUser?.successRatePercentage ?? '0%',
          Icons.verified,
          Colors.green,
        ),
        _buildStatCard(
          'Farm Size',
          '${_currentUser?.farmSize ?? 0} acres',
          Icons.agriculture,
          Colors.orange,
        ),
        _buildStatCard(
          'Language',
          _currentUser?.languageDisplayName ?? 'Swahili',
          Icons.language,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScansSection() {
    if (_recentDetections.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.photo_library, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'No scans yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the scan button to check your plants',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Scans',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._recentDetections.map((detection) => _buildDetectionCard(detection)),
      ],
    );
  }

  Widget _buildDetectionCard(DiseaseDetection detection) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getSeverityColor(detection.severity).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getSeverityIcon(detection.severity),
            color: _getSeverityColor(detection.severity),
          ),
        ),
        title: Text(
          detection.diseaseName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${detection.plantType} • ${detection.confidencePercentage}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Chip(
          label: Text(
            detection.severity,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          backgroundColor: _getSeverityColor(detection.severity),
        ),
        onTap: () {
          // Navigate to results screen with this detection
          _showDetectionDetails(detection);
        },
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
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

  void _showDetectionDetails(DiseaseDetection detection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(detection.diseaseName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plant: ${detection.plantType}'),
            Text('Confidence: ${detection.confidencePercentage}'),
            Text('Severity: ${detection.severity}'),
            const SizedBox(height: 16),
            const Text(
              'Recommended Treatments:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...detection.treatments.take(2).map((treatment) => 
              Text('• $treatment')
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              _ttsService.speakDetectionResult(
                detection, 
                _currentUser?.preferredLanguage ?? 'sw'
              );
              Navigator.pop(context);
            },
            child: const Text('Hear Advice'),
          ),
        ],
      ),
    );
  }
}
