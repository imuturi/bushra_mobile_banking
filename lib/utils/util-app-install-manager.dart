import 'package:shared_preferences/shared_preferences.dart';

class AppInstallManager {
  static const _installFlagKey = 'install_id';

  /// Call this early in main() before using prefs anywhere else
  static Future<void> handleFirstInstall() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_installFlagKey)) {
      // This means either:
      // - Fresh install (never had prefs before), or
      // - Restored prefs from backup without this flag
      print("🆕 First launch after install → clearing old prefs");
      await prefs.clear(); // wipe old restored prefs
      await prefs.setString(_installFlagKey, DateTime.now().toIso8601String());
    } else {
      print("✅ Existing install → keeping prefs");
    }
  }
}
