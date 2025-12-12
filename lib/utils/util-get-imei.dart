import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:flutter/foundation.dart';

class DeviceIdentifier {

  static Future<String> getDeviceIdentifier() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = "Unknown";
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt < 29) {
          deviceId = androidInfo.id; // IMEI for Android 9 and below
        } else {
          //deviceId = androidInfo.androidId; // Alternative for Android 10+
          deviceId = androidInfo.id; // Alternative for Android 10+
        }
      } else if (Platform.isIOS) {
        deviceId = await FlutterUdid.udid; // Unique ID for iOS
      }
    } catch (e) {
      debugPrint("Error retrieving device identifier: $e");
    }
    return deviceId;
  }
}
