import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bushra_mobile/utils/providers/provider-session.dart';
import 'package:bushra_mobile/utils/util-http-client.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../remote-config-services.dart';
import '../utils/constants/app_constants.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {

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
        Uri.parse(RemoteConfigService.baseUrl  + AppConstants.endpointFetchProfileImage + authProvider!.phoneNumber),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/octet-stream',
          'apikey': AppConstants.apiKey,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade900,
              Colors.transparent,
            ],
            stops: const [0.1, 0.9],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Background with concentric circles
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CirclesPainter(),
                    ),
                  ),
                  // Title
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Text(
                      AppLocalizations.of(context)!.weAreHereTonsupportYou,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  // Center icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration:  BoxDecoration(
                        color: Colors.blue.shade900,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.headset_mic,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Icons around circles
                  _buildCircleItem(
                    context,
                    icon: Icons.monetization_on,
                    top: 200,
                    left: 50,
                  ),
                  _buildCircleItem(
                    context,
                    icon: Icons.credit_card,
                    top: 200,
                    right: 50,
                  ),
                  _buildCircleItem(
                    context,
                    icon: Icons.receipt,
                    bottom: 200,
                    right: 100,
                  ),
                  _buildCircleItem(
                    context,
                    icon: Icons.person,
                    bottom: 200,
                    left: 100,
                  ),
                  // Profile images
                  _buildProfileImage(context, top: 300, left: 20),
                  _buildProfileImage(context, bottom: 300, right: 20),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      //TODO
                      final Uri url = Uri(scheme: 'tel', path: '+252611385050');
                      if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                      } else {
                      throw 'Could not launch $url';
                      }
                    },
                    icon: Icon(Icons.phone, color: Colors.blue.shade900),
                    label: Text(AppLocalizations.of(context)!.callCenter,
                      style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton.icon(
                    onPressed: () async {
                      //TODO
                      final url = Platform.isAndroid
                      ? 'https://maps.app.goo.gl/NMXdnuoTRKKMzZ1W6'
                          : 'https://maps.app.goo.gl/NMXdnuoTRKKMzZ1W6';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: Icon(Icons.location_on, color: Colors.blue.shade900),
                    label: Text(
                      AppLocalizations.of(context)!.bankDirection,
                      style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      //side: const BorderSide(color: Colors.indigo),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleItem(BuildContext context,
      {IconData? icon, double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue.shade900,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        radius: 34,
        child: FutureBuilder<Uint8List?>(
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
    );
  }
}

class CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    const radii = [120.0, 160.0, 200.0];

    for (final radius in radii) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
