
import 'dart:io';

import 'package:bushra_mobile/utils/reference-generator.dart';
import 'package:bushra_mobile/utils/util-api-service.dart';
import 'package:bushra_mobile/utils/util-get-imei.dart';
import 'package:bushra_mobile/utils/util-get-location.dart';

import 'api_module.dart';

class ApiOtpFunctions{

  final apiService = ApiService();
  final referenceGenerator = ReferenceGenerator();

  static const String _customerOtpVerificationEndpoint = '/bb/mobile/otp/verification/1.0.0';
  static const String _customerOtpResendEndpoint = '/bb/mobile/resend/otp/1.0.0';

  Future<dynamic> generateOtp(String phoneNumber, String debitAccount) async {
    return apiService.makeApiCall(
      _customerOtpResendEndpoint,
      ApiModule.otp,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "GENERATEOTP",
          'transactionCode': "GENERATEOTP",
          'hostCode': "MOBILE",
          'debitAccount': phoneNumber,
          'phoneNumber': phoneNumber,
        },
        'channelDetails': {
          'host': await DeviceLocation.getLocalIpAddress(),
          'geolocation': "1.2921, 36.8219",//await DeviceLocation.getDeviceLocation(),
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': await DeviceIdentifier.getDeviceIdentifier(),
        }
      },
    );
  }
  Future<dynamic> verifyOtp(String phoneNumber, String otpCode) async {
    return apiService.makeApiCall(
      _customerOtpVerificationEndpoint,
      ApiModule.otp,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "VERIFYOTP",
          'transactionCode': "VERIFYOTP",
          'hostCode': "MOBILE",
          'debitAccount': phoneNumber,
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
        },
        'channelDetails': {
          'host': await DeviceLocation.getLocalIpAddress(),
          'geolocation': "1.2921, 36.8219",//await DeviceLocation.getDeviceLocation(),
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': await DeviceIdentifier.getDeviceIdentifier(),
        }
      },
    );
  }

}