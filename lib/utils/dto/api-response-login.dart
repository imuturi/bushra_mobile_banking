class Account {
  final String accountStatus;
  final String accountType;
  final String currency;
  final String accountNumber;
  final String accountName;
  final String iban;
  final double balance;

  Account({
    required this.accountStatus,
    required this.accountType,
    required this.currency,
    required this.accountNumber,
    required this.accountName,
    required this.iban,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        accountStatus: json["accountStatus"] ?? "UNKNOWN",
        accountType: json["accountType"] ?? "UNKNOWN",
        currency: json["currency"] ?? "USD", // Default currency
        accountNumber: json["accountNumber"] ?? "",
        accountName: json["accountName"] ?? "",
        iban: json["iban"] ?? "",
        balance: 0.00
    );
  }

  // factory Account.fromJson(Map<String, dynamic> json) {
  //   return Account(
  //     accountStatus: json["accountStatus"],
  //     accountType: json["accountType"],
  //     currency: json["currency"],
  //     accountNumber: json["accountNumber"],
  //     accountName: json["accountName"],
  //     iban: json["iban"],
  //     balance: 0.00
  //   );
  // }
}

class CustomerDetails {
  final String firstName;
  final String? secondName; // Made nullable
  final String lastName;
  final String customerName;
  final String phoneNumber;
  final String? emailAddress; // Made nullable
  final String idType;
  final String idNumber;
  final String? identificationId; // Made nullable
  final String gender;
  final String? dateOfBirth; // Made nullable
  final String cif;
  final int passReset;
  final int pinBlock;
  final String partiallyRegistered;

  CustomerDetails({
    required this.firstName,
    this.secondName,
    required this.lastName,
    required this.customerName,
    required this.phoneNumber,
    this.emailAddress,
    required this.idType,
    required this.idNumber,
    this.identificationId,
    required this.gender,
    this.dateOfBirth,
    required this.cif,
    required this.passReset,
    required this.pinBlock,
    required this.partiallyRegistered,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      firstName: json["firstName"] ?? "", // Default empty string
      secondName: json["secondName"], // Can be null
      lastName: json["lastName"] ?? "", // Default empty string
      customerName: json["customerName"] ?? "", // Default empty string
      phoneNumber: json["phoneNumber"] ?? "", // Default empty string
      emailAddress: json["emailAddress"], // Can be null
      idType: json["idType"] ?? "", // Default empty string
      idNumber: json["idNumber"] ?? "", // Default empty string
      identificationId: json["identificationId"], // Can be null
      gender: json["gender"] ?? "", // Default empty string
      dateOfBirth: json["dateOfBirth"], // Can be null
      cif: json["cif"] ?? "", // Default empty string
      passReset: json['passReset'] ?? 0,
      pinBlock: json['pinBlock'] ?? 0,
      partiallyRegistered: json['partiallyRegistered'] ?? "N",
    );
  }
}

// class CustomerDetails {
//   final String firstName;
//   final String secondName;
//   final String lastName;
//   final String customerName;
//   final String phoneNumber;
//   final String emailAddress;
//   final String idType;
//   final String idNumber;
//   final String identificationId;
//   final String gender;
//   final String dateOfBirth;
//   final String cif;
//   final int passReset;
//   final int pinBlock;
//   final String partiallyRegistered;
//
//   CustomerDetails({
//     required this.firstName,
//     required this.secondName,
//     required this.lastName,
//     required this.customerName,
//     required this.phoneNumber,
//     required this.emailAddress,
//     required this.idType,
//     required this.idNumber,
//     required this.identificationId,
//     required this.gender,
//     required this.dateOfBirth,
//     required this.cif,
//     required this.passReset,
//     required this.pinBlock,
//     required this.partiallyRegistered,
//   });
//
//   factory CustomerDetails.fromJson(Map<String, dynamic> json) {
//     return CustomerDetails(
//       firstName: json["firstName"],
//       secondName: json["secondName"],
//       lastName: json["lastName"],
//       customerName: json["customerName"],
//       phoneNumber: json["phoneNumber"],
//       emailAddress: json["emailAddress"],
//       idType: json["idType"],
//       idNumber: json["idNumber"],
//       identificationId: json["identificationId"],
//       gender: json["gender"],
//       dateOfBirth: json["dateOfBirth"],
//       cif: json["cif"],
//       passReset: json['passReset'] ?? 0,  // Default to 0 if null
//       pinBlock: json['pinBlock'] ?? 0,    // Default to 0 if null
//       partiallyRegistered: json['partiallyRegistered'] ?? "N", // Default to "N" if null
//     );
//   }
// }

class UserModel {
  final String phoneNumber;
  final List<Account> accounts;
  final String token;
  final CustomerDetails customerDetails;
  final String responseCode;
  final String response;

  UserModel({
    required this.phoneNumber,
    required this.accounts,
    required this.token,
    required this.customerDetails,
    required this.responseCode,
    required this.response,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle case where accounts might be null or not a list
    List<Account> accounts = [];
    if (json["data"]["accounts"] != null && json["data"]["accounts"] is List) {
      var accountList = json["data"]["accounts"] as List;
      accounts = accountList.map((acc) => Account.fromJson(acc)).toList();
    }

    return UserModel(
      phoneNumber: json["transactionDetails"]["phoneNumber"] ?? "",
      accounts: accounts,
      token: json["data"]["token"] ?? "", // Handle potential null token
      customerDetails: CustomerDetails.fromJson(json["data"]["customerDetails"] ?? {}),
      responseCode: json["data"]["response_code"] ?? "",
      response: json["data"]["response"] ?? "",
    );
  }
  // factory UserModel.fromJson(Map<String, dynamic> json) {
  //   var accountList = json["data"]["accounts"] as List;
  //   List<Account> accounts =
  //   accountList.map((acc) => Account.fromJson(acc)).toList();
  //
  //   return UserModel(
  //     phoneNumber: json["transactionDetails"]["phoneNumber"],
  //     accounts: accounts,
  //     token: json["data"]["token"],
  //     customerDetails:
  //     CustomerDetails.fromJson(json["data"]["customerDetails"]),
  //     responseCode: json["data"]["response_code"],
  //     response: json["data"]["response"],
  //   );
  // }

}
