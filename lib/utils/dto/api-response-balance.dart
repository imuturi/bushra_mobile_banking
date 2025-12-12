class TransactionResponse {
  final TransactionDetails transactionDetails;
  final String xref;
  final TransactionData data;
  final String txntimestamp;
  final ChannelDetails channelDetails;

  TransactionResponse({
    required this.transactionDetails,
    required this.xref,
    required this.data,
    required this.txntimestamp,
    required this.channelDetails,
  });

  // Convert JSON to Dart object
  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactionDetails: TransactionDetails.fromJson(json['transactionDetails']),
      xref: json['xref'],
      data: TransactionData.fromJson(json['data']),
      txntimestamp: json['txntimestamp'],
      channelDetails: ChannelDetails.fromJson(json['channelDetails']),
    );
  }

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'transactionDetails': transactionDetails.toJson(),
      'xref': xref,
      'data': data.toJson(),
      'txntimestamp': txntimestamp,
      'channelDetails': channelDetails.toJson(),
    };
  }
}

class TransactionDetails {
  final String transactionType;
  final double amount;
  final String debitAccount;
  final String? creditAccount;
  final String phoneNumber;
  final String currency;
  final String transactionCode;
  final String hostCode;
  final String direction;

  TransactionDetails({
    required this.transactionType,
    required this.amount,
    required this.debitAccount,
    this.creditAccount,
    required this.phoneNumber,
    required this.currency,
    required this.transactionCode,
    required this.hostCode,
    required this.direction,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactionType: json['transactionType'],
      amount: (json['amount'] as num).toDouble(),
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
  final String responseCode;
  final String response;
  final double currentBalance;
  final double netBalance;
  final double availableBalance;

  TransactionData({
    required this.responseCode,
    required this.response,
    required this.currentBalance,
    required this.netBalance,
    required this.availableBalance,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      responseCode: json['response_code'],
      response: json['response'],
      currentBalance: (json['currentBalance'] as num).toDouble(),
      netBalance: (json['netBalance'] as num).toDouble(),
      availableBalance: (json['availableBalance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_code': responseCode,
      'response': response,
      'currentBalance': currentBalance,
      'netBalance': netBalance,
      'availableBalance': availableBalance,
    };
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