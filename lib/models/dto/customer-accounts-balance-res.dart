class ApiResponseDTO {
  final ResponseHeader header;
  final ResponseBody body;

  ApiResponseDTO({required this.header, required this.body});

  factory ApiResponseDTO.fromJson(Map<String, dynamic> json) {
    return ApiResponseDTO(
      header: ResponseHeader.fromJson(json['header']),
      body: ResponseBody.fromJson(json['body']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'header': header.toJson(),
      'body': body.toJson(),
    };
  }
}

class ResponseHeader {
  final String messageId;
  final String correlationId;
  final String statusCode;
  final String statusMessage;

  ResponseHeader({
    required this.messageId,
    required this.correlationId,
    required this.statusCode,
    required this.statusMessage,
  });

  factory ResponseHeader.fromJson(Map<String, dynamic> json) {
    return ResponseHeader(
      messageId: json['messageId'] ?? '',
      correlationId: json['correlationId'] ?? '',
      statusCode: json['statusCode'] ?? '',
      statusMessage: json['statusMessage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'correlationId': correlationId,
      'statusCode': statusCode,
      'statusMessage': statusMessage,
    };
  }
}

class ResponseBody {
  final String accountNumber;
  final String cbsReference;
  final double currentBalance;
  final double availableBalance;
  final double netBalance;
  final String accountName;
  final String accountStatus;

  ResponseBody({
    required this.accountNumber,
    required this.cbsReference,
    required this.currentBalance,
    required this.availableBalance,
    required this.netBalance,
    required this.accountName,
    required this.accountStatus,
  });

  factory ResponseBody.fromJson(Map<String, dynamic> json) {
    return ResponseBody(
      accountNumber: json['accountNumber'] ?? '',
      cbsReference: json['cbsReference'] ?? '',
      currentBalance: (json['currentBalance'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      netBalance: (json['netBalance'] ?? 0).toDouble(),
      accountName: json['accountName'] ?? '',
      accountStatus: json['accountStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'cbsReference': cbsReference,
      'currentBalance': currentBalance,
      'availableBalance': availableBalance,
      'netBalance': netBalance,
      'accountName': accountName,
      'accountStatus': accountStatus,
    };
  }
}
