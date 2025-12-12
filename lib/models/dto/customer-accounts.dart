import 'dart:convert';

class AccountDTO {
  final String accountType;
  final String currency;
  final String accountNumber;

  AccountDTO({
    required this.accountType,
    required this.currency,
    required this.accountNumber,
  });

  // Factory constructor to create an instance from JSON
  factory AccountDTO.fromJson(Map<String, dynamic> json) {
    return AccountDTO(
      accountType: json['accountType'] ?? '',
      currency: json['currency'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'accountType': accountType,
      'currency': currency,
      'accountNumber': accountNumber,
    };
  }
}

// Wrapper DTO for the full response
class AccountResponseDTO {
  final AccountDTO account;

  AccountResponseDTO({required this.account});

  factory AccountResponseDTO.fromJson(Map<String, dynamic> json) {
    return AccountResponseDTO(
      account: AccountDTO.fromJson(json['accounts']['account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accounts': {
        'account': account.toJson(),
      },
    };
  }
}
