import 'package:flutter/foundation.dart';
import '../api-customer-accounts.dart';
import '../dto/api-response-login.dart';

class Transaction {
  final String transactionType;
  final double transactionAmount;
  final String narration;
  final String transactionRef;
  final String? transactionDescription;
  final String transactionDate;
  final String externalRef;
  final double runningBalance;

  Transaction({
    required this.transactionType,
    required this.transactionAmount,
    required this.narration,
    required this.transactionRef,
    this.transactionDescription,
    required this.transactionDate,
    required this.externalRef,
    required this.runningBalance,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionType: json['transactionType'],
      transactionAmount: (json['transactionAmount'] as num).toDouble(),
      narration: json['narration'],
      transactionRef: json['transactionRef'].toString(),
      transactionDescription: json['transactionDescription'],
      transactionDate: json['transactionDate'],
      externalRef: json['externalRef'].toString(),
      runningBalance: (json['runningBalance'] as num).toDouble(),
    );
  }
}

class MiniStatementProvider with ChangeNotifier {

  final apiCustomerAccounts = ApiCustomerAccounts();

  final Map<String, List<Transaction>> _accountTransactions = {};
  final Map<String, String> _accountCurrency = {};
  bool _isFetching = false;

  bool get isFetching => _isFetching;

  List<Transaction> getTransactions(String accountNumber) {
    return _accountTransactions[accountNumber] ?? [];
  }

  List<Transaction> get allTransactions {
    return _accountTransactions.values.expand((txList) => txList).toList();
  }

  String getCurrency(String accountNumber) {
    return _accountCurrency[accountNumber] ?? "USD"; // Default to USD if not available
  }

  Future<void> fetchMiniStatement(String account, String currency) async {
    _isFetching = true;
    notifyListeners();

    try {
      var response = await apiCustomerAccounts.fetchMiniStatements(
          account,
          '',
          currency
      );

      if (response["data"]["response_code"] == "00") {
        List<Transaction> transactions = (response["data"]["transactions"] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
        _accountTransactions[account] = transactions;
        _accountCurrency[account] = currency;
      }else{
        if (kDebugMode) {
          print(response["data"]["response"]);
        }
        throw Exception(response["data"]["response"]);
      }
    } catch (e) {
      debugPrint("Error fetching mini statement: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  // 🔥 Grouped Transactions Getter 🔥
  Map<String, List<Transaction>> getGroupedTransactions() {
    return _accountTransactions;
  }

  /// Fetch statements for all accounts after fetching balances
  Future<void> fetchStatementsForAllAccounts(List<Account> accounts) async {
    for (var account in accounts) {
      await fetchMiniStatement(account.accountNumber, account.currency);
    }
  }

}
