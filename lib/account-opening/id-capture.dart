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
    required this.dateOfBirth
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

      // Load image for cropping
      img.Image? original = img.decodeImage(await capturedFile.readAsBytes());
      if (original != null) {
        // int centerX = original.width ~/ 2;
        // int centerY = original.height ~/ 2;
        // int cropWidth = 300;
        // int cropHeight = 180;
        // img.Image cropped = img.copyCrop(original,
        //     x: centerX - cropWidth ~/ 2,
        //     y: centerY - cropHeight ~/ 2,
        //     width: cropWidth,
        //     height: cropHeight
        // );
        // File croppedFile = File(image.path)..writeAsBytesSync(img.encodeJpg(cropped));
        //
        // setState(() {
        //   if (_isFrontSide) {
        //     _frontImage = croppedFile;
        //   } else {
        //     _backImage = croppedFile;
        //   }
        // });

        if (!mounted) return; // Ensure widget is still active
        setState(() {
          if (_isFrontSide) {
            _frontImage = capturedFile;
          } else {
            _backImage = capturedFile;
          }
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
                          //TODO
                        },
                      ),
                    ],
                  ),
                ),
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
                      _toggleButton("FRONT", _isFrontSide),
                      _toggleButton("BACK", !_isFrontSide),
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
                  onPressed: (){
                    //TODO
                    _captureImage(context);
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isFrontSide = (label == "FRONT")),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? Colors.purple.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
    required this.dateOfBirth
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
          const SizedBox(height: 40,),
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
          // Image.file(frontImage),
          // Image.file(backImage),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //TODO
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OpenAccountVerifyIdentityScreen(
                    frontImage: frontImage,
                    backImage: backImage,
                    accountType: accountType,
                    passportNumber: passportNumber,
                    phoneNumber: phoneNumber,
                    dateOfBirth: dateOfBirth,)
                  ),);
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
          )
        ],
      ),
    );
  }
}
