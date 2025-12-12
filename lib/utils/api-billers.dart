
import 'dart:io';

import 'package:bushra_mobile/utils/reference-generator.dart';
import 'package:bushra_mobile/utils/util-api-service.dart';

import 'api_module.dart';

class ApiBillers{

  final apiService = ApiService();
  final referenceGenerator = ReferenceGenerator();

  static const String _fetchBillersEndpoint = '/bb/mobile/getbillers/1.0.0';
  static const String _fetchBillHistoryEndpoint = '/bb/mobile/billpayment/statement/1.0.0';

  Future<dynamic> fetchBillers(String category) async {
    return apiService.makeApiCall(
      "$_fetchBillersEndpoint?category=${category.toUpperCase()}",
      ApiModule.billPayments,
      method: 'GET',
    );
  }

  Future<dynamic> fetchBillHistory(String debitAccount, String phone, String deviceId, int pageSize) async {
    return apiService.makeApiCall(
      _fetchBillHistoryEndpoint,
      ApiModule.billPayments,
      method: 'POST',
      body: {
        "txntimestamp": DateTime.now().toUtc().toIso8601String(),
        "xref": referenceGenerator.generateUniqueReference(false),
        "transactionDetails": {
          "direction": "0200",
          "transactionType": "BILLPAYMENTSTATEMENT",
          "transactionCode": "BILLPAYMENTSTATEMENT",
          "hostCode": "MOBILE",
          "debitAccount": debitAccount,
          "creditAccount": debitAccount,
          "phoneNumber": phone,
          "transactionCount": pageSize,
          "amount": 0,
          "currency": "USD"
        },
        "channelDetails": {
          "host": "IP",
          "geolocation": "1.2921, 36.8219",
          "userAgent": Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          "userAgentVersion": "1.0",
          "channel": "MOBILE",
          "clientId": "client123",
          "deviceId": deviceId,
        }
      },
    );
  }

}