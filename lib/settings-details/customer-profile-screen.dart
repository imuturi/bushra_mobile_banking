import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../remote-config-services.dart';
import '../utils/constants/app_constants.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-http-client.dart';
import '../widgets/progress-dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  final picker = ImagePicker();
  File? _imageFile;


  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final String pathUploadImage = "/bb/mobile/customer/uploadprofilephoto/1.0.0";

  Future<void> _showImageSourceSelector() async {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800, // Resize image
      maxHeight: 800,
      imageQuality: 70, // Compress image (0 = worst, 100 = best)
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
    _nameController.text = '${authProvider?.customerDetails.firstName} ${authProvider?.customerDetails.lastName}';
    _emailController.text = authProvider!.customerDetails.emailAddress!;
    _phoneController.text = authProvider.phoneNumber;
    _provinceController.text = 'Province';
    _cityController.text = 'City / Town';
    _districtController.text = 'District';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void showCrossingBallsProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CrossingBallsProgressDialog(message: message,),
    );
  }

  void showAlertDialogSuccess(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final dialogWidth = isLandscape
        ? mediaQuery.size.width * 0.5
        : mediaQuery.size.width * 0.8;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/images/icons/success-check.png',
                    width: mediaQuery.size.width * 0.15,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Profile changed successfully',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your profile details have been updated successfully.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'ACTIVATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadData() async {
    final token = Provider.of<SessionProvider>(context, listen: false).user?.token ?? '';
    try {
      await _clearImageCache();
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }
      setState(() => _isLoading = true);
      showCrossingBallsProgressDialog(context, 'We are updating your profile\nPlease Wait...');
      final dio = await createPinnedDioClient();
      final formData = FormData.fromMap({
        "phoneNumber": _phoneController.text,
        "file": await MultipartFile.fromFile(_imageFile!.path,
            filename: _imageFile!.path.split('/').last),
      });
      final response = await dio.post(
        RemoteConfigService.baseUrl + pathUploadImage,
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            'apikey': RemoteConfigService.apiKey,
          },
          contentType: 'multipart/form-data',
        ),
      );
      Navigator.of(context).pop(); // Close the progress dialog
      if (response.statusCode == 200) {
        showAlertDialogSuccess(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusMessage}')),
        );
      }
      setState(() => _isLoading = false);
    } catch (e, st) {
      print('Upload error: $e');
      print('Stacktrace: $st');
      Navigator.of(context).pop();
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<Uint8List?> _fetchImageBytes() async {
    try {
      print("-------------------------- Fetching profile image (Base64 string)...");
      // Try to load from cache
      final cached = await _loadImageFromCache();
      if (cached != null) {
        print('✅ Using cached profile image picture');
        return cached;
      }
      final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
      final token = authProvider?.token;
      final httpClient = await createPinnedHttpClient();
      final ioClient = IOClient(httpClient);
      final response = await ioClient.get(
        Uri.parse(RemoteConfigService.baseUrl + AppConstants.endpointFetchProfileImage + authProvider!.phoneNumber),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/octet-stream',
          'apikey': RemoteConfigService.apiKey,
        },
      );
      print('-------------------------- Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type']; // e.g. 'image/png'
        final base64Str = utf8.decode(response.bodyBytes);
        final bytes = base64Decode(base64Str);
        print("Decoded Base64 length: ${base64Str.length}");
        print("Response Content-Type: $contentType");
        // Save to cache with correct extension
        await _saveImageToCache(bytes, contentType);
        return bytes;
      } else {
        print('Error fetching image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error decoding image: $e');
      return null;
    }
  }

  Future<File> _saveImageToCache(Uint8List bytes, String? contentType) async {
    final dir = await getApplicationDocumentsDirectory();
    // Decide extension based on content-type
    String extension = 'jpg'; // Default fallback
    if (contentType != null) {
      if (contentType.contains('png')) {
        extension = 'png';
      } else if (contentType.contains('jpeg') || contentType.contains('jpg')) {
        extension = 'jpg';
      }
    }
    final file = File('${dir.path}/cached_profile_image.$extension');
    return await file.writeAsBytes(bytes);
  }

  Future<Uint8List?> _loadImageFromCache() async {
    final dir = await getApplicationDocumentsDirectory();
    // Check for both .jpg and .png (or any other formats you've added)
    final jpgFile = File('${dir.path}/cached_profile_image.jpg');
    final jpegFile = File('${dir.path}/cached_profile_image.jpeg');
    final pngFile = File('${dir.path}/cached_profile_image.png');
    if (await jpgFile.exists()) {
      return await jpgFile.readAsBytes();
    } else if (await jpegFile.exists()) {
      return await jpegFile.readAsBytes();
    } else if (await pngFile.exists()) {
      return await pngFile.readAsBytes();
    }
    return null; // Return null if neither file exists
  }

  Future<void> _clearImageCache() async {
    final dir = await getApplicationDocumentsDirectory();
    // Check for both .jpg and .png (or any other formats you've added)
    final jpgFile = File('${dir.path}/cached_profile_image.jpg');
    final pngFile = File('${dir.path}/cached_profile_image.png');
    // Delete the .jpg file if it exists
    if (await jpgFile.exists()) {
      await jpgFile.delete();
      print("🧹 Cleared cached image (JPG)");
    }
    // Delete the .png file if it exists
    if (await pngFile.exists()) {
      await pngFile.delete();
      print("🧹 Cleared cached image (PNG)");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Profile information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  radius: 50,
                  child: _imageFile != null
                      ? ClipOval(
                    child: Image.file(
                      _imageFile!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      : FutureBuilder<Uint8List?>(
                    future: _fetchImageBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return ClipOval(
                          child: Image.memory(
                            snapshot.data!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50, color: Colors.grey),
                          ),
                        );
                      } else {
                        return const Icon(Icons.person, size: 50, color: Colors.grey);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blue.shade600,
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  ),
                  //onPressed: () => _pickImage(ImageSource.camera),
                  onPressed: _showImageSourceSelector,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle("Personal Details"),
            _inputCard([
              _buildTextField(_nameController, '${authProvider?.customerDetails.firstName} ${authProvider?.customerDetails.lastName}'),
              _buildTextField(_emailController, authProvider!.customerDetails.emailAddress!),
              _buildTextField(_phoneController, authProvider.phoneNumber),
            ]),
            const SizedBox(height: 18),
            _sectionTitle("Additional Address"),
            _inputCard([
              _buildTextField(_provinceController, 'Province'),
              _buildTextField(_cityController, 'City / Town'),
              _buildTextField(_districtController, 'District'),
            ]),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _uploadData,
              child: const Text("Save Changes",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Stack(
        children: [
          TextField(
            enabled: false,
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              hintStyle: const TextStyle(color: Colors.black87),
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _inputCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

}
