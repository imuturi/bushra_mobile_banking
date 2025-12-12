class AccountVerifyApiResponse {
  final String responseCode;
  final String responseMessage;
  final String? errorData;
  final Customer? customer;

  AccountVerifyApiResponse({
    required this.responseCode,
    required this.responseMessage,
    this.errorData,
    this.customer,
  });

  // Factory method to parse JSON
  factory AccountVerifyApiResponse.fromJson(Map<String, dynamic> json) {
    return AccountVerifyApiResponse(
      responseCode: json['response_code'] ?? json['data']?['response']?['response_code'] ?? "99",
      responseMessage: json['response'] ?? json['data']?['response']?['response'] ?? "Unknown Response",
      errorData: json['data']?['response']?['error_data'],
      customer: json.containsKey('customer') ? Customer.fromJson(json['customer']) : null,
    );
  }

  bool get isSuccess => responseCode == "00";
}

class Customer {
  final String cif;
  final String phoneNumber;
  final String passport;
  final String accountNumber;
  final String email;

  Customer({
    required this.cif,
    required this.phoneNumber,
    required this.passport,
    required this.accountNumber,
    required this.email,
  });

  // Factory method to parse JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      cif: json['cif'],
      phoneNumber: json['phoneNumber'],
      passport: json['passport'],
      accountNumber: json['accountNumber'],
      email: json['email'],
    );
  }
}
