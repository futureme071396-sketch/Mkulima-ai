// mobile-app/lib/src/views/history_screen.dart
import 'package:flutter/material.dart';
import '../models/disease_model.dart';
import '../services/offline_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final OfflineService _offlineService = OfflineService();
  List<DiseaseDetection> _detections = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'high', 'medium', 'low'

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final detections = await _offlineService.getDetectionHistory();
    setState(() {
      _detections = detections;
      _isLoading = false;
    });
  }

  List<DiseaseDetection> get _filteredDetections {
    if (_filter == 'all') return _detections;
    return _detections.where((d) => d.severity.toLowerCase() == _filter).toList();
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),
          
          // History List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _detections.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'value': 'all', 'label': 'All'},
      {'value': 'high', 'label': 'High'},
      {'value': 'medium', 'label': 'Medium'},
      {'value': 'low', 'label': 'Low'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: filters.map((filter) {
          return FilterChip(
            label: Text(filter['label']!),
            selected: _filter == filter['value'],
            onSelected: (selected) {
              setState(() => _filter = filter['value']!);
            },
            backgroundColor: Colors.grey[200],
            selectedColor: Colors.green[100],
            checkmarkColor: Colors.green,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No scan history',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your plant scans will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDetections.length,
      itemBuilder: (context, index) {
        final detection = _filteredDetections[index];
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${detection.plantType} • ${detection.confidencePercentage}'),
                Text(
                  _formatDate(detection.detectedAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                detection.severity,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: _getSeverityColor(detection.severity),
            ),
            onTap: () {
              _showDetectionDetails(detection);
            },
          ),
        );
      },
    );
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return Icons.warning;
      case 'medium': return Icons.info;
      case 'low': return Icons.check_circle;
      default: return Icons.help;
    }
  }

  void _showDetectionDetails(DiseaseDetection detection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(detection.diseaseName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Plant: ${detection.plantType}'),
              Text('Confidence: ${detection.confidencePercentage}'),
              Text('Severity: ${detection.severity}'),
              Text('Date: ${_formatDate(detection.detectedAt)}'),
              const SizedBox(height: 16),
              if (detection.location != null)
                Text('Location: ${detection.location}'),
              const SizedBox(height: 16),
              const Text(
                'Treatments:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...detection.treatments.take(3).map((treatment) => 
                Text('• $treatment')
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
