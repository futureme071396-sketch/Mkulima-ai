// mobile-app/lib/src/services/camera_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _availableCameras;
  bool _isInitialized = false;

  // Camera configuration
  static const ResolutionPreset _resolutionPreset = ResolutionPreset.medium;
  static const bool _enableAudio = false;

  /// Initialize camera service and get available cameras
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _availableCameras = await availableCameras();
      _isInitialized = true;
    } catch (e) {
      throw CameraException(
        'Camera initialization failed',
        'Failed to get available cameras: $e',
      );
    }
  }

  /// Initialize camera controller with specific camera
  Future<CameraController?> initializeCamera({
    CameraLensDirection preferredLens = CameraLensDirection.back,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_availableCameras == null || _availableCameras!.isEmpty) {
      throw CameraException(
        'No camera available',
        'No cameras found on this device',
      );
    }

    // Find preferred camera
    CameraDescription? selectedCamera;
    for (final camera in _availableCameras!) {
      if (camera.lensDirection == preferredLens) {
        selectedCamera = camera;
        break;
      }
    }

    // Fallback to first available camera
    selectedCamera ??= _availableCameras!.first;

    try {
      _cameraController = CameraController(
        selectedCamera,
        _resolutionPreset,
        enableAudio: _enableAudio,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      return _cameraController;
    } catch (e) {
      _cameraController?.dispose();
      _cameraController = null;
      throw CameraException(
        'Camera controller initialization failed',
        'Failed to initialize camera: $e',
      );
    }
  }

  /// Take picture using current camera controller
  Future<CameraResult> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return CameraResult.error('Camera not initialized');
    }

    if (_cameraController!.value.isTakingPicture) {
      return CameraResult.error('Camera is already taking a picture');
    }

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final File file = File(imageFile.path);

      // Validate the captured image
      final validationError = AppHelpers.validateImageFile(file);
      if (validationError != null) {
        // Delete invalid image
        await file.delete();
        return CameraResult.error(validationError);
      }

      // Optimize image for analysis
      final optimizedFile = await _optimizeImageForAnalysis(file);
      
      return CameraResult.success(optimizedFile);
    } on CameraException catch (e) {
      return CameraResult.error('Camera error: ${e.description}');
    } catch (e) {
      return CameraResult.error('Failed to capture image: $e');
    }
  }

  /// Pick image from device gallery
  Future<CameraResult> pickImageFromGallery({
    int maxWidth = 1200,
    int maxHeight = 1200,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        requestFullMetadata: false,
      );

      if (imageFile == null) {
        return CameraResult.error('No image selected');
      }

      final File file = File(imageFile.path);
      
      // Validate the selected image
      final validationError = AppHelpers.validateImageFile(file);
      if (validationError != null) {
        return CameraResult.error(validationError);
      }

      // Optimize image for analysis
      final optimizedFile = await _optimizeImageForAnalysis(file);
      
      return CameraResult.success(optimizedFile);
    } catch (e) {
      return CameraResult.error('Failed to pick image: $e');
    }
  }

  /// Capture image from camera (convenience method that handles initialization)
  Future<CameraResult> captureImage({
    CameraLensDirection lensDirection = CameraLensDirection.back,
  }) async {
    try {
      await initializeCamera(preferredLens: lensDirection);
      return await takePicture();
    } catch (e) {
      return CameraResult.error('Failed to capture image: $e');
    }
  }

  /// Optimize image for disease analysis
  Future<File> _optimizeImageForAnalysis(File originalFile) async {
    try {
      // Read image bytes
      final Uint8List imageBytes = await originalFile.readAsBytes();
      
      // Decode image
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        return originalFile; // Return original if decoding fails
      }

      // Target dimensions for analysis
      const targetWidth = 800;
      const targetHeight = 800;

      // Calculate resize dimensions maintaining aspect ratio
      int newWidth, newHeight;
      if (originalImage.width > originalImage.height) {
        newWidth = targetWidth;
        newHeight = (originalImage.height * targetWidth / originalImage.width).round();
      } else {
        newHeight = targetHeight;
        newWidth = (originalImage.width * targetHeight / originalImage.height).round();
      }

      // Resize image
      final resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Convert to JPEG with quality compression
      final optimizedBytes = img.encodeJpg(resizedImage, quality: 80);

      // Create temporary file
      final tempDir = Directory.systemTemp;
      final optimizedFile = File(
        '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Write optimized image
      await optimizedFile.writeAsBytes(optimizedBytes);

      // Delete original file if it's a temporary camera file
      if (originalFile.path.contains('/tmp/') || 
          originalFile.path.contains('Camera/')) {
        await originalFile.delete();
      }

      return optimizedFile;
    } catch (e) {
      // Return original file if optimization fails
      return originalFile;
    }
  }

  /// Get image metadata
  Future<ImageMetadata> getImageMetadata(File imageFile) async {
    try {
      final stat = await imageFile.stat();
      final image = img.decodeImage(await imageFile.readAsBytes());
      
      return ImageMetadata(
        fileSize: stat.size,
        width: image?.width ?? 0,
        height: image?.height ?? 0,
        filePath: imageFile.path,
        lastModified: stat.modified,
        formattedSize: AppHelpers.formatFileSize(stat.size),
        aspectRatio: image != null ? image.width / image.height : 0,
      );
    } catch (e) {
      throw CameraException(
        'Metadata extraction failed',
        'Failed to get image metadata: $e',
      );
    }
  }

  /// Check camera availability
  Future<bool> get isCameraAvailable async {
    if (!_isInitialized) {
      await initialize();
    }
    return _availableCameras != null && _availableCameras!.isNotEmpty;
  }

  /// Get available camera descriptions
  List<CameraDescription>? get availableCameras => _availableCameras;

  /// Get current camera controller
  CameraController? get cameraController => _cameraController;

  /// Check if camera is ready
  bool get isCameraReady {
    return _cameraController != null && 
           _cameraController!.value.isInitialized &&
           !_cameraController!.value.isTakingPicture;
  }

  /// Toggle camera flash mode
  Future<void> toggleFlash() async {
    if (_cameraController == null) return;

    final currentMode = _cameraController!.value.flashMode;
    FlashMode newMode;

    switch (currentMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.off;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.off;
    }

    try {
      await _cameraController!.setFlashMode(newMode);
    } catch (e) {
      // Flash might not be available on all devices
    }
  }

  /// Switch between front and back cameras
  Future<bool> switchCamera() async {
    if (_availableCameras == null || _availableCameras!.length < 2) {
      return false;
    }

    final currentCamera = _cameraController?.description;
    if (currentCamera == null) return false;

    // Find next camera
    final currentIndex = _availableCameras!.indexOf(currentCamera);
    final nextIndex = (currentIndex + 1) % _availableCameras!.length;
    final nextCamera = _availableCameras![nextIndex];

    try {
      await _cameraController?.dispose();
      await initializeCamera(preferredLens: nextCamera.lensDirection);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
    _isInitialized = false;
  }

  /// Capture a series of images for better analysis
  Future<List<CameraResult>> captureImageSeries({
    int count = 3,
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    final results = <CameraResult>[];

    for (int i = 0; i < count; i++) {
      final result = await takePicture();
      results.add(result);

      if (i < count - 1) {
        await Future.delayed(interval);
      }
    }

    return results;
  }

  /// Validate multiple images for batch processing
  List<String> validateImages(List<File> imageFiles) {
    final errors = <String>[];

    for (int i = 0; i < imageFiles.length; i++) {
      final error = AppHelpers.validateImageFile(imageFiles[i]);
      if (error != null) {
        errors.add('Image ${i + 1}: $error');
      }
    }

    return errors;
  }
}

/// Result class for camera operations
class CameraResult {
  final bool success;
  final File? imageFile;
  final String? error;
  final DateTime timestamp;

  CameraResult({
    required this.success,
    this.imageFile,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory CameraResult.success(File imageFile) {
    return CameraResult(
      success: true,
      imageFile: imageFile,
    );
  }

  factory CameraResult.error(String error) {
    return CameraResult(
      success: false,
      error: error,
    );
  }

  /// Get image file size if available
  int? get fileSize => imageFile?.lengthSync();

  /// Get formatted file size
  String? get formattedFileSize {
    final size = fileSize;
    return size != null ? AppHelpers.formatFileSize(size) : null;
  }
}

/// Image metadata class
class ImageMetadata {
  final int fileSize;
  final int width;
  final int height;
  final String filePath;
  final DateTime lastModified;
  final String formattedSize;
  final double aspectRatio;

  const ImageMetadata({
    required this.fileSize,
    required this.width,
    required this.height,
    required this.filePath,
    required this.lastModified,
    required this.formattedSize,
    required this.aspectRatio,
  });

  /// Check if image meets minimum requirements for analysis
  bool get meetsAnalysisRequirements {
    return width >= 300 && height >= 300 && fileSize <= AppConstants.maxImageSize;
  }

  /// Get image orientation
  String get orientation {
    if (width > height) return 'Landscape';
    if (height > width) return 'Portrait';
    return 'Square';
  }
}

/// Custom camera exception class
class CameraException implements Exception {
  final String code;
  final String description;

  const CameraException(this.code, this.description);

  @override
  String toString() => 'CameraException: $code - $description';
}
