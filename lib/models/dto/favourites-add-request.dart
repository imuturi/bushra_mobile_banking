class TransactionRequest {
  final String xref;
  final String txntimestamp;
  final TransactionDetails transactionDetails;
  final ChannelDetails channelDetails;

  TransactionRequest({
    required this.xref,
    required this.txntimestamp,
    required this.transactionDetails,
    required this.channelDetails,
  });

  factory TransactionRequest.fromJson(Map<String, dynamic> json) {
    return TransactionRequest(
      xref: json['xref'] ?? '',
      txntimestamp: json['txntimestamp'] ?? '',
      transactionDetails: TransactionDetails.fromJson(json['transactionDetails'] ?? {}),
      channelDetails: ChannelDetails.fromJson(json['channelDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xref': xref,
      'txntimestamp': txntimestamp,
      'transactionDetails': transactionDetails.toJson(),
      'channelDetails': channelDetails.toJson(),
    };
  }
}

class TransactionDetails {
  final String phoneNumber;
  final List<Favourite> favourites;

  TransactionDetails({
    required this.phoneNumber,
    required this.favourites,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      phoneNumber: json['phoneNumber'] ?? '',
      favourites: (json['favourites'] as List<dynamic>? ?? [])
          .map((item) => Favourite.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'favourites': favourites.map((f) => f.toJson()).toList(),
    };
  }
}

class Favourite {
  final List<Beneficiary>? ift;
  final List<Beneficiary>? billpayment;
  final List<Beneficiary>? sps;

  Favourite({this.ift, this.billpayment, this.sps});

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      ift: (json['ift'] as List<dynamic>?)
          ?.map((item) => Beneficiary.fromJson(item))
          .toList(),
      billpayment: (json['billpayment'] as List<dynamic>?)
          ?.map((item) => Beneficiary.fromJson(item))
          .toList(),
      sps: (json['sps'] as List<dynamic>?)
          ?.map((item) => Beneficiary.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (ift != null) map['ift'] = ift!.map((b) => b.toJson()).toList();
    if (billpayment != null) map['billpayment'] = billpayment!.map((b) => b.toJson()).toList();
    if (sps != null) map['sps'] = sps!.map((b) => b.toJson()).toList();
    return map;
  }
}

class Beneficiary {
  final String id;
  final String name;
  final String bankcode;
  final String type;
  final String amount;
  final String recipient;

  Beneficiary({
    required this.id,
    required this.name,
    required this.bankcode,
    required this.type,
    required this.amount,
    required this.recipient,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bankcode: json['bankcode'] ?? '',
      type: json['type'] ?? '',
      amount: json['amount'] ?? '',
      recipient: json['recipient'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bankcode': bankcode,
      'type': type,
      'amount': amount,
      'recipient': recipient,
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
      host: json['host'] ?? '',
      geolocation: json['geolocation'] ?? '',
      userAgent: json['userAgent'] ?? '',
      userAgentVersion: json['userAgentVersion'] ?? '',
      channel: json['channel'] ?? '',
      clientId: json['clientId'] ?? '',
      deviceId: json['deviceId'] ?? '',
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
