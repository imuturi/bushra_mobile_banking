import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraLensDirection preferredCamera;

  const CameraCaptureScreen({
    super.key,
    required this.cameras,
    this.preferredCamera = CameraLensDirection.front,
  });

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  CameraDescription? _selectedCamera;
  CameraLensDirection _currentCameraDirection = CameraLensDirection.front;
  bool _isSwitchingCamera = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _currentCameraDirection = widget.preferredCamera;
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (widget.cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      try {
        _selectedCamera = widget.cameras.firstWhere(
              (camera) => camera.lensDirection == _currentCameraDirection,
        );
      } catch (e) {
        _selectedCamera = widget.cameras.first;
        _currentCameraDirection = _selectedCamera!.lensDirection;
      }

      await _controller?.dispose();

      _controller = CameraController(
        _selectedCamera!,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isSwitchingCamera = false;
          _isInitializing = false;
        });
      });

      setState(() {
        _isInitializing = true;
      });
    } catch (e) {
      debugPrint("Error initializing camera: $e");
      if (mounted) {
        setState(() {
          _isSwitchingCamera = false;
          _isInitializing = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Camera error: ${e.toString()}')),
            );
            Navigator.pop(context);
          }
        });
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      if (!mounted) return;

      if (_controller == null || !_controller!.value.isInitialized) {
        throw Exception('Camera controller not initialized');
      }

      final image = await _controller!.takePicture();

      if (!mounted) return;

      Navigator.pop(context, image);
    } catch (e) {
      debugPrint("Error taking picture: $e");

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error taking picture: ${e.toString()}')),
          );
        }
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_isSwitchingCamera || widget.cameras.length < 2) return;

    setState(() {
      _isSwitchingCamera = true;
    });

    try {
      final currentIndex = widget.cameras.indexOf(_selectedCamera!);
      final nextIndex = (currentIndex + 1) % widget.cameras.length;
      _selectedCamera = widget.cameras[nextIndex];
      _currentCameraDirection = _selectedCamera!.lensDirection;

      await _initializeCamera();
    } catch (e) {
      debugPrint("Error switching camera: $e");
      if (mounted) {
        setState(() {
          _isSwitchingCamera = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error switching camera: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate available space excluding app bar
    final appBarHeight = AppBar().preferredSize.height;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - appBarHeight - MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Take Selfie',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Centered camera preview - positioned to account for app bar
          if (_controller != null && _initializeControllerFuture != null)
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_controller != null && _controller!.value.isInitialized) {
                    final cameraAspectRatio = _controller!.value.aspectRatio;

                    // Calculate height based on aspect ratio and available width
                    final screenWidth = MediaQuery.of(context).size.width;
                    final previewHeight = screenWidth / 0.9;

                    return Positioned(
                      top: (availableHeight - previewHeight) / 2 - 40,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: screenWidth,
                        height: previewHeight,
                        child: CameraPreview(_controller!),
                      ),
                    );
                  } else {
                    return Center(
                      child: Container(
                        margin: EdgeInsets.only(top: availableHeight / 2),
                        child: const Text(
                          'Camera not initialized',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: Container(
                      margin: EdgeInsets.only(top: availableHeight / 2),
                      child: const CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
              },
            ),

          // Capture button
          if (!_isInitializing)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 4),
                    ),
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (_isSwitchingCamera || _isInitializing)
            Center(
              child: Container(
                margin: EdgeInsets.only(top: availableHeight / 2),
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}