class ApiResponseCustomerDetails {
  final TransactionDetails transactionDetails;
  final String xref;
  final Data data;
  final String txntimestamp;
  final ChannelDetails channelDetails;

  ApiResponseCustomerDetails({
    required this.transactionDetails,
    required this.xref,
    required this.data,
    required this.txntimestamp,
    required this.channelDetails,
  });

  factory ApiResponseCustomerDetails.fromJson(Map<String, dynamic> json) {
    return ApiResponseCustomerDetails(
      transactionDetails: TransactionDetails.fromJson(json['transactionDetails']),
      xref: json['xref'],
      data: Data.fromJson(json['data']),
      txntimestamp: json['txntimestamp'],
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

class Data {
  final CustomerDetails customerDetails;
  final String responseCode;
  final String response;

  Data({
    required this.customerDetails,
    required this.responseCode,
    required this.response,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      customerDetails: CustomerDetails.fromJson(json['customer_details']),
      responseCode: json['response_code'],
      response: json['response'],
    );
  }
}

class CustomerDetails {
  final Account? account;

  CustomerDetails({this.account}); // Allow null values
  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('account') || json['account'] == null) {
      return CustomerDetails(account: null); // Handle missing or null "account"
    }
    var accountData = json['account'];
    Account? account;

    if (accountData is List && accountData.isNotEmpty) {
      account = Account.fromJson(accountData.first); // Extract first item if it's a list
    } else if (accountData is Map<String, dynamic>) {
      account = Account.fromJson(accountData); // Directly convert if it's a map
    }
    return CustomerDetails(account: account);
  }
}

class Account {
  final String passportNumber;
  final String? nationalId;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String gender;
  final String? address1;
  final String? address2;
  final String? address3;
  final String middleName;
  final String? dateOfBirth;
  final int customerNumber;
  final String? email;

  Account({
    required this.passportNumber,
    this.nationalId,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.gender,
    this.address1,
    this.address2,
    this.address3,
    required this.middleName,
    this.dateOfBirth,
    required this.customerNumber,
    this.email,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      passportNumber: json['passportNumber'],
      nationalId: _parseNullableString(json['nationalId']),
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: _parseNullableString(json['phoneNumber']),
      gender: json['gender'],
      address1: _parseNullableString(json['address1']),
      address2: _parseNullableString(json['address2']),
      address3: _parseNullableString(json['address3']),
      middleName: json['middleName'],
      dateOfBirth: _parseNullableString(json['dateOfBirth']),
      customerNumber: int.tryParse(json['customerNumber'].toString()) ?? 0,
      email: _parseNullableString(json['email']),
    );
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isEmpty) return null;
    if (value is Map<String, dynamic> && value["@nil"] == "true") return null;
    return value.toString();
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
