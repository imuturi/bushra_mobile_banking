import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../utils/api-customer-loans.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-log-service.dart';
import 'dto/loan-statement-response.dart';

class LoanStatementScreen extends StatefulWidget {
  final String? loanAccount;
  final String? startDate;
  final String? endDate;
  const LoanStatementScreen({super.key, required this.loanAccount, required this.startDate, required this.endDate});

  @override
  State<LoanStatementScreen> createState() => _LoanStatementScreenState();
}

class _LoanStatementScreenState extends State<LoanStatementScreen> {
  bool isLoading = false;
  var uuid = const Uuid();
  int _selectedTab = 0;

  String loginId = 'FALSE';
  String loginPin = 'FALSE';

  final apiCustomerLoans = ApiCustomerLoans();
  List<LoanStatement> loanStatements = [];

  @override
  void initState(){
    super.initState();
    _loadSharedPreferencesValue();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loanStatement(widget.loanAccount, widget.startDate, widget.endDate);
      }
    });
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  }

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10), // Set to any duration
        backgroundColor: color,
        action: SnackBarAction(
          label: "DISMISS",
          textColor: Colors.white,
          onPressed: () {}, // Dismiss action
        ),
      ),
    );
  }

  void showProgressLoaderDialog(BuildContext context){
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Row(
        children: [
          const CircularProgressIndicator(
            color: Colors.red,
          ),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: Text(AppLocalizations.of(context)!.postingLoanRepaymentNPleaseWait
              )
          ),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
      loginPin = prefs.getString('USER_LOGIN_PIN') ?? "FALSE";
    });
  }

  Future<void> _loanStatement(String? loanAccount, String? startDate, String? endDate) async {
    try {
      setState(() {
        isLoading = true;
      });
      var responseData = await apiCustomerLoans.loanStatements(
        loanAccount!,
        startDate!,
        endDate!,
      );
      if (responseData["data"]["response_code"] == "00") {
        final dynamic loansData = responseData['data']['loan_statements'];
        List<dynamic> loans = [];
        if (loansData is Map && loansData.containsKey('loanStatement')) {
          loans = loansData['loanStatement'] as List<dynamic>;
        } else if (loansData is List) {
          loans = loansData;
        }
        setState(() {
          loanStatements = loans.map((loan) => LoanStatement.fromMap(loan)).toList();
          isLoading = false;
        });
      }else{
        showSnackBar(context, responseData["data"]["response"], Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      showSnackBar(context, error.toString(), Colors.red);
      setState(() {
        isLoading = false;
      });
      throw Exception('FAILED TO GET LOAN-STATEMENT : $error');
    }
  }

  Map<String, List<LoanStatement>> _groupStatementsByDate(List<LoanStatement> statements) {
    Map<String, List<LoanStatement>> grouped = {};
    for (var statement in statements) {
      final key = statement.transactionDate; // or use `dueDate`
      grouped.putIfAbsent(key, () => []).add(statement);
    }
    return grouped;
  }

  final String _selectedSortOption = 'Date';
  void _sortTransactions(Map<String, List<LoanStatement>> transactionsByAccount) {
    setState(() {
      for (var transactions in transactionsByAccount.values) {
        if (_selectedSortOption == 'Date') {
          transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        } else if (_selectedSortOption == 'Amount') {
          transactions.sort((a, b) => b.amount.compareTo(a.amount));
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SessionProvider>(context).user;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final groupedStatements = _groupStatementsByDate(loanStatements);
    final sortedKeys = groupedStatements.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.loanStatements,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort Dropdown
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.transactions,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.sortBy,
                      style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: "Date",
                      underline: const SizedBox(),
                      items: ["Date", "Amount",]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e,style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),)))
                          .toList(),
                      onChanged: (value) {
                        //TODO sort logic
                      },
                      icon: const Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              ],
            ),
            // Transactions List
            Expanded(
              child: loanStatements.isEmpty && isLoading
                  ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.red.shade900,
                  )
              )
                  : loanStatements.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context)!.noTransactionsAvailable, style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
              ),))
                  :
              ListView.builder(
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final dateKey = sortedKeys[index];
                  final txs = groupedStatements[dateKey]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(DateTime.parse(dateKey)),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      ...txs.map((tx) => _buildTransactionItem(
                        tx.amountTag,
                        tx.amount,
                        tx.transactionDate,
                        tx.drcrIndicator,
                        isDarkMode,
                        onTap: () {
                          // your dialog logic here
                        },
                      )),
                      const SizedBox(height: 16.0),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }


  Widget _buildTransactionItem(
      String narration,
      String amount,
      String dateTime,
      String transactionType,
      bool isDarkMode, {
        bool compactView = true,
        required VoidCallback onTap,
      }) {
    final isCredit = transactionType == 'C';
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final iconColor = isCredit ? Colors.green.shade300 : Colors.red.shade900;
    final bgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = isDarkMode ? Colors.grey.shade100 : Colors.grey.shade800;

    final dt = DateTime.parse(dateTime);
    final date = DateFormat('dd/MM/yyyy').format(dt);
    final time = DateFormat('h:mm a').format(dt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        padding: EdgeInsets.all(compactView ? 8.0 : 12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(compactView ? 8.0 : 12.0),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 4.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon
            Container(
              width: compactView ? 30 : 40,
              height: compactView ? 30 : 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: iconColor, size: compactView ? 16 : 20),
            ),
            SizedBox(width: compactView ? 8 : 12),
            // Narration + Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    narration,
                    style: TextStyle(
                      fontSize: compactView ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: compactView ? 10 : 11,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Amount + Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isCredit ? '+' : '-'}\$$amount",
                  style: TextStyle(
                    fontSize: compactView ? 12.5 : 14,
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.green : Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: compactView ? 10 : 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String amount;
  final String date;
  const TransactionItem({super.key,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  AppLocalizations.of(context)!.monthlyInstalment,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}