import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';

import '../remote-config-services.dart';

class SecurityService {

  static Future<bool> isDeviceSecure() async {
    try {
      final instance = JailbreakRootDetection.instance;
      // Core security checks (always enforced)
      final isNotTrust = await instance.isNotTrust;
      final isRealDevice = await instance.isRealDevice;
      bool platformSpecificIssue = false;
      String platformIssueType = 'none';
      if (Platform.isAndroid) {
        final isDevMode = RemoteConfigService.allowDeveloperMode ? false : await instance.isDevMode;
        final isOnExternalStorage = RemoteConfigService.allowExternalStorage ? false : await instance.isOnExternalStorage;
        platformSpecificIssue = isDevMode || isOnExternalStorage;
        await FirebaseCrashlytics.instance.log(
            'Android Security Check: '
                'isNotTrust=$isNotTrust, '
                'isRealDevice=$isRealDevice, '
                'isDevMode=${await instance.isDevMode}, ' // Log actual value
                'isOnExternalStorage=${await instance.isOnExternalStorage}'
        );
        if (isDevMode) platformIssueType = 'android_dev_mode';
        if (isOnExternalStorage) platformIssueType = 'external_storage';
      }
      else if (Platform.isIOS) {
        final isJailBroken = await instance.isJailBroken;
        platformSpecificIssue = isJailBroken;
        platformIssueType = isJailBroken ? 'jailbroken' : 'none';
        await FirebaseCrashlytics.instance.log(
            'iOS Security Check: '
                'isNotTrust=$isNotTrust, '
                'isRealDevice=$isRealDevice, '
                'isJailBroken=$isJailBroken'
        );
      }
      // Record metrics
      await _recordSecurityMetrics(
        isNotTrust: isNotTrust,
        isRealDevice: isRealDevice,
        platformIssueType: platformIssueType,
      );

      return !isNotTrust && isRealDevice && !platformSpecificIssue;
    } catch (e, stack) {
      await _recordSecurityError(e, stack);
      return false; // Fail secure
    }
  }

  static Future<void> _recordSecurityMetrics({
    required bool isNotTrust,
    required bool isRealDevice,
    required String platformIssueType,
  }) async {
    await FirebaseCrashlytics.instance.setCustomKey('security_is_not_trust', isNotTrust);
    await FirebaseCrashlytics.instance.setCustomKey('security_is_real_device', isRealDevice);
    await FirebaseCrashlytics.instance.setCustomKey('security_platform_issue', platformIssueType);
    if (!isRealDevice || isNotTrust || platformIssueType != 'none') {
      await FirebaseCrashlytics.instance.recordError(
        Exception('Insecure device detected: $platformIssueType'),
        StackTrace.current,
        reason: 'Security check failed',
        information: [
          'isNotTrust: $isNotTrust',
          'isRealDevice: $isRealDevice',
          'platformIssue: $platformIssueType',
          'platform: ${Platform.operatingSystem}',
          'timestamp: ${DateTime.now().toIso8601String()}',
        ],
        fatal: false,
      );
    }
  }

  static Future<void> _recordSecurityError(dynamic e, StackTrace stack) async {
    await FirebaseCrashlytics.instance.recordError(
      e,
      stack,
      reason: 'Security check error',
      fatal: false,
    );
    await FirebaseCrashlytics.instance.setCustomKey('security_policy_version', '1.1');
    await FirebaseCrashlytics.instance.setCustomKey('app_build_mode', kReleaseMode ? 'release' : 'debug');
    await FirebaseCrashlytics.instance.setCustomKey('security_check_failed', true);
    await FirebaseCrashlytics.instance.setCustomKey('last_security_error', e.toString());
  }
}