import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetCheckerService {
  static final InternetCheckerService _instance = InternetCheckerService._internal();
  factory InternetCheckerService() => _instance;

  InternetCheckerService._internal();

  final Connectivity _connectivity = Connectivity();
  Stream<List<ConnectivityResult>>? _connectivityStream;

  /// Stream to listen for connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream {
    _connectivityStream ??= _connectivity.onConnectivityChanged;
    return _connectivityStream!;
  }

  /// Checks if device has actual internet access
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
