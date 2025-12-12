class LoginApiResponse {
  final String messageId;
  final String correlationId;
  final String statusCode;
  final String statusMessage;
  final String customerNumber;

  LoginApiResponse({
    required this.messageId,
    required this.correlationId,
    required this.statusCode,
    required this.statusMessage,
    required this.customerNumber,
  });

  factory LoginApiResponse.fromJson(Map<String, dynamic> json) {
    return LoginApiResponse(
      messageId: json['header']['messageId'],
      correlationId: json['header']['correlationId'],
      statusCode: json['header']['statusCode'],
      statusMessage: json['header']['statusMessage'],
      customerNumber: json['body']['customerNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'header': {
        'messageId': messageId,
        'correlationId': correlationId,
        'statusCode': statusCode,
        'statusMessage': statusMessage,
      },
      'body': {
        'customerNumber': customerNumber,
      },
    };
  }
}