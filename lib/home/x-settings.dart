import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/io_client.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:app_settings/app_settings.dart'; // to open settings
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../change-pin/forgot-pin-set-pin/page-forgot-pin-create.dart';
import '../page-landing/page-home-landing-support.dart';
import '../remote-config-services.dart';
import '../settings-details/customer-profile-screen.dart';
import '../utils/constants/app_constants.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-http-client.dart';
import '../widgets/dialog-coming-soon.dart';

class SettingsScreen extends StatefulWidget {
  final bool showBackButton;
  const SettingsScreen({super.key, required this.showBackButton});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationFlag = false;
  bool alertFlag = false;
  bool biometricsFlag = false;
  String _appVersion = '';

  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadSecureStorage();
    notificationFlag = false; // Default value
    alertFlag = false; // Default value
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10), // Set to any duration
        backgroundColor: color,
        action: SnackBarAction(
          label: "DISMISS",
          textColor: Colors.white,
          onPressed: () {
            //
          }, // Dismiss action
        ),
      ),
    );
  }

  Future<Uint8List?> _fetchImageBytes() async {
    try {
      print("-------------------------- Fetching profile image (Base64 string)...");
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

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (Build ${info.buildNumber})';
    });
  }

  Future<void> _loadSecureStorage() async {
    final secureStorage = const FlutterSecureStorage();
    String? biometricsEnabled = await secureStorage.read(key: 'BIOMETRICS_ENABLED');
    setState(() {
      biometricsFlag = biometricsEnabled == 'true'; // default false
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometrics not supported on this device")),
        );
        return;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Confirm your identity to enable biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      final secureStorage = const FlutterSecureStorage();

      if (didAuthenticate) {
        await secureStorage.write(key: 'BIOMETRICS_ENABLED', value: 'true');
        setState(() {
          biometricsFlag = true;
        });
      } else {
        await secureStorage.write(key: 'BIOMETRICS_ENABLED', value: 'false');
        setState(() {
          biometricsFlag = false;
        });
      }
    } catch (e) {
      if (e is PlatformException && e.code == auth_error.notEnrolled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No biometrics enrolled, please set up in Settings")),
        );
        AppSettings.openAppSettings(type: AppSettingsType.security);
      } else {
        debugPrint("Biometric error: $e");
      }
    }
  }

  Future<void> _promptBiometricActivation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth > 400 ? 400.0 : screenWidth * 0.9;
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dialogWidth),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fingerprint, size: 50, color: Colors.red),
                    const SizedBox(height: 14),
                    const Text(
                      "Activate your Biometrics",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "You don’t have any Fingerprint or Face ID activated yet on your account. "
                          "Activate Fingerprint or Face ID for easier Login and authorisation",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Activate Button → return true
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        //onPressed: () => Navigator.pop(context, true),
                        onPressed: () async {
                          Navigator.pop(context); // close dialog
                          await _toggleBiometrics(true); // trigger biometric setup
                        },
                        child: const Text(
                          "ACTIVATE",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Not Now Button → return false
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "NOT NOW",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    //return result ?? false;
  }

  Future<bool> _promptBiometricDeactivation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth > 400 ? 400.0 : screenWidth * 0.9;

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dialogWidth),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fingerprint, size: 50, color: Colors.red),
                    const SizedBox(height: 14),
                    const Text(
                      "De-Activate your Biometrics",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Please confirm if you want to de-activate Biometrics on your account. "
                          "You will need to use your PIN for Login and authorisation",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Deactivate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          Navigator.pop(context, true); // Close dialog & confirm
                        },
                        child: const Text(
                          "DE-ACTIVATE",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Cancel
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          "NOT NOW",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // If user confirmed deactivation → require biometric authentication again
    if (result == true) {
      try {
        final didAuthenticate = await auth.authenticate(
          localizedReason: 'Confirm your identity to deactivate biometrics',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );
        return didAuthenticate; // true if confirmed
      } catch (e) {
        debugPrint("Biometric error on deactivation: $e");
        return false;
      }
    }

    return false; // Cancelled
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SessionProvider>(context).user;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ✅ Prevent Flutter from automatically adding a back button
        automaticallyImplyLeading: false,
        // ✅ Only show back button when explicitly requested
        leading: widget.showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ) : null,
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        centerTitle: false,
      ),
      body: authProvider != null
          ? Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()),);
                            },
                            child: Container(
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.shade100, // Border color
                                  width: 1.0, // Border width
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${authProvider.customerDetails.firstName} ${authProvider.customerDetails.lastName}\n',
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          TextSpan(
                                            text: authProvider.customerDetails.emailAddress,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12,),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300, // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                const Row(
                                  children: [
                                    Icon(Icons.perm_identity_outlined),
                                    SizedBox(width: 10),
                                    Text(
                                      'General',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                                  leading: const Icon(Icons.support_agent, size: 18,),
                                  title: const Text('Support',
                                    style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                  ),),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()),);
                                  },
                                ),
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                                  leading: const Icon(Icons.lock, size: 18,),
                                  title: const Text('Change PIN',
                                    style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                  ),),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) => const ConfirmChangePinDialog(),
                                    );
                                  },
                                ),
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                                  leading: const Icon(Icons.language,size: 18,),
                                  title: const Text('Change language (English)',
                                    style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                  ),),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const ComingSoonDialog(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                const Row(
                                  children: [
                                    Icon(Icons.notifications_none),
                                    SizedBox(width: 10),
                                    Text(
                                      'Notification',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Notifications', style: TextStyle(fontSize: 11)),
                                      Transform.scale(
                                        scale: 0.5, // Adjust to your preferred size
                                        child: Switch(
                                          value: notificationFlag,
                                          onChanged: (value) {
                                            setState(() => notificationFlag = value);
                                            if (value) {
                                              showDialog(context: context, builder: (_) => const ComingSoonDialog());
                                            }
                                          },
                                          activeColor: Colors.red.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Transaction Alert', style: TextStyle(fontSize: 11)),
                                      Transform.scale(
                                        scale: 0.5, // Adjust to your preferred size
                                        child: Switch(
                                          value: alertFlag,
                                          onChanged: (value) {
                                            setState(() => alertFlag = value);
                                            if (value) {
                                              showDialog(context: context, builder: (_) => const ComingSoonDialog());
                                            }
                                          },
                                          activeColor: Colors.red.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Row(
                                  children: [
                                    Icon(Icons.settings),
                                    SizedBox(width: 10),
                                    Text(
                                      'Settings',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Activate Biometric', style: TextStyle(fontSize: 11)),
                                      Transform.scale(
                                        scale: 0.5, // Adjust to your preferred size
                                        child: Switch(
                                          value: biometricsFlag,
                                          onChanged: (value) async {
                                            final secureStorage = const FlutterSecureStorage();
                                            if (value) {
                                              await _promptBiometricActivation();
                                            } else {
                                              final confirmed = await _promptBiometricDeactivation();
                                              if (confirmed) {
                                                await secureStorage.write(key: 'BIOMETRICS_ENABLED', value: 'false');
                                                setState(() => biometricsFlag = false);
                                              } else {
                                                setState(() => biometricsFlag = true); // revert if not confirmed
                                              }
                                            }
                                          },
                                          activeColor: Colors.red.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Center(
                                  child: Text(
                                    'App Version: $_appVersion',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) => const ConfirmLogOutDialog(),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade900,
                                        minimumSize: const Size(double.infinity, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'LOGOUT',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
        )
          : const Center(child: Text("No customer details found")),
    );
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      if (kDebugMode) {
        print(e);
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }
  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

}

class ConfirmLogOutDialog extends StatelessWidget {
  const ConfirmLogOutDialog({super.key,});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to logout ?.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'By confirming (YES) you will be logged out and by (NO) you will remain logged in',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: screenWidth * 0.8, // responsive width
                child: ElevatedButton(
                  onPressed: () async {
                    //TODO: Implement update logic
                    Provider.of<SessionProvider>(context, listen: false).logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'YES',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 6,),
              SizedBox(
                width: screenWidth * 0.8, // responsive width
                child: ElevatedButton(
                  onPressed: () async {
                    //TODO: Implement update logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'NO',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmChangePinDialog extends StatelessWidget {
  const ConfirmChangePinDialog({super.key,});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to change your PIN ?.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'By confirming (YES) you will be you will be redirected to change your PIN and by (NO) you will remain logged with current',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: screenWidth * 0.8, // responsive width
                child: ElevatedButton(
                  onPressed: () async {
                    //TODO: Implement update logic
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('IN_APP_PIN_CHANGE', true);
                    String? phoneNumber  = prefs.getString("USER_LOGIN_ID");
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPinPinInputScreen1()),);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'YES',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 6,),
              SizedBox(
                width: screenWidth * 0.8, // responsive width
                child: ElevatedButton(
                  onPressed: () async {
                    //TODO: Implement update logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'NO',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
