import 'dart:io';

import 'package:bushra_mobile/utils/reference-generator.dart';
import 'package:bushra_mobile/utils/util-api-service.dart';
import 'package:bushra_mobile/utils/util-get-imei.dart';
import 'package:bushra_mobile/utils/util-get-location.dart';

import 'api_module.dart';

class ApiCustomerLoans{

  static const String _getCustomerLoansEndpoint = '/bb/mobile/loan/getcustomerloans/1.0.0';
  static const String _loanRepaymentEndpoint = '/bb/mobile/loan/payment/1.0.0';
  static const String _loanStatementEndpoint = '/bb/mobile/loan/statement/1.0.0';
  static const String _loanPaymentScheduleEndpoint = '/bb/mobile/loan/repaymentschedule/1.0.0';

  final apiService = ApiService();
  final referenceGenerator = ReferenceGenerator();

  Future<dynamic> getCustomerLoans(String cif) async {
    return apiService.makeApiCall(
      _getCustomerLoansEndpoint,
      ApiModule.loans,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "CUSTOMERLOANS",
          'transactionCode': "CUSTOMERLOANS",
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

  Future<dynamic> loanRepayments(String debitAccount, String creditAccount, String phone, String narration, double amount,String currency) async {
    return apiService.makeApiCall(
      _loanRepaymentEndpoint,
      ApiModule.loans,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "LOAN",
          'transactionCode': "LOANREPAYMENT",
          'hostCode': "MOBILE",
          'debitAccount': debitAccount,
          'creditAccount': creditAccount,
          'phoneNumber': phone,
          'narration': narration,
          'amount': amount,
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

  Future<dynamic> loanStatements(String loanAccount, String startDate, String endDate) async {
    return apiService.makeApiCall(
      _loanStatementEndpoint,
      ApiModule.loans,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "CUSTOMERLOANSTATEMENT",
          'transactionCode': "CUSTOMERLOANSTATEMENT",
          'hostCode': "MOBILE",
          'loanAccount': loanAccount
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

  Future<dynamic> loanPaymentSchedule(String loanAccount) async {
    return apiService.makeApiCall(
      _loanPaymentScheduleEndpoint,
      ApiModule.loans,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "CUSTOMERLOANREPAYMENTSCHEDULE",
          'transactionCode': "CUSTOMERLOANREPAYMENTSCHEDULE",
          'hostCode': "MOBILE",
          'loanAccount': loanAccount, //000MR01221720002
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