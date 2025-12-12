// File: ApiResponseGetTransactionCharges.dart

class ApiResponseGetTransactionCharges {
  final TransactionDetails? transactionDetails;
  final String? xref;
  final TransactionData? data;
  final String? txntimestamp;
  final ChannelDetails? channelDetails;

  ApiResponseGetTransactionCharges({
    this.transactionDetails,
    this.xref,
    this.data,
    this.txntimestamp,
    this.channelDetails,
  });

  factory ApiResponseGetTransactionCharges.fromJson(Map<String, dynamic> json) {
    return ApiResponseGetTransactionCharges(
      transactionDetails: json['transactionDetails'] != null
          ? TransactionDetails.fromJson(json['transactionDetails'])
          : null,
      xref: json['xref'],
      data: json['data'] != null ? TransactionData.fromJson(json['data']) : null,
      txntimestamp: json['txntimestamp'],
      channelDetails: json['channelDetails'] != null
          ? ChannelDetails.fromJson(json['channelDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionDetails': transactionDetails?.toJson(),
      'xref': xref,
      'data': data?.toJson(),
      'txntimestamp': txntimestamp,
      'channelDetails': channelDetails?.toJson(),
    };
  }
}

class TransactionDetails {
  final String? transactionType;
  final double? amount;
  final String? debitAccount;
  final String? creditAccount;
  final String? phoneNumber;
  final String? currency;
  final String? transactionCode;
  final String? hostCode;
  final String? direction;

  TransactionDetails({
    this.transactionType,
    this.amount,
    this.debitAccount,
    this.creditAccount,
    this.phoneNumber,
    this.currency,
    this.transactionCode,
    this.hostCode,
    this.direction,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactionType: json['transactionType'],
      amount: json['amount'],
      debitAccount: json['debitAccount'],
      creditAccount: json['creditAccount'],
      phoneNumber: json['phoneNumber'],
      currency: json['currency'],
      transactionCode: json['transactionCode'],
      hostCode: json['hostCode'],
      direction: json['direction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionType': transactionType,
      'amount': amount,
      'debitAccount': debitAccount,
      'creditAccount': creditAccount,
      'phoneNumber': phoneNumber,
      'currency': currency,
      'transactionCode': transactionCode,
      'hostCode': hostCode,
      'direction': direction,
    };
  }
}

class TransactionData {
  final String? responseCode;
  final String? response;
  final double? chargeAmount;
  final String? transactionCode;

  TransactionData({
    this.responseCode,
    this.response,
    this.chargeAmount,
    this.transactionCode,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      responseCode: json['response_code'],
      response: json['response'],
      chargeAmount: (json['chargeAmount'] != null)
          ? (json['chargeAmount'] as num).toDouble()
          : null,
      transactionCode: json['transactionCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'response': response,
      'chargeAmount': chargeAmount,
      'transactionCode': transactionCode,
    };
  }
}


class ChannelDetails {
  final String? clientId;
  final String? userAgentVersion;
  final String? host;
  final String? channel;
  final String? userAgent;
  final String? deviceId;
  final String? geolocation;

  ChannelDetails({
    this.clientId,
    this.userAgentVersion,
    this.host,
    this.channel,
    this.userAgent,
    this.deviceId,
    this.geolocation,
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

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'userAgentVersion': userAgentVersion,
      'host': host,
      'channel': channel,
      'userAgent': userAgent,
      'deviceId': deviceId,
      'geolocation': geolocation,
    };
  }
}