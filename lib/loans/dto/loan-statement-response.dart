import 'dart:convert';

class LoanStatementResponse {
  final TransactionDetails transactionDetails;
  final String xref;
  final LoanStatementData data;
  final String txntimestamp;
  final ChannelDetails channelDetails;

  LoanStatementResponse({
    required this.transactionDetails,
    required this.xref,
    required this.data,
    required this.txntimestamp,
    required this.channelDetails,
  });

  factory LoanStatementResponse.fromJson(String source) =>
      LoanStatementResponse.fromMap(json.decode(source));

  factory LoanStatementResponse.fromMap(Map<String, dynamic> map) {
    return LoanStatementResponse(
      transactionDetails: TransactionDetails.fromMap(map['transactionDetails']),
      xref: map['xref'],
      data: LoanStatementData.fromMap(map['data']),
      txntimestamp: map['txntimestamp'],
      channelDetails: ChannelDetails.fromMap(map['channelDetails']),
    );
  }
}

class TransactionDetails {
  final String transactionType;
  final String loanAccount;
  final String transactionCode;
  final String hostCode;
  final String direction;

  TransactionDetails({
    required this.transactionType,
    required this.loanAccount,
    required this.transactionCode,
    required this.hostCode,
    required this.direction,
  });

  factory TransactionDetails.fromMap(Map<String, dynamic> map) {
    return TransactionDetails(
      transactionType: map['transactionType'],
      loanAccount: map['loanAccount'],
      transactionCode: map['transactionCode'],
      hostCode: map['hostCode'],
      direction: map['direction'],
    );
  }
}

class LoanStatementData {
  final List<LoanStatement> loanStatements;
  final String responseCode;
  final String response;

  LoanStatementData({
    required this.loanStatements,
    required this.responseCode,
    required this.response,
  });

  factory LoanStatementData.fromMap(Map<String, dynamic>? map) {
    final statements = map?['loan_statements'];
    return LoanStatementData(
      loanStatements: (statements != null && statements['loanStatement'] is List)
          ? (statements['loanStatement'] as List)
          .map((x) => LoanStatement.fromMap(x))
          .toList()
          : [], // Handle empty or null case
      responseCode: map?['response_code'] ?? "",
      response: map?['response'] ?? "",
    );
  }

}

class LoanStatement {
  final String amount;
  final String loanAccount;
  final String drcrIndicator;
  final String refNumber;
  final String event;
  final String accountNumber;
  final String customerNumber;
  final String transactionDate;
  final String amountTag;

  LoanStatement({
    required this.amount,
    required this.loanAccount,
    required this.drcrIndicator,
    required this.refNumber,
    required this.event,
    required this.accountNumber,
    required this.customerNumber,
    required this.transactionDate,
    required this.amountTag,
  });

  factory LoanStatement.fromMap(Map<String, dynamic> map) {
    return LoanStatement(
      amount: map['amount'] ?? '',
      loanAccount: map['loanAccount'] ?? '',  // Removed extra '('
      drcrIndicator: map['drcrIndicator'] ?? '',
      refNumber: map['refNumber'] ?? '',
      event: map['event'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      customerNumber: map['customerNumber'] ?? '',
      transactionDate: map['transactionDate'] ?? '',
      amountTag: map['amountTag'] ?? '',
    );
  }

  factory LoanStatement.fromJson(String source) =>
      LoanStatement.fromMap(json.decode(source));
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

  factory ChannelDetails.fromMap(Map<String, dynamic> map) {
    return ChannelDetails(
      clientId: map['clientId'],
      userAgentVersion: map['userAgentVersion'],
      host: map['host'],
      channel: map['channel'],
      userAgent: map['userAgent'],
      deviceId: map['deviceId'],
      geolocation: map['geolocation'],
    );
  }
}