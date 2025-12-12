import 'package:bushra_mobile/utils/constants/app_constants.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {

  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Initialize and fetch values once on app startup
  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 15),
      minimumFetchInterval: const Duration(minutes: 10),
    ));
    await _remoteConfig.fetchAndActivate();
    // Optionally, you can log the fetched values for debugging
    // Print all Remote Config values properly
    final allKeys = _remoteConfig.getAll().keys;
    for (final key in allKeys) {
      final value = _remoteConfig.getValue(key);
      if (kDebugMode) {
        print('Remote Config =====>> $key: ${value.asString()}');
      }
    }
  }

  static String get baseUrl =>
      _remoteConfig.getString('base_url_prod').isNotEmpty
          ? _remoteConfig.getString('base_url_prod')
          : AppConstants.baseUrl;

  static String get baseUrlToken =>
      _remoteConfig.getString('token_url_prod').isNotEmpty
          ? _remoteConfig.getString('token_url_prod')
          : AppConstants.baseUrlToken;

  static String get clientId =>
      _remoteConfig.getString('client_id_prod').isNotEmpty
          ? _remoteConfig.getString('client_id_prod')
          : AppConstants.clientId;

  static String get clientSecret =>
      _remoteConfig.getString('client_secret_prod').isNotEmpty
          ? _remoteConfig.getString('client_secret_prod')
          : AppConstants.clientSecret;

  static String get apiKey =>
      _remoteConfig.getString('api_key_prod').isNotEmpty
          ? _remoteConfig.getString('api_key_prod')
          : AppConstants.apiKey;

  static String get certificateHost =>
      _remoteConfig.getString('certificate_host').isNotEmpty
          ? _remoteConfig.getString('certificate_host')
          : AppConstants.certificateHost;

  static String get isProdBuild =>
      _remoteConfig.getString('is_prod_build').isNotEmpty
          ? _remoteConfig.getString('is_prod_build')
          : AppConstants.isProdBuild;

  static String get minVersion =>
      _remoteConfig.getString('min_version').isNotEmpty
          ? _remoteConfig.getString('min_version')
          : AppConstants.appVersion;

  static bool get allowDeveloperMode {
    final hasKey = _remoteConfig.getAll().containsKey('allow_developer_mode');
    return hasKey
        ? _remoteConfig.getBool('allow_developer_mode')
        : AppConstants.allowDeveloperMode;
  }

  static bool get allowExternalStorage {
    final hasKey = _remoteConfig.getAll().containsKey('allow_external_storage');
    return hasKey
        ? _remoteConfig.getBool('allow_external_storage')
        : AppConstants.allowExternalStorage;
  }

  static int get minBuild =>
      ( _remoteConfig.getString('min_build').isNotEmpty
          ? int.tryParse(_remoteConfig.getString('min_build'))
          : int.tryParse(AppConstants.appBuildNumber)
      ) ?? 18;

  static Duration get connectionTimeout {
    final timeoutStr = _remoteConfig.getString('connection_timeout');
    if (timeoutStr.isNotEmpty) {
      final seconds = int.tryParse(timeoutStr);
      if (seconds != null && seconds > 0) {
        return Duration(seconds: seconds);
      }
    }
    return AppConstants.connectionTimeout;
  }

  static Duration get readTimeout {
    final timeoutStr = _remoteConfig.getString('read_timeout');
    if (timeoutStr.isNotEmpty) {
      final seconds = int.tryParse(timeoutStr);
      if (seconds != null && seconds > 0) {
        return Duration(seconds: seconds);
      }
    }
    return AppConstants.readTimeout;
  }

}
