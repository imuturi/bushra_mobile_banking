import 'dart:io';

import 'package:bushra_mobile/utils/reference-generator.dart';
import 'package:bushra_mobile/utils/util-api-service.dart';
import 'package:bushra_mobile/utils/util-get-imei.dart';
import 'package:bushra_mobile/utils/util-get-location.dart';
import 'api_module.dart';

class ApiQrCode{

  static const String _generateQrCodeEndpoint = '/bb/mobile/somqr/generate/1.0.0';
  static const String _processQrCodeEndpoint = '/bb/mobile/somqr/process/1.0.0';

  final apiService = ApiService();
  final referenceGenerator = ReferenceGenerator();

  Future<dynamic> generateQrCode(String accountNumber, String accountName, String amount, String currency, String qrType, String narration) async {
    return apiService.makeApiCall(
      _generateQrCodeEndpoint,
      ApiModule.qrcode,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "GENERATE_QR_CODE",
          'transactionCode': "GENERATE_QR_CODE",
          'hostCode': "MOBILE",
          'debitAccount': accountNumber,
          'accountName': accountName,
          'amount': amount,
          'currency': currency,
          'qrType': qrType,
          'narration': narration,
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

  Future<dynamic> processQrCode(String qrData) async {
    return apiService.makeApiCall(
      _processQrCodeEndpoint,
      ApiModule.qrcode,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'qrData': qrData,
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