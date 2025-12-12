import 'dart:convert';

class GetFavoritesRequest {
  final String txntimestamp;
  final String xref;
  final TransactionDetails transactionDetails;
  final ChannelDetails channelDetails;

  GetFavoritesRequest({
    required this.txntimestamp,
    required this.xref,
    required this.transactionDetails,
    required this.channelDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      "txntimestamp": txntimestamp,
      "xref": xref,
      "transactionDetails": transactionDetails.toJson(),
      "channelDetails": channelDetails.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

class TransactionDetails {
  final String direction;
  final String transactionType;
  final String transactionCode;
  final String hostCode;
  final String? debitAccount;
  final String phoneNumber;

  TransactionDetails({
    required this.direction,
    required this.transactionType,
    required this.transactionCode,
    required this.hostCode,
    this.debitAccount,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "direction": direction,
      "transactionType": transactionType,
      "transactionCode": transactionCode,
      "hostCode": hostCode,
      "debitAccount": debitAccount,
      "phoneNumber": phoneNumber,
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

  Map<String, dynamic> toJson() {
    return {
      "host": host,
      "geolocation": geolocation,
      "userAgent": userAgent,
      "userAgentVersion": userAgentVersion,
      "channel": channel,
      "clientId": clientId,
      "deviceId": deviceId,
    };
  }
}
