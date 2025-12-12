import 'dart:io';

import 'package:bushra_mobile/utils/reference-generator.dart';
import 'package:bushra_mobile/utils/util-api-service.dart';
import 'package:bushra_mobile/utils/util-get-imei.dart';
import 'package:bushra_mobile/utils/util-get-location.dart';

import 'api_module.dart';

class ApiCustomerAccounts {

  final apiService = ApiService();
  final referenceGenerator = ReferenceGenerator();

  static const String _customerAccountBalanceEndpoint = '/bb/mobile/account/balance/1.0.0';
  static const String _customerAccountMiniStatementEndpoint = '/bb/mobile/account/ministatement/1.0.0';
  static const String _customerAccountFullStatementEndpoint = '/bb/mobile/account/fullstatement/1.0.0';
  static const String _customerAccountRecentTransactionEndpoint = '/bb/mobile/account/gettransactions/1.0.0';
  static const String _customerAccounts = '/bb/mobile/account/get/1.0.0';
  static const String _customerDetailsByCif = '/bb/mobile/customer/details/1.0.0';
  static const String _customerDetailsAccount = '/bb/mobile/account/status/1.0.0';

  Future<dynamic> fetchAccountBalance(String accountNumber, String currency) async {
    return apiService.makeApiCall(
      _customerAccountBalanceEndpoint,
      ApiModule.inquiries,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "BALANCEINQUIRY",
          'transactionCode': "BALANCEINQUIRY",
          'hostCode': "MOBILE",
          'debitAccount': accountNumber,
          'creditAccount': null,
          'phoneNumber': null,
          'amount': 0,
          'currency': currency
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

  Future<dynamic> fetchMiniStatements(String accountNumber, String phoneNumber, String currency) async {
    return apiService.makeApiCall(
      _customerAccountMiniStatementEndpoint,
      ApiModule.inquiries,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "MINISTATEMENT",
          'transactionCode': "MINISTATEMENT",
          'hostCode': "MOBILE",
          'debitAccount': accountNumber,
          'creditAccount': null,
          'phoneNumber': phoneNumber,
          'amount': 0,
          'currency': currency
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

  Future<dynamic> fetchMiniRecentStatements(String accountNumber, String phoneNumber, String currency) async {
    return apiService.makeApiCall(
      _customerAccountRecentTransactionEndpoint,
      ApiModule.inquiries,
      method: 'POST',
      body: {
        "txntimestamp": DateTime.now().toUtc().toIso8601String(),
        "xref": referenceGenerator.generateUniqueReference(false),
        "transactionDetails": {
          "direction": "0200",
          "transactionType": "TXNHIST",
          "transactionCode": "TXNHIST",
          "hostCode": "MOBILE",
          "debitAccount": accountNumber,
          "creditAccount": accountNumber,
          "phoneNumber": phoneNumber,
          "amount": 0,
          "currency": "USD"
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

  Future<dynamic> fetchFullStatements(String accountNumber, String phoneNumber, String currency, String fromDate, String toDate, int transactionNo, String email) async {
    return apiService.makeApiCall(
      _customerAccountFullStatementEndpoint,
      ApiModule.inquiries,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "FULLSTATEMENT",
          'transactionCode': "FULLSTATEMENT",
          'hostCode': "MOBILE",
          'debitAccount': accountNumber,
          'creditAccount': null,
          'phoneNumber': phoneNumber,
          'customerEmail': email,
          'amount': 0,
          'currency': currency,
          'fromDate': fromDate,
          'toDate': toDate,
          'noOfTransactions': transactionNo
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

  Future<dynamic> fetchCustomerAccounts(String cif) async {
    return apiService.makeApiCall(
      _customerAccounts,
      ApiModule.inquiries,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "CUSTOMERDETAILS",
          'transactionCode': "CUSTOMERDETAILS",
          'hostCode': "MOBILE",
          'cif': cif
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

  Future<dynamic> customerDetailsByCif(String cif) async {
    return apiService.makeApiCall(
      _customerDetailsByCif,
      ApiModule.inquiries,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "CUSTOMERDETAILS",
          'transactionCode': "CUSTOMERDETAILS",
          'hostCode': "MOBILE",
          'cif': cif,
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

  Future<dynamic> customerAccountStatus(String account) async {
    return apiService.makeApiCall(
      _customerDetailsAccount,
      ApiModule.inquiries,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "CUSTOMERACCOUNTSTATUS",
          'transactionCode': "CUSTOMERACCOUNTSTATUS",
          'hostCode': "MOBILE",
          'accountnumber': account,
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