import 'dart:io';

import 'package:flutter/material.dart';

import '../dto/api-request-registration.dart';
import '../reference-generator.dart';
import '../util-get-imei.dart';
class RegistrationData extends ChangeNotifier {
  // Screen 1 Data
  String? debitAccount;
  String? phoneNumber;
  String? accountNumber;
  String? firstName;
  String? lastName;
  String? middleName;
  String? passportNumber;
  String? gender;
  String? dateOfBirth;
  String? email;
  String? documentType;

  // Screen 2 Data
  String? question1;
  String? answer1;
  String? question2;
  String? answer2;
  String? question3;
  String? answer3;

  // Screen 3 Data
  String? pin;

  void updateScreen1Data({
    required String debitAccount,
    required String phoneNumber,
    required String accountNumber,
    required String firstName,
    required String lastName,
    required String middleName,
    required String passportNumber,
    required String gender,
    required String dateOfBirth,
    required String email,
    required String documentType,
  }) {
    this.debitAccount = debitAccount;
    this.phoneNumber = phoneNumber;
    this.accountNumber = accountNumber;
    this.firstName = firstName;
    this.lastName = lastName;
    this.middleName = middleName;
    this.passportNumber = passportNumber;
    this.gender = gender;
    this.dateOfBirth = dateOfBirth;
    this.email = email;
    this.documentType = documentType;
    notifyListeners();
  }

  void updateScreen2Data({
    required String question1,
    required String answer1,
    required String question2,
    required String answer2,
    required String question3,
    required String answer3,
  }) {
    this.question1 = question1;
    this.answer1 = answer1;
    this.question2 = question2;
    this.answer2 = answer2;
    this.question3 = question3;
    this.answer3 = answer3;
    notifyListeners();
  }

  void updateScreen3Data({
    required String pin,
  }) {
    this.pin = pin;
    notifyListeners();
  }

  //TODO DTO
  final referenceGenerator = ReferenceGenerator();
  Future<RegistrationRequestDto> toDto() async {
    String deviceId = await DeviceIdentifier.getDeviceIdentifier();
    return RegistrationRequestDto(
      txntimestamp: DateTime.now().toUtc().toIso8601String(),
      xref: referenceGenerator.generateUniqueReference(false),
      transactionDetails: TransactionDetails(
        direction: "0200",
        transactionType: "REGISTRATION",
        transactionCode: "CUSTOMER_REG",
        hostCode: "MOBILE",
        debitAccount: debitAccount!,
        phoneNumber: phoneNumber!,
        accountNumber: accountNumber!,
        firstName: firstName!,
        lastName: lastName!,
        middleName: middleName!,
        passportNumber: passportNumber!,
        pin: pin!,
        email: email!,
        documentType: documentType!,
        securityQuestions: [
          SecurityQuestion(
            questionsAsked1: question1!,
            questionsAnswered1: answer1!,
            questionsAsked2: question2,
            questionsAnswered2: answer2,
            questionsAsked3: question3,
            questionsAnswered3: answer3,
          ),
        ],
      ),
      channelDetails: ChannelDetails(
        host: "IP",
        geolocation: "1.2921, 36.8219",
        userAgent: Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
        userAgentVersion: "1.0",
        channel: "MOBILE",
        clientId: "client123",
        deviceId: deviceId,
      ),
    );
  }

}