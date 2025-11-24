// mobile-app/lib/src/views/camera_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/api_service.dart';
import '../models/disease_model.dart';
import 'results_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final ApiService _apiService = ApiService();
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isLoading = false;
  String _selectedPlant = 'maize';

  final List<Map<String, String>> plants = [
    {'value': 'maize', 'label': 'Maize (Mahindi)', 'emoji': '🌽'},
    {'value': 'coffee', 'label': 'Coffee (Kahawa)', 'emoji': '☕'},
    {'value': 'tea', 'label': 'Tea (Chai)', 'emoji': '🍃'},
    {'value': 'tomato', 'label': 'Tomato (Nyanya)', 'emoji': '🍅'},
    {'value': 'banana', 'label': 'Banana (Ndizi)', 'emoji': '🍌'},
    {'value': 'beans', 'label': 'Beans (Maharage)', 'emoji': '🫘'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final controller = await _cameraService.initializeCamera();
    if (controller != null) {
      setState(() {
        _controller = controller;
        _isCameraReady = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final File? imageFile = await _cameraService.takePicture();
      
      if (imageFile != null) {
        final validationError = _cameraService.validateImage(imageFile);
        if (validationError != null) {
          _showError(validationError);
          return;
        }

        // Send to AI API
        final DiseaseDetection detection = await _apiService.detectDisease(
          imageFile,
          _selectedPlant,
          'Kenya', // You can get actual location later
        );

        // Navigate to results
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              detection: detection,
              imageFile: imageFile,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to process image: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);

    try {
      final File? imageFile = await _cameraService.pickImageFromGallery();
      
      if (imageFile != null) {
        final validationError = _cameraService.validateImage(imageFile);
        if (validationError != null) {
          _showError(validationError);
          return;
        }

        final DiseaseDetection detection = await _apiService.detectDisease(
          imageFile,
          _selectedPlant,
          'Kenya',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              detection: detection,
              imageFile: imageFile,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Plant'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Plant Selection
          _buildPlantSelector(),
          
          // Camera Preview
          Expanded(
            child: _isCameraReady && _controller != null
                ? CameraPreview(_controller!)
                : _buildCameraPlaceholder(),
          ),
          
          // Controls
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildPlantSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Plant Type:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPlant,
            items: plants.map((plant) {
              return DropdownMenuItem(
                value: plant['value'],
                child: Text('${plant['emoji']} ${plant['label']}'),
              );
            }).toList(),
            onChanged: _isLoading ? null : (value) {
              setState(() => _selectedPlant = value!);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'Camera Loading...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery Button
          IconButton(
            icon: Icon(Icons.photo_library, 
                color: _isLoading ? Colors.grey : Colors.white),
            onPressed: _isLoading ? null : _pickFromGallery,
          ),
          
          // Capture Button
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : FloatingActionButton(
                  onPressed: _takePicture,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.camera_alt, color: Colors.black),
                ),
          
          // Placeholder for alignment
          const IconButton(
            icon: Icon(Icons.flash_on, color: Colors.transparent),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
