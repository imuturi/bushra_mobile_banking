class CustomerDetailsResponse {
  final TransactionDetails transactionDetails;
  final String xref;
  final CustomerData data;
  final DateTime txntimestamp;
  final ChannelDetails channelDetails;

  CustomerDetailsResponse({
    required this.transactionDetails,
    required this.xref,
    required this.data,
    required this.txntimestamp,
    required this.channelDetails,
  });

  factory CustomerDetailsResponse.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsResponse(
      transactionDetails: TransactionDetails.fromJson(json['transactionDetails']),
      xref: json['xref'],
      data: CustomerData.fromJson(json['data']),
      txntimestamp: DateTime.parse(json['txntimestamp']),
      channelDetails: ChannelDetails.fromJson(json['channelDetails']),
    );
  }
}

class TransactionDetails {
  final String transactionType;
  final String cif;
  final String transactionCode;
  final String hostCode;
  final String direction;

  TransactionDetails({
    required this.transactionType,
    required this.cif,
    required this.transactionCode,
    required this.hostCode,
    required this.direction,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactionType: json['transactionType'],
      cif: json['cif'],
      transactionCode: json['transactionCode'],
      hostCode: json['hostCode'],
      direction: json['direction'],
    );
  }
}

class CustomerData {
  final CustomerDetails customerDetails;
  final String responseCode;
  final String response;

  CustomerData({
    required this.customerDetails,
    required this.responseCode,
    required this.response,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      customerDetails: CustomerDetails.fromJson(json['customer_details']),
      responseCode: json['response_code'],
      response: json['response'],
    );
  }
}

class CustomerDetails {
  final List<Account> account;

  CustomerDetails({required this.account});

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    var list = json['account'] as List? ?? [];
    List<Account> accountList = list.map((e) => Account.fromJson(e)).toList();
    return CustomerDetails(account: accountList);
  }
}

class Account {
  final String passportNumber;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String gender;
  final String address1;
  final String address2;
  final String address3;
  final String middleName;
  final DateTime dateOfBirth;
  final String customerNumber;
  final String email;

  Account({
    required this.passportNumber,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.gender,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.middleName,
    required this.dateOfBirth,
    required this.customerNumber,
    required this.email,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      passportNumber: json['passportNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      address1: json['address1'],
      address2: json['address2'],
      address3: json['address3'],
      middleName: json['middleName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      customerNumber: json['customerNumber'],
      email: json['email'],
    );
  }
}

class ChannelDetails {
  final String clientId;
  final String userAgentVersion;
  final String host;
  final String channel;
  final String userAgent;
  final String deviceId;
  final String geolocation;

  ChannelDetails({
    required this.clientId,
    required this.userAgentVersion,
    required this.host,
    required this.channel,
    required this.userAgent,
    required this.deviceId,
    required this.geolocation,
  });

  factory ChannelDetails.fromJson(Map<String, dynamic> json) {
    return ChannelDetails(
      clientId: json['clientId'],
      userAgentVersion: json['userAgentVersion'],
      host: json['host'],
      channel: json['channel'],
      userAgent: json['userAgent'],
      deviceId: json['deviceId'],
      geolocation: json['geolocation'],
    );
  }
}
