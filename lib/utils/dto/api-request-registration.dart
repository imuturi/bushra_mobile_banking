class RegistrationRequestDto {
  final String txntimestamp;
  final String xref;
  final TransactionDetails transactionDetails;
  final ChannelDetails channelDetails;

  RegistrationRequestDto({
    required this.txntimestamp,
    required this.xref,
    required this.transactionDetails,
    required this.channelDetails,
  });

  factory RegistrationRequestDto.fromJson(Map<String, dynamic> json) {
    return RegistrationRequestDto(
      txntimestamp: json['txntimestamp'],
      xref: json['xref'],
      transactionDetails: TransactionDetails.fromJson(json['transactionDetails']),
      channelDetails: ChannelDetails.fromJson(json['channelDetails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txntimestamp': txntimestamp,
      'xref': xref,
      'transactionDetails': transactionDetails.toJson(),
      'channelDetails': channelDetails.toJson(),
    };
  }
}

class TransactionDetails {
  final String direction;
  final String transactionType;
  final String transactionCode;
  final String hostCode;
  final String debitAccount;
  final String phoneNumber;
  final String accountNumber;
  final String firstName;
  final String lastName;
  final String middleName;
  final String passportNumber;
  final String pin;
  final String email;
  final String documentType;
  final List<SecurityQuestion> securityQuestions;

  TransactionDetails({
    required this.direction,
    required this.transactionType,
    required this.transactionCode,
    required this.hostCode,
    required this.debitAccount,
    required this.phoneNumber,
    required this.accountNumber,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.passportNumber,
    required this.pin,
    required this.email,
    required this.documentType,
    required this.securityQuestions,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      direction: json['direction'],
      transactionType: json['transactionType'],
      transactionCode: json['transactionCode'],
      hostCode: json['hostCode'],
      debitAccount: json['debitAccount'],
      phoneNumber: json['phoneNumber'],
      accountNumber: json['accountNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      passportNumber: json['passportNumber'],
      pin: json['pin'],
      email: json['email'],
      documentType: json['documentType'],
      securityQuestions: List<SecurityQuestion>.from(
          json['securityQuestions'].map((x) => SecurityQuestion.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'transactionType': transactionType,
      'transactionCode': transactionCode,
      'hostCode': hostCode,
      'debitAccount': debitAccount,
      'phoneNumber': phoneNumber,
      'accountNumber': accountNumber,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'passportNumber': passportNumber,
      'pin': pin,
      'email': email,
      'documentType': documentType,
      'securityQuestions':
      securityQuestions.map((question) => question.toJson()).toList(),
    };
  }
}

class SecurityQuestion {
  final String questionsAsked1;
  final String questionsAnswered1;
  final String? questionsAsked2;
  final String? questionsAnswered2;
  final String? questionsAsked3;
  final String? questionsAnswered3;

  SecurityQuestion({
    required this.questionsAsked1,
    required this.questionsAnswered1,
    this.questionsAsked2,
    this.questionsAnswered2,
    this.questionsAsked3,
    this.questionsAnswered3,
  });

  factory SecurityQuestion.fromJson(Map<String, dynamic> json) {
    return SecurityQuestion(
      questionsAsked1: json['questionsAsked1'],
      questionsAnswered1: json['questionsAnswered1'],
      questionsAsked2: json['questionsAsked2'],
      questionsAnswered2: json['questionsAnswered2'],
      questionsAsked3: json['questionsAsked3'],
      questionsAnswered3: json['questionsAnswered3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionsAsked1': questionsAsked1,
      'questionsAnswered1': questionsAnswered1,
      if (questionsAsked2 != null) 'questionsAsked2': questionsAsked2,
      if (questionsAnswered2 != null) 'questionsAnswered2': questionsAnswered2,
      if (questionsAsked3 != null) 'questionsAsked3': questionsAsked3,
      if (questionsAnswered3 != null) 'questionsAnswered3': questionsAnswered3,
    };
  }
}

class ChannelDetails {
  final String host;
  final String geolocation;
  final String userAgent;
  final String userAgentVersion;
  final String channel;
  final String clientId;
  final String deviceId;

  ChannelDetails({
    required this.host,
    required this.geolocation,
    required this.userAgent,
    required this.userAgentVersion,
    required this.channel,
    required this.clientId,
    required this.deviceId,
  });

  factory ChannelDetails.fromJson(Map<String, dynamic> json) {
    return ChannelDetails(
      host: json['host'],
      geolocation: json['geolocation'],
      userAgent: json['userAgent'],
      userAgentVersion: json['userAgentVersion'],
      channel: json['channel'],
      clientId: json['clientId'],
      deviceId: json['deviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'geolocation': geolocation,
      'userAgent': userAgent,
      'userAgentVersion': userAgentVersion,
      'channel': channel,
      'clientId': clientId,
      'deviceId': deviceId,
    };
  }
}