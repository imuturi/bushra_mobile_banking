import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import '../login/landing-login-3-login.dart';
import '../utils/constants/app_constants.dart';
import '../utils/reference-generator.dart';
import '../utils/util-api-service.dart';
import '../utils/util-get-imei.dart';
import '../widgets/progress-dialog.dart';
import 'camera_capture_screen.dart';

class OpenAccountSelfie2 extends StatefulWidget {
  final File frontImage;
  final File backImage;
  final String accountType;
  final String passportNumber;
  final String phoneNumber;
  final String dateOfBirth;

  const OpenAccountSelfie2({
    super.key,
    required this.frontImage,
    required this.backImage,
    required this.accountType,
    required this.passportNumber,
    required this.phoneNumber,
    required this.dateOfBirth
  });

  @override
  State<OpenAccountSelfie2> createState() => _TakeSelfieScreenState();
}

class _TakeSelfieScreenState extends State<OpenAccountSelfie2> {

  File? _image;
  final referenceGenerator = ReferenceGenerator();
  final apiService = ApiService();
  final deviceIdentifier = DeviceIdentifier();
  List<CameraDescription>? _cameras;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10),
        backgroundColor: color,
        action: SnackBarAction(
          label: "DISMISS",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void showCrossingBallsProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CrossingBallsProgressDialog(message: message,),
    );
  }

  Future<void> _initializeCameras() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();

      setState(() {
        _isLoading = false;
      });

      // If we have cameras, directly open the camera screen
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Wait a bit before opening camera to ensure UI is ready
        await Future.delayed(const Duration(milliseconds: 500));
        await _openCameraScreen();
      } else {
        if (mounted) {
          showSnackBar(context, 'No camera available', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, 'Failed to initialize camera: $e', Colors.red);
      }
    }
  }

  Future<void> _openCameraScreen() async {
    if (_cameras == null || _cameras!.isEmpty) {
      if (mounted) {
        showSnackBar(context, 'Camera not available', Colors.red);
      }
      return;
    }

    // Check if front camera is available
    final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraCaptureScreen(
          cameras: _cameras!,
          preferredCamera: frontCamera.lensDirection,
        ),
      ),
    );

    if (result != null && result is XFile) {
      setState(() {
        _image = File(result.path);
      });
    } else if (result != null && result is File) {
      setState(() {
        _image = result;
      });
    }
  }

  Future<void> _retakeSelfie() async {
    await _openCameraScreen();
  }

  //TODO Create a custom HTTP client that trusts self-signed certificates
  static http.Client _createCustomHttpClient() {
    final HttpClient client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(client);
  }

  Future<void> _uploadImages(BuildContext context) async {
    if (_image == null) {
      showSnackBar(context, 'Please take a selfie first', Colors.red);
      return;
    }

    showCrossingBallsProgressDialog(context, "We are uploading your details.\nPlease wait...");
    try{
      String _accountOpeningEndpoint = '/bb/account/opening/1.0.0';
      final stopwatch = Stopwatch()..start();
      final client = _createCustomHttpClient();

      var request = http.MultipartRequest(
          'POST',
          Uri.parse(AppConstants.baseUrl+_accountOpeningEndpoint)
      );

      String token = await apiService.getToken();
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
        'apikey': AppConstants.apiKey,
      });

      request.files.add(await http.MultipartFile.fromPath('identificationDocumentFront', widget.frontImage.path));
      request.files.add(await http.MultipartFile.fromPath('identificationDocumentBack', widget.backImage.path));
      request.files.add(await http.MultipartFile.fromPath('selfie', _image!.path));

      String imei = await DeviceIdentifier.getDeviceIdentifier();
      Map<String, dynamic> jsonBody = {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'phoneNumber': widget.phoneNumber,
          'email': "user@example.com",
          'accountType': "SAVINGS",
          'identificationDocumentNumber': widget.passportNumber,
          'customerName': "Default",
          'dateOfBirth': widget.dateOfBirth,
          'gender': "MALE",
          'residence': "Default",
          'postalAddress': "Default",
          'cif': "Default",
          'idType': "NATIONAL_ID",
          'idNumber': widget.passportNumber,
        },
        'channelDetails': {
          'host': "IP",
          'geolocation': "1.2921, 36.8219",
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': imei
        }
      };

      request.fields['request'] = json.encode(jsonBody);
      var response = await client.send(request);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('➡️ Making POST request to: ${AppConstants.baseUrl+_accountOpeningEndpoint}');
          stopwatch.stop();
          print('⬅️ Response Status: ${response.statusCode} (Duration : ${stopwatch.elapsedMilliseconds}ms)');
        }
        Navigator.pop(context);
        showDialog(
          barrierDismissible: false,
          context: context, builder: (context) => const CenteredImageDialog(),
        );
      } else {
        if (kDebugMode) {
          print("Upload failed with status: ${response.statusCode}");
        }
        Navigator.pop(context);
        showSnackBar(context, 'Error occurred in uploading images', Colors.red);
      }
    }catch(error){
      if (kDebugMode) {
        print('ERROR UPLOADING IMAGES : $error');
      }
      Navigator.pop(context);
      showSnackBar(context, 'Error occurred in uploading images : $error', Colors.red);
      throw Exception('ERROR UPLOADING IMAGES : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            'Take selfie',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Take selfie',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Take a selfie of yourself",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Take a selfie and we will do a face match with the photo on your National ID.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade900),
            ),
            const SizedBox(height: 100),
            _image != null
                ? CircleAvatar(
              radius: 100,
              backgroundImage: FileImage(_image!),
            )
                : CircleAvatar(
              radius: 100,
              backgroundColor: Colors.grey.shade200,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "No selfie taken",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _image != null ? Colors.red.shade900 : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _image != null ? () {
                  _uploadImages(context);
                } : null,
                child: const Text("CONTINUE",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold,)
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade900),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _retakeSelfie,
                child: Text(
                  _image != null ? "RE-TAKE SELFIE" : "TAKE SELFIE",
                  style: TextStyle(fontSize: 16, color: Colors.red.shade900, fontWeight: FontWeight.bold,),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class CenteredImageDialog extends StatelessWidget {
  const CenteredImageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/icons/success-check.png',
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            const Text(
              'Account successfully registered',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your account has been set up. Please wait as we share your account details. Thank you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PinInputLoginScreen()),);
                },
                child: const Text('CONTINUE',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}