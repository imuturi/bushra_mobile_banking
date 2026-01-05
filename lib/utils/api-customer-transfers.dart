import 'dart:io';

import 'package:bushra_mobile/utils/reference-generator.dart';
import 'package:bushra_mobile/utils/util-api-service.dart';
import 'package:bushra_mobile/utils/util-get-imei.dart';
import 'package:bushra_mobile/utils/util-get-location.dart';

import 'api_module.dart';

class ApiCustomerFundsTransfers {
  final apiService = ApiService();
  final referenceGenerator = ReferenceGenerator();
  static const String _customerFundsTransferEndpoint = '/bb/mobile/fundstransfer/ift/1.0.0';
  static const String _customerFundsTransferMnoEndpoint = '/bb/mobile/fundstransfer/accounttomno/1.0.0';
  static const String _customerFundsTransferSpsEndpoint = '/bb/mobile/sps/outgoing/ft/1.0.0';
  static const String _customerParticipantsSpsEndpoint = '/bb/sps/getparticipatingbanks/1.0.0';
  static const String _customerFundsTransferBillPaymentsEndpoint = '/bb/mobile/billpayment/1.0.0';
  static const String _customerSpsVerificationEndpoint = '/bb/mobile/sps/outgoing/verification/1.0.0';
  static const String _customerFundsTransferCharges = '/bb/charge/calculate/1.0.0';
  static const String _customerFundsTransferStatus = '/bb/mobile/transaction/querystatus/1.0.0';
  static const String _customerGetRemittanceTypes = '/bb/mobile/get/remittancetypes/1.0.0';
  static const String _customerGetExchangeRates = '/bb/mobile/get/exchagerate/1.0.0';
  static const String _customerRemittanceTransfer = '/bb/mobile/remittance/transfer/1.0.0';

  Future<dynamic> getRemittanceTypes() async {
    return apiService.makeApiCall(
      _customerGetRemittanceTypes,
      ApiModule.fundsTransfer,
      method: 'GET',
      body: {},
    );
  }

  Future<dynamic> getRemittanceExchangeRates(String drAccount, String fromCurrency, String toCurrency, double amount, String phone) async {
    return apiService.makeApiCall(
      _customerGetExchangeRates,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          "direction": "0200",
          "transactionType": "REMIITANCE",
          "transactionCode": "REMIITANCE_RATE",
          "hostCode": "MOBILE",
          "debitAccount": drAccount,
          "creditAccount": phone,
          "phoneNumber": phone,
          "fromCurrency": fromCurrency,
          "toCurrency": toCurrency,
          "amount": amount,
          "currency": fromCurrency

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

  Future<dynamic> fundsTransferRemittance(
      String messageId,
      String drAccount,
      String drAccCurrency,
      String crAccount,
      String phoneNumber,
      String fromCurrency,
      String toCurrency,
      double amount,
      double convertedAmount,
      String fcmToken, {
        // 👇 pass extra transaction-related parameters as optional named args
        required String destinationChannelCode,
        required String destinationChannelName,
        required String receiverPhoneNumber,
        required String receiverAccountName,
        required String senderName,
        required String senderDOB,
        required String senderCountryISO,
        required String senderNationality,
        required String senderIDType,
        required String senderIDNumber,
        required String narration,
      }) async {
    return apiService.makeApiCall(
      _customerRemittanceTransfer,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': messageId,
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "REMIITANCE",
          'transactionCode': "REMIITANCE_TRANSFER",
          'hostCode': "MOBILE",
          'debitAccount': drAccount,
          'creditAccount': crAccount,
          'phoneNumber': phoneNumber,
          "fromCurrency": fromCurrency,
          "toCurrency": toCurrency,
          "amount": amount,
          "convertedAmount": convertedAmount,
          "currency": toCurrency,
          "destinationChannelCode": destinationChannelCode,
          "destinationChannelName": destinationChannelName,
          "receiverPhoneNumber": receiverPhoneNumber,
          "receiverAccountName": receiverAccountName,
          "senderName": senderName,
          "senderDOB": senderDOB,
          "senderCountryISO": senderCountryISO,
          "senderNationality": senderNationality,
          "senderIDType": senderIDType,
          "senderIDNumber": senderIDNumber,
          "narration": narration,
        },
        'channelDetails': {
          'host': await DeviceLocation.getLocalIpAddress(),
          'geolocation': "1.2921, 36.8219", // you can replace with real GPS
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': await DeviceIdentifier.getDeviceIdentifier(),
          'fcmToken': fcmToken,
        },
      },
    );
  }


