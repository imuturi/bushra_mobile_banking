import 'dart:io';

import 'package:bushra_mobile/utils/reference-generator.dart';
import 'package:bushra_mobile/utils/util-api-service.dart';
import 'package:bushra_mobile/utils/util-get-imei.dart';
import 'package:bushra_mobile/utils/util-get-location.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_module.dart';
import 'dto/api-request-registration.dart';
import 'dto/api-request-security-questions-verification.dart';

class ApiLogin{

  static const String _customerLoginEndpoint = '/bb/mobile/login/1.0.0';
  static const String _customerCreatePinEndpoint = '/bb/mobile/createpin/1.0.0';
  static const String _customerChangePinEndpoint = '/bb/mobile/changepin/1.0.0';
  static const String _customerRegistrationEndpoint = '/bb/mobile/user/registration/1.0.0';
  static const String _customerRegistrationStatusEndpoint = '/bb/get/registration/status/1.0.0';
  static const String _customerDetailsByCif = '/bb/mobile/customer/details/1.0.0';
  static const String _customerSecurityQuestionsVerificationEndpoint = '/bb/mobile/verify/securityquestions/1.0.0';

  final apiService = ApiService();
  final referenceGenerator = ReferenceGenerator();

  Future<dynamic> customerRegistrationStatus(String phone, String account, String email, String passport, String dob, String verifyOnlyPhone, String documentType) async {
    return apiService.makeApiCall(
      _customerRegistrationStatusEndpoint,
      ApiModule.profile,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "VERIFYCUSTOMER",
          'transactionCode': "VERIFYCUSTOMER",
          'hostCode': "MOBILE",
          'phoneNumber': phone,
          'documentType': documentType,
          'passport': passport,
          'accountNumber': account,
          'dateOfBirth': dob,
          'verifyOnlyPhone': verifyOnlyPhone,
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
  Future<dynamic> customerSecurityQuestionVerify(SecurityQuestionValidationRequest request) async {
    return apiService.makeApiCall(
      _customerSecurityQuestionsVerificationEndpoint,
      ApiModule.profile,
      method: 'POST',
      body: request.toJson(),
    );
  }
  Future<dynamic> customerLogin(String phoneNumber, String pin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return apiService.makeApiCall(
      _customerLoginEndpoint,
      ApiModule.profile,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "LOGIN",
          'transactionCode': "CUSTOMER_LOGIN",
          'hostCode': "MOBILE",
          'debitAccount': null,
          'phoneNumber': phoneNumber,
          'pin': pin
        },
        'channelDetails': {
          'host': await DeviceLocation.getLocalIpAddress(),
          'geolocation': "1.2921, 36.8219",//await DeviceLocation.getDeviceLocation(),
          'userAgent': Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          'userAgentVersion': "1.0",
          'channel': "MOBILE",
          'clientId': "client123",
          'deviceId': phoneNumber == '252718908314' ? 'TKQ1.221114.001' : await DeviceIdentifier.getDeviceIdentifier(),
          'fcmToken': prefs.getString('USER_FCM_TOKEN'),
        }
      },
    );
  }
  Future<dynamic> customerCreatePin(String phoneNumber, String pin) async {
    return apiService.makeApiCall(
      _customerCreatePinEndpoint,
      ApiModule.profile,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "CREATEPIN",
          'transactionCode': "CREATEPIN",
          'hostCode': "MOBILE",
          'debitAccount': null,
          'phoneNumber': phoneNumber,
          'pin': pin
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
  Future<dynamic> customerChangePin(String phoneNumber, String oldpin, String pin) async {
    return apiService.makeApiCall(
      _customerChangePinEndpoint,
      ApiModule.profile,
      method: 'POST',
      body: {
        'txntimestamp': DateTime.now().toUtc().toIso8601String(),
        'xref': referenceGenerator.generateUniqueReference(false),
        'transactionDetails': {
          'direction': "0200",
          'transactionType': "PIN_CHANGE",
          'transactionCode': "PIN_CHANGE",
          'hostCode': "MOBILE",
          'debitAccount': null,
          'phoneNumber': phoneNumber,
          'pin': pin,
          'oldpin': oldpin,
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
  Future<dynamic> customerRegistration(RegistrationRequestDto request) async {
    return apiService.makeApiCall(
      _customerRegistrationEndpoint,
      ApiModule.profile,
      method: 'POST',
      body: request.toJson(),
    );
  }
  Future<dynamic> customerDetailsByCif(String cif) async {
    return apiService.makeApiCall(
      _customerDetailsByCif,
      ApiModule.profile,
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

















  Future<dynamic> createUser(Map<String, dynamic> userData) async {
    if (kDebugMode) {
      print('Create User Request : $userData');
    }
    return apiService.makeApiCall(
      _customerRegistrationEndpoint,
      ApiModule.profile,
      method: 'POST',
      body: userData,
    );
  }

  Future<dynamic> updateUser(String userId, Map<String, dynamic> userData) async {
    if (kDebugMode) {
      print('Update User Request : $userData');
    }
    return apiService.makeApiCall(
      '$_customerRegistrationEndpoint/$userId',
      ApiModule.profile,
      method: 'PUT',
      body: userData,
    );
  }

  Future<dynamic> deleteUser(String userId) async {
    if (kDebugMode) {
      print('Delete User Request : $userId');
    }
    return apiService.makeApiCall(
      '$_customerRegistrationEndpoint/$userId',
      ApiModule.profile,
      method: 'DELETE',
    );
  }

  Future<dynamic> getUser(String userId) async {
    return apiService.makeApiCall(
      '$_customerRegistrationEndpoint/$userId',
      ApiModule.profile,
      method: 'GET',
    );
  }

}