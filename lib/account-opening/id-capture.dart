import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

import 'open-account-5-scan-id.dart';

class IdCaptureScreen extends StatefulWidget {
  final String accountType;
  final String passportNumber;
  final String phoneNumber;
  final String dateOfBirth;
  const IdCaptureScreen({
    super.key,
    required this.accountType,
    required this.passportNumber,
    required this.phoneNumber,
    required this.dateOfBirth,
  });

  @override
  _IdCaptureScreenState createState() => _IdCaptureScreenState();
}

class _IdCaptureScreenState extends State<IdCaptureScreen> {
  CameraController? _cameraController;
  bool _isFrontSide = true;
  File? _frontImage;
  File? _backImage;
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _captureImage(BuildContext context) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final image = await _cameraController!.takePicture();
      File capturedFile = File(image.path);

      img.Image? original = img.decodeImage(await capturedFile.readAsBytes());
      if (original != null) {
        if (!mounted) return;

        if (_isFrontSide) {
          // Front captured — show confirmation sheet before proceeding to back
          setState(() {
            _frontImage = capturedFile;
          });
          _showFrontCapturedSheet(context, capturedFile);
        } else {
          // Back captured — proceed normally
          setState(() {
            _backImage = capturedFile;
          });

          if (_frontImage != null && _backImage != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewScreen(
                  frontImage: _frontImage!,
                  backImage: _backImage!,
                  accountType: widget.accountType,
                  passportNumber: widget.passportNumber,
                  phoneNumber: widget.phoneNumber,
                  dateOfBirth: widget.dateOfBirth,
                ),
              ),
            );
          }
        }
      }
    }
  }

  void _showFrontCapturedSheet(BuildContext context, File capturedFile) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon + title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Front Side Captured!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Now let's scan the back side of your ID.",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Thumbnail of the captured front image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  capturedFile,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Retake or Continue buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Clear front image and dismiss sheet to retake
                        setState(() {
                          _frontImage = null;
                        });
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text("Retake"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        // Switch to back side
                        setState(() {
                          _isFrontSide = false;
                        });
                      },
                      icon: const Icon(Icons.flip, size: 18, color: Colors.white),
                      label: const Text(
                        "Scan Back Side",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _cameraController != null && _cameraController!.value.isInitialized
              ? CameraPreview(_cameraController!)
              : Container(color: Colors.black),
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on, color: Colors.white, size: 30),
                        onPressed: () {
                          // TODO: implement flash toggle
                        },
                      ),
                    ],
                  ),
                ),

                // Toggle with captured indicator
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _toggleButton("FRONT", _isFrontSide, captured: _frontImage != null),
                      _toggleButton("BACK", !_isFrontSide, captured: _backImage != null),
                    ],
                  ),
                ),

                if (_showInstructions)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Place the camera to fit in the frame and scan ID to get details of the Identification card",
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showInstructions = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
                          child: const Text("GOT IT", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),
                Container(
                  width: 300,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 5),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.camera, color: Colors.white, size: 50),
                  onPressed: () => _captureImage(context),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isActive, {bool captured = false}) {
    return GestureDetector(
      onTap: () => setState(() => _isFrontSide = (label == "FRONT")),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? Colors.purple.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (captured) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: 14,
                color: isActive ? Colors.greenAccent : Colors.green.shade600,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final File frontImage;
  final File backImage;
  final String accountType;
  final String passportNumber;
  final String phoneNumber;
  final String dateOfBirth;

  const PreviewScreen({
    super.key,
    required this.frontImage,
    required this.backImage,
    required this.accountType,
    required this.passportNumber,
    required this.phoneNumber,
    required this.dateOfBirth,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Preview ID Card",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              children: [
                Image.file(
                  File(frontImage.path),
                  height: 200,
                  width: 350,
                ),
                const SizedBox(height: 20),
                Image.file(
                  File(backImage.path),
                  height: 200,
                  width: 230,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpenAccountVerifyIdentityScreen(
                        frontImage: frontImage,
                        backImage: backImage,
                        accountType: accountType,
                        passportNumber: passportNumber,
                        phoneNumber: phoneNumber,
                        dateOfBirth: dateOfBirth,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "CONTINUE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}