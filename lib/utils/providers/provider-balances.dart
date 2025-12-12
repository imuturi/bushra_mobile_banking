import 'package:flutter/foundation.dart';
import '../api-customer-accounts.dart';
import '../dto/api-response-login.dart';

class BalanceProvider extends ChangeNotifier {

  final apiCustomerAccounts = ApiCustomerAccounts();

  List<Account> accounts = [];
  Map<String, AccountBalance> accountBalances = {}; // Store balances by account number
  bool isLoading = true;

  void setAccounts(List<Account> accountList) {
    accounts = accountList;
  }

  Future<void> fetchBalances(String phone) async {
    isLoading = true;
    notifyListeners();
    for (var account in accounts) {
      AccountBalance balance = await fetchBalanceFromAPI(
          account.accountNumber,
          account.currency,
          account.accountName,
          account.accountType,
      );
      accountBalances[account.accountNumber] = balance;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<AccountBalance> fetchBalanceFromAPI(String account, String currency, String accountName, String accountType) async {
    try {
      var response = await apiCustomerAccounts.fetchAccountBalance(
          account,
          currency
      );
      if (response["data"]["response_code"] == "00") {
        final balanceResponse = {
          "accountType": accountType,
          "currency": currency,
          "accountNumber": account,
          "accountName": accountName,
          "currentBalance": response["data"]["currentBalance"],
          "netBalance": response["data"]["netBalance"],
          "availableBalance": response["data"]["availableBalance"]
        };
        return AccountBalance.fromJson(balanceResponse);
      }else if(response["data"]["response_code"] != "00"){
        if (kDebugMode) {
          print(response["data"]["response"]);
        }
        final balanceResponse = {
          "accountType": accountType,
          "currency": currency,
          "accountNumber": account,
          "accountName": accountName,
          "currentBalance": 0.0,
          "netBalance": 0.0,
          "availableBalance": 0.0
        };
        return AccountBalance.fromJson(balanceResponse);
      }else{
        if (kDebugMode) {
          print(response["data"]["response"]);
        }
        throw Exception(response["data"]["response"]);
      }
    } catch (error) {
      if (kDebugMode) {
        print('ERROR BALANCE INQUIRY : $error');
      }
      throw Exception('ERROR BALANCE INQUIRY : $error');
    }
  }
}

class AccountBalance {
  final String accountType;
  final String currency;
  final String accountNumber;
  final String accountName;
  final double currentBalance;
  final double netBalance;
  final double availableBalance;

  AccountBalance({
    required this.accountType,
    required this.currency,
    required this.accountNumber,
    required this.accountName,
    required this.currentBalance,
    required this.netBalance,
    required this.availableBalance,
  });

  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    return AccountBalance(
      accountType: json['accountType'],
      currency: json['currency'],
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
      currentBalance: json['currentBalance'],
      netBalance: json['netBalance'],
      availableBalance: json['availableBalance'],
    );
  }
}
