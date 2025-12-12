import 'package:flutter/foundation.dart';
import '../api-customer-accounts.dart';
import '../dto/api-response-login.dart';

class RecentTransaction {
  final String amount;
  final String drcrTag;
  final String debitRef;
  final String creditorName;
  final String authTimestamp;
  final String transactionRef;
  final String debtorsAccount;
  final String transactionCode;
  final String transactionDate;
  final String creditRef;
  final String transactionDesc;
  final String debtorsName;
  final String creditorsAccount;

  RecentTransaction({
    required this.amount,
    required this.drcrTag,
    required this.debitRef,
    required this.creditorName,
    required this.authTimestamp,
    required this.transactionRef,
    required this.debtorsAccount,
    required this.transactionCode,
    required this.transactionDate,
    required this.creditRef,
    required this.transactionDesc,
    required this.debtorsName,
    required this.creditorsAccount,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      amount: json['amount']?.toString() ?? '',
      drcrTag: json['drcrTag']?.toString() ?? '',
      debitRef: json['debitRef']?.toString() ?? '',
      creditorName: json['creditorName']?.toString() ?? '',
      authTimestamp: json['authTimestamp']?.toString() ?? '',
      transactionRef: json['transactionRef']?.toString() ?? '',
      debtorsAccount: json['debtorsAccount']?.toString() ?? '',
      transactionCode: json['transactionCode']?.toString() ?? '',
      transactionDate: json['transactionDate']?.toString() ?? '',
      creditRef: json['creditRef']?.toString() ?? '',
      transactionDesc: json['transactionDesc']?.toString() ?? '',
      debtorsName: json['debtorsName']?.toString() ?? '',
      creditorsAccount: json['creditorsAccount']?.toString() ?? '',
    );
  }
}


class MiniRecentStatementProvider with ChangeNotifier {

  final apiCustomerAccounts = ApiCustomerAccounts();

  final Map<String, List<RecentTransaction>> _accountTransactions = {};
  final Map<String, String> _accountCurrency = {};
  bool _isFetching = false;

  bool get isFetching => _isFetching;

  List<RecentTransaction> getTransactions(String accountNumber) {
    return _accountTransactions[accountNumber] ?? [];
  }

  List<RecentTransaction> get allTransactions {
    return _accountTransactions.values.expand((txList) => txList).toList();
  }

  String getCurrency(String accountNumber) {
    return _accountCurrency[accountNumber] ?? "USD"; // Default to USD if not available
  }

  Future<void> fetchMiniStatement(String account, String currency, String phone) async {
    _isFetching = true;
    notifyListeners();

    try {
      var response = await apiCustomerAccounts.fetchMiniRecentStatements(
          account,
          phone,
          currency
      );

      List<RecentTransaction> transactionsList = [];
      if (response["data"]["response_code"] == "00") {

        final dynamic recentData = response['data']['recentTransactions'];
        List<dynamic> recent = [];
        if (recentData is Map && recentData.containsKey('recentTransaction')) {
          recent = recentData['recentTransaction'] as List<dynamic>;
        } else if (recentData is List) {
          recent = recentData;
        }
        transactionsList = recent.map((loan) => RecentTransaction.fromJson(loan)).toList();
        _accountTransactions[account] = transactionsList;
        _accountCurrency[account] = currency;
      }else{
        if (kDebugMode) {
          print(response["data"]["response"]);
        }
        throw Exception(response["data"]["response"]);
      }
    } catch (e) {
      debugPrint("Error fetching Recent statement: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  // 🔥 Grouped Transactions Getter 🔥
  Map<String, List<RecentTransaction>> getGroupedTransactions() {
    return _accountTransactions;
  }

  /// Fetch statements for all accounts after fetching balances
  Future<void> fetchStatementsForAllAccounts(List<Account> accounts, String phone) async {
    for (var account in accounts) {
      await fetchMiniStatement(account.accountNumber, account.currency, phone);
    }
  }

}
