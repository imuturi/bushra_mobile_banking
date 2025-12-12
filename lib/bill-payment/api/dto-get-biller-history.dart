class BillPaymentTransactionResponse {
  final BillPaymentResponseData? data;
  final List<Transaction>? transactions;

  BillPaymentTransactionResponse({this.data, this.transactions});

  factory BillPaymentTransactionResponse.fromJson(Map<String, dynamic> json) {
    return BillPaymentTransactionResponse(
      data: json['data'] != null ? BillPaymentResponseData.fromJson(json['data']) : null,
      transactions: json['transactions'] != null
          ? List<Transaction>.from(json['transactions'].map((x) => Transaction.fromJson(x)))
          : [],
    );
  }
}

class BillPaymentResponseData {
  final String responseCode;
  final String response;

  BillPaymentResponseData({required this.responseCode, required this.response});

  factory BillPaymentResponseData.fromJson(Map<String, dynamic> json) {
    return BillPaymentResponseData(
      responseCode: json['response_code'],
      response: json['response'],
    );
  }
}

class Transaction {
  final double amount;
  final String xref;
  final String debitAccount;
  final String creditAccount;
  final String clientId;
  final String channel;
  final String transactionStatusDesc;
  final String userAgent;
  final String transactionCode;
  final String deviceId;
  final String transactionType;
  final String createdAt;
  final String phoneNumber;
  final String userAgentVersion;
  final String narration;
  final String currency;
  final String transactionStatusCode;
  final int id;
  final String hostCode;
  final String billNumber;
  final String updatedAt;
  final String direction;
  final String geolocation;

  Transaction({
    required this.amount,
    required this.xref,
    required this.debitAccount,
    required this.creditAccount,
    required this.clientId,
    required this.channel,
    required this.transactionStatusDesc,
    required this.userAgent,
    required this.transactionCode,
    required this.deviceId,
    required this.transactionType,
    required this.createdAt,
    required this.phoneNumber,
    required this.userAgentVersion,
    required this.narration,
    required this.currency,
    required this.transactionStatusCode,
    required this.id,
    required this.hostCode,
    required this.billNumber,
    required this.updatedAt,
    required this.direction,
    required this.geolocation,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: json['amount']?.toDouble() ?? 0.0,
      xref: json['xref'],
      debitAccount: json['debitAccount'],
      creditAccount: json['creditAccount'],
      clientId: json['clientId'],
      channel: json['channel'],
      transactionStatusDesc: json['transactionStatusDesc'],
      userAgent: json['userAgent'],
      transactionCode: json['transactionCode'],
      deviceId: json['deviceId'],
      transactionType: json['transactionType'],
      createdAt: json['createdAt'],
      phoneNumber: json['phoneNumber'],
      userAgentVersion: json['userAgentVersion'],
      narration: json['narration'],
      currency: json['currency'],
      transactionStatusCode: json['transactionStatusCode'],
      id: json['id'],
      hostCode: json['hostCode'],
      billNumber: json['billNumber'],
      updatedAt: json['updatedAt'],
      direction: json['direction'],
      geolocation: json['geolocation'],
    );
  }
}
