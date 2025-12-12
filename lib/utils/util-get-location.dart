import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class DeviceLocation {

  static String? _cachedLatLon;
  static DateTime? _latLonExpiry;

  static Future<String?> getLocalIpAddress() async {
    try {
      for (var interface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
        for (var add in interface.addresses) {
          if (!add.isLoopback) {
            return add.address;
          }
        }
      }
    } catch (e) {
      print('Error getting IP address: $e');
    }
    return "IP";
  }

  static Future<String> getDeviceLocation() async {
    if (_cachedLatLon != null && _latLonExpiry != null && DateTime.now().isBefore(_latLonExpiry!)) {
      return _cachedLatLon!;
    }
    String latLon = "1.2921, 36.8219";
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return latLon;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best
    ).then((Position position) {
      latLon = '${position.latitude.toString()}, ${position.longitude.toString()}';
      _cachedLatLon = latLon;
      _latLonExpiry = DateTime.now().add(const Duration(hours: 5)); // Set TTL to 5 hour
      return _latLonExpiry!;
    }).catchError((e) {
      debugPrint(e);
      return latLon;
    });
    return latLon;
  }

  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('ERROR: Location services are disabled. Please enable the services');
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('ERROR: Location permissions are denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('ERROR: Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    return true;
  }
}