  Future<dynamic> fundsTransferStatus(String transactionReference, String transactionCode) async {
    return apiService.makeApiCall(
      _customerFundsTransferStatus,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "TRANSACTIONSTATUS",
          'transactionCode': transactionCode,
          'hostCode': "MOBILE",
          'transactionRef': transactionReference
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

  Future<dynamic> fundsTransfer(String messageId, String drAccount, String crAccount, String phoneNumber, String currency, String narration, double amount, String fcmToken) async {
    return apiService.makeApiCall(
      _customerFundsTransferEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': messageId,
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "FUNDSTRANSFER",
          'transactionCode': "INTERNALFUNDSTRANSFER",
          'hostCode': "MOBILE",
          'debitAccount': drAccount,
          'creditAccount': crAccount,
          'phoneNumber': phoneNumber,
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
          'fcmToken': fcmToken,
        }
      },
    );
  }

  Future<dynamic> fundsTransferMno(String messageId, String drAccount, String phoneNumber, String currency, String narration, double amount, String telco, String fcmToken) async {
    return apiService.makeApiCall(
      _customerFundsTransferMnoEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': messageId,
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "FUNDSTRANSFER",
          'transactionCode': "ACOOUNTTOMNOTRANSFER",
          'hostCode': "MOBILE",
          'debitAccount': drAccount,
          'creditAccount': phoneNumber,
          'phoneNumber': phoneNumber,
          'narration': narration,
          'telco': telco,
          'amount': amount,
          'currency': currency,
        },
        'channelDetails': {
          'host': await DeviceLocation.getLocalIpAddress(),
          'geolocation': "1.2921, 36.8219",//await DeviceLocation.getDeviceLocation(),
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': await DeviceIdentifier.getDeviceIdentifier(),
          'fcmToken': fcmToken,
        }
      },
    );
  }

  Future<dynamic> fundsTransferSps(String messageId, String drAccount, String crAccount, String phoneNumber, String currency, String narration, double amount, String beneficiaryBankCode, String fcmToken, String transferType,String debtorsName, String creditorsName) async {
    return apiService.makeApiCall(
      _customerFundsTransferSpsEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': messageId,
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "SPSOUTGOINGTRANSFER",
          'transactionCode': "SPSOUTGOINGTRANSFER",
          'hostCode': "MOBILE",
          'transferType': transferType,
          'debitAccount': drAccount,
          'creditAccount': crAccount,
          'phoneNumber': phoneNumber,
          'narration': narration,
          'amount': amount,
          'currency': currency,
          'beneficiaryBankCode': beneficiaryBankCode,
          'debtorsName': debtorsName,
          'creditorsName': creditorsName
        },
        'channelDetails': {
          'host': await DeviceLocation.getLocalIpAddress(),
          'geolocation': "1.2921, 36.8219",//await DeviceLocation.getDeviceLocation(),
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': await DeviceIdentifier.getDeviceIdentifier(),
          'fcmToken': fcmToken,
        }
      },
    );
  }

  Future<dynamic> getSpsParticipantBanks() async {
    return apiService.makeApiCall(
      _customerParticipantsSpsEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {},
    );
  }

  Future<dynamic> getSpsBeneficiaryName(
      String beneficiaryBankCode,
      String drAccount,
      String crAccount,
      String phoneNumber,
      ) async {
    return apiService.makeApiCall(
      _customerSpsVerificationEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(true),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "SPSVERIFICATION",
          'transactionCode': "SPSVERIFICATION",
          'hostCode': "MOBILE",
          'debitAccount': drAccount,
          'creditAccount': crAccount,
          'phoneNumber': phoneNumber,
          'beneficiaryBankCode': beneficiaryBankCode,

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

  /// Funds Transfer Bill Payments
  Future<dynamic> fundsTransferBillPayments(
      String messageId,
      String billPaymentType,
      String billerCategory,
      String billerId,
      String drAccount,
      String crAccount,
      String phoneNumber,
      String currency,
      String narration,
      double amount,
      String billerCommonField,
      String fcmToken) async {
    return apiService.makeApiCall(
      _customerFundsTransferBillPaymentsEndpoint,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': messageId,
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "BILLPAYMENTS",
          'transactionCode': "BILLPAYMENTS$billerCategory$billerId", //APPEND CATEGORY AND BILLERID
          'hostCode': "MOBILE",
          'debitAccount': drAccount,
          'creditAccount': crAccount,
          'phoneNumber': phoneNumber,
          'billNumber': billerCommonField,
          'narration': narration,
          'currency': currency,
          'amount': amount,
        },
        'channelDetails': {
          'host': await DeviceLocation.getLocalIpAddress(),
          'geolocation': "1.2921, 36.8219",//await DeviceLocation.getDeviceLocation(),
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': await DeviceIdentifier.getDeviceIdentifier(),
          'fcmToken': fcmToken,
        }
      },
    );
  }

  Future<dynamic> transactionCharges(String drAccount, String crAccount,
      String phoneNumber, String currency, double amount,) async {
    return apiService.makeApiCall(
      _customerFundsTransferCharges,
      ApiModule.fundsTransfer,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "BALANCEINQUIRY",
          'transactionCode': "BALANCEINQUIRY",
          'hostCode': "MOBILE",
          'debitAccount': drAccount,
          'creditAccount': crAccount,
          'phoneNumber': phoneNumber,
          'amount': amount,
          'currency': currency,
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