class ApiResponseModelCustomerVerification {
  String responseCode;
  String responseMessage;
  String? errorData;
  Customer? customer;

  ApiResponseModelCustomerVerification({
    required this.responseCode,
    required this.responseMessage,
    this.errorData,
    this.customer,
  });

  // Factory constructor to parse JSON dynamically
  factory ApiResponseModelCustomerVerification.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('customer')) {
      // Handling Response 1
      return ApiResponseModelCustomerVerification(
        responseCode: json["response_code"] ?? "",
        responseMessage: json["response"] ?? "",
        customer: Customer.fromJson(json["customer"]),
      );
    } else if (json.containsKey('data')) {
      // Handling Response 2
      final data = json["data"]["response"];
      return ApiResponseModelCustomerVerification(
        responseCode: data["response_code"] ?? "",
        responseMessage: data["response"] ?? "",
        errorData: data["error_data"],
      );
    } else {
      throw Exception("Unknown response format");
    }
  }
}

class Customer {
  String cif;
  String phoneNumber;
  String passport;
  String accountNumber;
  String email;
  String dateOfBirth;

  Customer({
    required this.cif,
    required this.phoneNumber,
    required this.passport,
    required this.accountNumber,
    required this.email,
    required this.dateOfBirth,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      cif: json["cif"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      passport: json["passport"] ?? "",
      accountNumber: json["accountNumber"] ?? "",
      email: json["email"] ?? "",
      dateOfBirth: json["dateOfBirth"] ?? "",
    );
  }
}
