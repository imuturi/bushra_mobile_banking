import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = true;
  final _storage = const FlutterSecureStorage();

  bool get isAuthenticated => _isAuthenticated;

  void logout() async {
    _isAuthenticated = false;
    notifyListeners();
    // Clear secure storage or token
    await _storage.deleteAll();
  }

  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }
}