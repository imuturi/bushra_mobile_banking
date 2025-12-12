import 'dart:io';

import 'package:bushra_mobile/utils/reference-generator.dart';
import 'package:bushra_mobile/utils/util-api-service.dart';

import 'api_module.dart';

class ApiCustomerTermDeposits {

  final apiService = ApiService();
  final referenceGenerator = ReferenceGenerator();

  static const String _customerGetTermDepositEndpoint = '/bb/mobile/termdeposit/query/1.0.0';
  static const String _customerGetTermDepositDetailsEndpoint ='/bb/termdeposit/query/1.0.0';
  static const String _customerCreateTermDepositEndpoint = '/bb/mobile/termdeposit/create/1.0.0';
  static const String _customerTermDepositClass = '/bb/mobile/termdeposit/getclass/1.0.0';

  Future<dynamic> getTermDepositsClass(String imei, String messageId) async {
    return apiService.makeApiCall(
      _customerTermDepositClass,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': messageId,
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "TERMDEPOSITSCLASS",
          'transactionCode': "TERMDEPOSITSCLASS",
          'hostCode': "MOBILE",
        },
        'channelDetails': {
          'host': "IP",
          'geolocation': "1.2921, 36.8219",
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': imei
        }
      },
    );
  }

  Future<dynamic> getTermDeposits(String imei, String messageId, String cif) async {
    return apiService.makeApiCall(
      _customerGetTermDepositEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': messageId,
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "CUSTOMERTERMDEPOSITS",
          'transactionCode': "CUSTOMERTERMDEPOSITS",
          'hostCode': "MOBILE",
          'cif': cif
        },
        'channelDetails': {
          'host': "IP",
          'geolocation': "1.2921, 36.8219",
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': imei
        }
      },
    );
  }

  Future<dynamic> getTermDepositDetails(String imei, String messageId, String accountNumber) async {
    return apiService.makeApiCall(
      _customerGetTermDepositDetailsEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'header': {
          'messageId': messageId,
          'correlationId': messageId,
        },
        'body': {
          'accountNumber': accountNumber,
        }
      },
    );
  }

  Future<dynamic> createTermDeposit(String imei, String messageId, String debitAccount, String creditAccount, String currency, String termDepositType, String instructions, String phone, double amount) async {
    return apiService.makeApiCall(
      _customerCreateTermDepositEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': messageId,
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "TERMDEPOSIT",
          'transactionCode': "CREATETERMDEPOSIT",
          'hostCode': "MOBILE",
          'cif': debitAccount.substring(3, debitAccount.length - 3),
          'debitAccount': debitAccount,
          'creditAccount': creditAccount,
          'currency': currency,
          'accountClass': termDepositType,
          'maturityInstruction': instructions,
          'phoneNumber': phone,
          'amount': amount,
          'narration': 'TD Instructions',
        },
        'channelDetails': {
          'host': "IP",
          'geolocation': "1.2921, 36.8219",
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': imei
        }
      },
    );
  }

}