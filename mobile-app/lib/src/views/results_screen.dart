// mobile-app/lib/src/views/results_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/disease_model.dart';
import '../services/tts_service.dart';
import '../services/offline_service.dart';

class ResultsScreen extends StatefulWidget {
  final DiseaseDetection detection;
  final File imageFile;

  const ResultsScreen({
    Key? key,
    required this.detection,
    required this.imageFile,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final TtsService _ttsService = TtsService();
  final OfflineService _offlineService = OfflineService();
  bool _isSpeaking = false;
  String _selectedLanguage = 'sw';

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final user = await _offlineService.getUser();
    setState(() {
      _selectedLanguage = user?.preferredLanguage ?? 'sw';
    });
  }

  void _speakResults() {
    setState(() => _isSpeaking = true);
    _ttsService.speakDetectionResult(widget.detection, _selectedLanguage)
      .then((_) => setState(() => _isSpeaking = false));
  }

  void _stopSpeaking() {
    _ttsService.stopSpeaking();
    setState(() => _isSpeaking = false);
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return Icons.warning;
      case 'medium': return Icons.info;
      case 'low': return Icons.check_circle;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isSpeaking 
                ? const Icon(Icons.stop)
                : const Icon(Icons.volume_up),
            onPressed: _isSpeaking ? _stopSpeaking : _speakResults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            _buildImagePreview(),
            const SizedBox(height: 20),
            
            // Detection Results
            _buildDetectionCard(),
            const SizedBox(height: 20),
            
            // Treatments
            _buildTreatmentsSection(),
            const SizedBox(height: 20),
            
            // Prevention
            _buildPreventionSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              image: DecorationImage(
                image: FileImage(widget.imageFile),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  _getSeverityIcon(widget.detection.severity),
                  color: _getSeverityColor(widget.detection.severity),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.detection.plantType.toUpperCase()} • ${widget.detection.severity} Severity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionCard() {
    return Card(
      color: _getSeverityColor(widget.detection.severity).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSeverityIcon(widget.detection.severity),
                  color: _getSeverityColor(widget.detection.severity),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.detection.diseaseName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Confidence: ${widget.detection.confidencePercentage}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(
                widget.detection.severity.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: _getSeverityColor(widget.detection.severity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💊 Recommended Treatments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.detection.treatments.map((treatment) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(treatment)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreventionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🛡️ Prevention Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.detection.preventions.map((prevention) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(prevention)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Scan Again'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSpeaking ? _stopSpeaking : _speakResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                    const SizedBox(width: 8),
                    Text(_isSpeaking ? 'Stop' : 'Hear Advice'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
