class AccountStatusResponse {
  final TransactionDetails? transactionDetails;
  final String xref;
  final ResponseData data;
  final DateTime? txntimestamp;
  final ChannelDetails? channelDetails;

  AccountStatusResponse({
    this.transactionDetails,
    required this.xref,
    required this.data,
    this.txntimestamp,
    this.channelDetails,
  });

  factory AccountStatusResponse.fromJson(Map<String, dynamic> json) {
    return AccountStatusResponse(
      transactionDetails: json['transactionDetails'] != null
          ? TransactionDetails.fromJson(json['transactionDetails'])
          : null,
      xref: json['xref'] as String,
      data: ResponseData.fromJson(json['data']),
      txntimestamp: json['txntimestamp'] != null
          ? DateTime.tryParse(json['txntimestamp'])
          : null,
      channelDetails: json['channelDetails'] != null
          ? ChannelDetails.fromJson(json['channelDetails'])
          : null,
    );
  }
}

// class AccountStatusResponse {
//   final TransactionDetails transactionDetails;
//   final String xref;
//   final ResponseData data;
//   final DateTime txntimestamp;
//   final ChannelDetails channelDetails;
//
//   AccountStatusResponse({
//     required this.transactionDetails,
//     required this.xref,
//     required this.data,
//     required this.txntimestamp,
//     required this.channelDetails,
//   });
//
//   factory AccountStatusResponse.fromJson(Map<String, dynamic> json) {
//     return AccountStatusResponse(
//       transactionDetails: TransactionDetails.fromJson(json['transactionDetails']),
//       xref: json['xref'] as String,
//       data: ResponseData.fromJson(json['data']),
//       txntimestamp: DateTime.parse(json['txntimestamp'] as String),
//       channelDetails: ChannelDetails.fromJson(json['channelDetails']),
//     );
//   }
// }

class TransactionDetails {
  final String transactionType;
  final String accountNumber;
  final String transactionCode;
  final String hostCode;
  final String direction;

  TransactionDetails({
    required this.transactionType,
    required this.accountNumber,
    required this.transactionCode,
    required this.hostCode,
    required this.direction,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactionType: json['transactionType'] as String,
      accountNumber: json['accountnumber'] as String, // Note: lowercase 'n' in JSON
      transactionCode: json['transactionCode'] as String,
      hostCode: json['hostCode'] as String,
      direction: json['direction'] as String,
    );
  }
}

class ResponseData {
  final String responseCode;
  final String response;
  final AccountStatus? accountStatus;
  final String? errorData;

  ResponseData({
    required this.responseCode,
    required this.response,
    this.accountStatus,
    this.errorData,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      responseCode: json['response_code'] as String,
      response: json['response'] as String,
      accountStatus: json['account_status'] != null
          ? AccountStatus.fromJson(json['account_status'])
          : null,
      errorData: json['error_data'] as String?,
    );
  }
}


// class ResponseData {
//   final String responseCode;
//   final String response;
//   final AccountStatus accountStatus;
//
//   ResponseData({
//     required this.responseCode,
//     required this.response,
//     required this.accountStatus,
//   });
//
//   factory ResponseData.fromJson(Map<String, dynamic> json) {
//     return ResponseData(
//       responseCode: json['response_code'] as String,
//       response: json['response'] as String,
//       accountStatus: AccountStatus.fromJson(json['account_status']),
//     );
//   }
// }

class AccountStatus {
  final String address1;
  final String address2;
  final String address3;
  final String accountName;
  final String accountNumber;
  final String accountStatus;
  final String accountType;
  final String atmStatus;
  final String cbsReference;
  final String chequeBookStatus;
  final String currency;
  final String customerNumber;
  final String dormantStatus;
  final String frozenStatus;
  final String ibanAccountNumber;
  final String noCreditStatus;
  final String noDebitStatus;
  final String opennedDate;
  final String passBookStatus;
  final String postAllowedStatus;
  final String stPayStatus;

  AccountStatus({
    required this.address1,
    required this.address2,
    required this.address3,
    required this.accountName,
    required this.accountNumber,
    required this.accountStatus,
    required this.accountType,
    required this.atmStatus,
    required this.cbsReference,
    required this.chequeBookStatus,
    required this.currency,
    required this.customerNumber,
    required this.dormantStatus,
    required this.frozenStatus,
    required this.ibanAccountNumber,
    required this.noCreditStatus,
    required this.noDebitStatus,
    required this.opennedDate,
    required this.passBookStatus,
    required this.postAllowedStatus,
    required this.stPayStatus,
  });

  factory AccountStatus.fromJson(Map<String, dynamic> json) {
    return AccountStatus(
      address1: json['address1'] as String,
      address2: json['address2'] as String,
      address3: json['address3'] as String,
      accountName: json['accountName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountStatus: json['accountStatus'] as String,
      accountType: json['accountType'] as String,
      atmStatus: json['atmStatus'] as String,
      cbsReference: json['cbsReference'] as String,
      chequeBookStatus: json['chequeBookStatus'] as String,
      currency: json['currency'] as String,
      customerNumber: json['customerNumber'] as String,
      dormantStatus: json['dormantStatus'] as String,
      frozenStatus: json['frozenStatus'] as String,
      ibanAccountNumber: json['ibanAccountNumber'] as String,
      noCreditStatus: json['noCreditStatus'] as String,
      noDebitStatus: json['noDebitStatus'] as String,
      opennedDate: json['opennedDate'] as String,
      passBookStatus: json['passBookStatus'] as String,
      postAllowedStatus: json['postAllowedStatus'] as String,
      stPayStatus: json['stPayStatus'] as String,
    );
  }
}

class ChannelDetails {
  final String clientId;
  final String channel;
  final String host;
  final String userAgent;
  final String userAgentVersion;
  final String deviceId;
  final String geolocation;

  ChannelDetails({
    required this.clientId,
    required this.channel,
    required this.host,
    required this.userAgent,
    required this.userAgentVersion,
    required this.deviceId,
    required this.geolocation,
  });

  factory ChannelDetails.fromJson(Map<String, dynamic> json) {
    return ChannelDetails(
      clientId: json['clientId'] as String,
      channel: json['channel'] as String,
      host: json['host'] as String,
      userAgent: json['userAgent'] as String,
      userAgentVersion: json['userAgentVersion'] as String,
      deviceId: json['deviceId'] as String,
      geolocation: json['geolocation'] as String,
    );
  }
}