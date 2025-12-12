import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';
import '../utils/api-customer-accounts.dart';
import '../utils/providers/provider-balances.dart';
import '../utils/providers/provider-mini-recent.dart';
import '../utils/providers/provider-session.dart';
import '../widgets/dialog-error.dart';
import '../widgets/dialog-success.dart';
import '../widgets/dialog-transaction-status-check.dart';
import '../widgets/dialog-transaction-status.dart';
import '../widgets/progress-dialog.dart';

class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  bool isLoading = false;
  var uuid = const Uuid();
  final apiCustomerAccounts = ApiCustomerAccounts();
  int _selectedTab = 0;

  final PageController _pageControllerAccountCard = PageController(viewportFraction: 0.9);
  int _currentAccountCardIndex = 0;
  late String _currentAccountCardIndexAccountNumber;
  late String _currentAccountCardIndexCurrency;

  List<RecentTransaction> filteredTransactions = [];
  String selectedFilter = "ALL"; // ALL, CR, DR
  String searchQuery = "";
  bool hideBalance = false;
  late MiniRecentStatementProvider _miniRecentProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final balanceProvider = Provider.of<BalanceProvider>(context, listen: false);
      if (balanceProvider.accounts.isNotEmpty) {
        _currentAccountCardIndexAccountNumber = balanceProvider.accounts[0].accountNumber;
        _currentAccountCardIndexCurrency = balanceProvider.accounts[0].currency;
      }
      _miniRecentProvider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
      _miniRecentProvider.addListener(_onMiniRecentChanged);
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _miniRecentProvider.removeListener(_onMiniRecentChanged);
    _pageControllerAccountCard.dispose();
    super.dispose();
  }

  void onRetry(){
    Navigator.pop(context);
  }

  void onConfirmed(){
    Navigator.pop(context);
  }

  void _onMiniRecentChanged() {
    if (!mounted) return;
    _applyFilters();
  }

  void _applyFilters() {
    final provider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
    final allTransactions = provider.allTransactions ?? <RecentTransaction>[];
    final q = searchQuery.trim().toLowerCase();
    setState(() {
      filteredTransactions = allTransactions.where((txn) {
        // 🔵 Filter by selected account first
        final matchesAccount = txn.debtorsAccount == _currentAccountCardIndexAccountNumber
            || txn.creditorsAccount == _currentAccountCardIndexAccountNumber;

        final matchesFilter = selectedFilter == "ALL" || txn.drcrTag == selectedFilter;
        final matchesSearch = q.isEmpty
            ? true
            : ((txn.debtorsName?.toLowerCase().contains(q) ?? false) ||
            (txn.creditorName?.toLowerCase().contains(q) ?? false) ||
            (txn.debtorsAccount?.contains(q) ?? false) ||
            (txn.transactionDate?.toLowerCase().contains(q) ?? false));

        return matchesAccount && matchesFilter && matchesSearch;
      }).toList();
    });
  }
  void _onPageAccountCardChanged(int index, String account, String currency) {
    if (!mounted) return;
    setState(() {
      _currentAccountCardIndex = index;
      _currentAccountCardIndexAccountNumber = account;
      _currentAccountCardIndexCurrency = currency;
    });
    _applyFilters(); // 🔵 Refresh transactions based on account
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

  void showErrorDialog(BuildContext context, String messageParent, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorAlertDialog(message: message, onRetry: onRetry, messageParent: messageParent,),
    );
  }

  void showSuccessDialog(BuildContext context, String messageParent, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessAlertDialog(message: message, onOkay: onRetry, messageParent: messageParent,),
    );
  }

  void showCrossingBallsProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CrossingBallsProgressDialog(message: message,),
    );
  }

  Future<void> fetchFullStatements(String fromDate, String toDate) async {
    final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
    final apiCustomerAccounts = ApiCustomerAccounts();
    try {
      var responseData = await apiCustomerAccounts.fetchFullStatements(
          authProvider!.accounts[0].accountNumber,
          authProvider.phoneNumber,
          authProvider.accounts[0].currency,
          fromDate,
          toDate,
          5,
          authProvider.customerDetails.emailAddress!,
      );
      if (responseData['data']['response_code'] == '00') {
        setState(() {
          isLoading = false;
          Navigator.pop(context);
          showSuccessDialog(context, responseData['data']['response'], 'Statement emailed successfully', onRetry);
        });
      }else{
        setState(() {
          isLoading = false;
          Navigator.pop(context);
          showErrorDialog(context, 'Oops! Your Request Failed', responseData['data']['response'], onRetry);
        });
      }
    } catch (error) {
      showSnackBar(context, error.toString(), Colors.red);
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      throw Exception('FAILED to get customer : $error');
    }
  }

  String parseDateTimeStringToDate(String? input) {
    if (input == null || input.isEmpty) {
      return input ?? '0000-00-00';
    }
    try {
      final parsed = DateTime.parse(input);
      final String date = "${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      return date;
    } catch (e) {
      return input;
    }
  }

  String parseDateTimeStringToTime(String? input) {
    if (input == null || input.isEmpty) {
      return input ?? '00:00';
    }
    try {
      final parsed = DateTime.parse(input);
      // Format date and time
      final String date = "${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      final String time = "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
      return time;
    } catch (e) {
      return "00:00";
    }
  }

  Future<void> _shareWidget(GlobalKey repaintKey) async {
    try {
      if (repaintKey.currentContext == null) {
        debugPrint("Widget not ready yet");
        return;
      }
      RenderRepaintBoundary boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return _shareWidget(repaintKey);
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/receipt.png';
      await File(filePath).writeAsBytes(pngBytes);
      //File imgFile = File(filePath)..writeAsBytesSync(pngBytes);
      await SharePlus.instance.share(
        ShareParams(
          text: "Here is your receipt for the transaction.",
          files: [XFile(filePath)],
        ),
      );
    } catch (e) {
      showSnackBar(context, "Error Sharing Receipt : $e", Colors.red);
      debugPrint("Error sharing receipt: $e");
    }
  }

  String _maskAccount(String account) {
    if (account.length <= 4) return account;
    return '${"*" * 5}${account.substring(account.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SessionProvider>(context).user;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
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
        title: const Text(
          "Statements",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
      ),
      body: LayoutBuilder(
          builder: (context, constraints){
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Tab Buttons
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Container(
                      height: MediaQuery.of(context).orientation == Orientation.portrait
                          ? screenHeight *  0.06
                          : screenHeight * 0.15,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.indigo.shade900, // Border color
                          width: 1.0, // Border thickness
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                color: _selectedTab == 0 ? Colors.indigo.shade900 : Colors.white,
                                child: Text(
                                  "Mini-statements",
                                  style: TextStyle(
                                    color: _selectedTab == 0 ? Colors.white : Colors.indigo.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                color: _selectedTab == 1 ? Colors.indigo.shade900 : Colors.white,
                                child: Text(
                                  "Full-statements",
                                  style: TextStyle(
                                    color: _selectedTab == 1 ? Colors.white : Colors.indigo.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4,),
                  //TODO - SLIDER
                  // Swipe-able Account Cards
                  SizedBox(
                    //height: screenHeight * 0.18,
                    height: MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenHeight * 0.18
                        : screenHeight * 0.45,
                    child: Consumer<BalanceProvider>(
                      builder: (context, balanceProvider, child) {
                        return PageView(
                          controller: _pageControllerAccountCard,
                          onPageChanged: (index) {
                            final account = balanceProvider.accounts[index]; // Get account from provider
                            _onPageAccountCardChanged(index, account.accountNumber, account.currency);
                          },
                          children: balanceProvider.accounts.asMap().entries.map<Widget>((entry) {
                            int index = entry.key;
                            var account = entry.value;
                            final double currentBalance =
                                balanceProvider.accountBalances[account.accountNumber]?.currentBalance ?? 0.0;
                            final double netBalance =
                                balanceProvider.accountBalances[account.accountNumber]?.netBalance ?? 0.0;
                            final double availableBalance =
                                balanceProvider.accountBalances[account.accountNumber]?.availableBalance ?? 0.0;
                            String accountType;
                            if(account.accountType=='S'){
                              accountType = 'Saving Account';
                            }else if(account.accountType=='C'){
                              accountType = 'Current Account';
                            }else if(account.accountType=='D'){
                              accountType = 'Term Deposit Account';
                            }else{
                              accountType = account.accountType;
                            }
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentAccountCardIndex = index;
                                  _currentAccountCardIndexAccountNumber = account.accountNumber;
                                  _currentAccountCardIndexCurrency = account.currency;
                                });
                                _applyFilters(); // 🔵 Refresh transactions
                              },
                              child: _buildAccountCardDetail(
                                accountType,
                                account.currency,
                                account.accountNumber,
                                availableBalance,
                                isDarkMode,
                                _currentAccountCardIndex == index,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: _selectedTab == 0 ?
                    _buildMiniStatementsTab(isDarkMode) : _buildFullStatementsTab(isDarkMode),
                  ),
                ],
              );
          }
      ),
    );
  }

  Widget _buildMiniStatementsTab(bool isDarkMode) {
    final miniRecentStatementsProvider = Provider.of<MiniRecentStatementProvider>(context);
    // choose which list to display: filtered (if any filter/search is active) otherwise provider list
    final bool isFilteringActive = searchQuery.trim().isNotEmpty || selectedFilter != 'ALL';
    final List<RecentTransaction> displayTransactions =
    (isFilteringActive || filteredTransactions.isNotEmpty)
        ? filteredTransactions
        : (miniRecentStatementsProvider.allTransactions ?? <RecentTransaction>[]);
    // grouping function (same as yours but using displayTransactions)
    Map<String, List<RecentTransaction>> groupByDate(List<RecentTransaction> transactions) {
      final Map<String, List<RecentTransaction>> grouped = {};
      for (var tx in transactions) {
        final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(tx.transactionDate));
        grouped.putIfAbsent(dateKey, () => []).add(tx);
      }
      final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
      return Map.fromEntries(sortedKeys.map((key) => MapEntry(key, grouped[key]!)));
    }
    final groupedByDate = groupByDate(displayTransactions);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      //padding: const EdgeInsets.all(16),
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Recent Transactions",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    hideBalance ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      hideBalance = !hideBalance;
                    });
                  },
                ),
              ],
            ),
          ),
          // 🔵 Search + Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                ToggleButtons(
                  selectedBorderColor: Colors.indigo.shade900,
                  selectedColor: Colors.white,
                  fillColor: Colors.indigo.shade900,
                  borderRadius: BorderRadius.circular(8),
                  isSelected: [
                    selectedFilter == "ALL",
                    selectedFilter == "CR",
                    selectedFilter == "DR"
                  ],
                  onPressed: (index) {
                    setState(() {
                      selectedFilter = ["ALL", "CR", "DR"][index];
                      _applyFilters();
                    });
                  },
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("All")),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("In")),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Out")),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search by Account, Name, Date",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      searchQuery = val;
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          Divider(
            color: Colors.grey,     // line color
            thickness: 1,           // line thickness
            indent: 4,             // empty space to the leading edge
            endIndent: 4,          // empty space to the trailing edge
          ),
          // Transactions List
          Expanded(
            child: Stack(
              children: [
                miniRecentStatementsProvider.isFetching
                    ? const Center(child: CircularProgressIndicator())
                    : displayTransactions.isEmpty
                    ? Center(
                  child: Text(
                    "No transactions available",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: groupedByDate.keys.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedByDate.keys.elementAt(index);
                    final txs = groupedByDate[dateKey]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(DateTime.parse(dateKey)),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                          ),
                        ),
                        ...txs.map(
                              (tx) => _buildTransactionItem(
                            tx.drcrTag == 'DR'
                                ? ((tx.creditorName.trim().isEmpty) ? tx.transactionDesc : tx.creditorName)
                                : ((tx.debtorsName.trim().isEmpty) ? tx.transactionDesc : tx.debtorsName),
                            double.parse(tx.amount),
                            tx.authTimestamp,
                            tx.drcrTag,
                            tx.transactionCode,
                            isDarkMode,
                            onTap: () {
                              final GlobalKey dialogKey = GlobalKey();
                              showDialog(
                                context: context,
                                builder: (context) => TransactionStatusCheckDialog(
                                  repaintKey: dialogKey,
                                  data: TransactionStatusCheckData(
                                    title: "Transaction Details",
                                    dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.parse(tx.authTimestamp)),
                                    reference: (tx.creditorName.trim().isEmpty) ? tx.debitRef : tx.transactionRef,
                                    source: tx.debtorsAccount,
                                    destination: tx.creditorsAccount!.trim().isEmpty ? tx.transactionCode : tx.creditorsAccount!,
                                    sourceName: tx.debtorsName,
                                    recipient: (tx.creditorName.trim().isEmpty) ? tx.transactionDesc : tx.creditorName,
                                    amount: tx.amount.toString(),
                                    transactionCode: tx.transactionCode,
                                    narration: tx.transactionDesc,
                                  ),
                                  onConfirmed: onConfirmed,
                                  onShare: () {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _shareWidget(dialogKey); // will now find the boundary
                                    });
                                  },
                                  isLoading: false,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  },
                ),

                if (hideBalance)
                  Positioned.fill(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(color: Colors.black.withOpacity(0)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullStatementsTab(bool isDarkMode) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final authProvider = Provider.of<SessionProvider>(context).user;

    final statementsProvider = Provider.of<MiniRecentStatementProvider>(context);
    final transactionsByAccount = statementsProvider.getGroupedTransactions();
    final allTransactions = statementsProvider.allTransactions;

    TextEditingController startDateController = TextEditingController();
    TextEditingController endDateController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Full Statements',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          // Start Date Input
          TextField(
            controller: startDateController,
            readOnly: true, // Prevent manual input
            decoration: InputDecoration(
              labelText: "Start Date",
              hintText: "YYYY-MM-DD",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.calendar_today), // Calendar icon
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900), // Earliest selectable date
                lastDate: DateTime.now(), // Prevent future dates
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.red.shade900, // Header background color
                        onPrimary: Colors.white, // Header text color
                        surface: Colors.white, // Dialog background color
                        onSurface: Colors.black, // Text color
                      ),
                      dialogBackgroundColor: Colors.white, // Alternative way to set background color
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                startDateController.text =
                "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
              }
            },
          ),
          const SizedBox(height: 20),
          // End Date Input
          TextField(
            controller: endDateController,
            readOnly: true, // Prevent manual input
            decoration: InputDecoration(
              labelText: "End Date",
              hintText: "YYYY-MM-DD",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.calendar_today), // Calendar icon
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900), // Earliest selectable date
                lastDate: DateTime.now(), // Prevent future dates
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.red.shade900, // Header background color
                        onPrimary: Colors.white, // Header text color
                        surface: Colors.white, // Dialog background color
                        onSurface: Colors.black, // Text color
                      ),
                      dialogBackgroundColor: Colors.white, // Alternative way to set background color
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                endDateController.text =
                "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
              }
            },
          ),
          const SizedBox(height: 30),
          // Search Button
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (kDebugMode) {
                      print("Start Date: ${startDateController.text}, End Date: ${endDateController.text}");
                    }
                    if (startDateController.text.isEmpty || endDateController.text.isEmpty) {
                      showSnackBar(context, "Please select both start and end dates", Colors.red);
                      return;
                    }
                    showCrossingBallsProgressDialog(context, 'Fetching full statement \n Please Wait...');
                    await fetchFullStatements(
                      startDateController.text,
                      endDateController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'GENERATE FULL STATEMENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),
          // ListView with Expanded
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: statementsProvider.allTransactions.length,
          //     itemBuilder: (context, index) {
          //       final transaction = statementsProvider.allTransactions[index];
          //       bool isDebit = transaction.transactionType == "D";
          //       return AlertCardFullStatement(
          //         title: isDebit ? "Debit Transaction" : "Credit Transaction",
          //         description: transaction.narration,
          //         dateTime: transaction.transactionDate,
          //         icon: isDebit ? Icons.arrow_downward : Icons.arrow_upward,
          //         iconColor: isDebit ? Colors.red : Colors.green,
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildAccountCardDetail(String title, String currency, String account, double balance, bool isDarkMode, bool isActiveCard) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isActiveCard ? Colors.red.shade900 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                ),
              ),
              Text(
                'A/C #${_maskAccount(account)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: SvgPicture.asset(
                  'assets/icons/account-icon.svg',
                  width: 50, // You can adjust width as needed
                  height: 50, // You can adjust height as needed
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),
                    Text(
                      "Actual Balance",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$currency ${NumberFormat("#,##0.00").format(balance)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      String narration,
      double amount,
      String time,
      String transactionType,
      String transactionCode,
      bool isDarkMode,
      {bool compactView = true, required Null Function() onTap}
      ) {
    final isCredit = transactionType == 'CR';
    final icon = isCredit ? Icons.south_west : Icons.north_east;
    final iconColor = isCredit ? Colors.white : Colors.white;
    //final bgColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final bgColor = Colors.grey.shade200;
    final textColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade600;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compactView ? 4.0 : 8.0),
        child: Container(
          padding: EdgeInsets.all(compactView ? 8.0 : 12.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(compactView ? 8.0 : 12.0),
            boxShadow: [
              // BoxShadow(
              //   color: Colors.grey.withOpacity(0.2),
              //   blurRadius: 6.0,
              //   spreadRadius: 1.0,
              //   offset: const Offset(0, 3),
              // ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: compactView ? 30 : 40,
                height: compactView ? 30 : 40,
                decoration: BoxDecoration(
                  color: isCredit ? Colors.green.shade700 : Colors.red.shade900,
                  borderRadius: BorderRadius.circular(compactView ? 15.0 : 20.0),
                ),
                child: Icon(icon, color: iconColor, size: compactView ? 16 : 20),
              ),
              SizedBox(width: compactView ? 8.0 : 12.0),
              // Narration and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      narration,
                      style: TextStyle(
                        fontSize: compactView ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (!compactView) const SizedBox(height: 4.0),
                    Text(
                      "$transactionCode - ${parseDateTimeStringToDate(time)}",
                      style: TextStyle(
                        fontSize: compactView ? 10 : 12,
                        color: isDarkMode ? Colors.grey.shade500 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isCredit ? "+${NumberFormat("#,##0.00").format(amount)} USD" : "-${NumberFormat("#,##0.00").format(amount)} USD",
                    style: TextStyle(
                      fontSize: compactView ? 13 : 14,
                      fontWeight: FontWeight.w800,
                      color: isCredit ? Colors.green : Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    parseDateTimeStringToTime(time),
                    style: TextStyle(
                      fontSize: compactView ? 10 : 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}


class AlertCardFullStatement extends StatelessWidget {
  final String title;
  final String description;
  final String dateTime;
  final IconData icon;
  final Color iconColor;

  const AlertCardFullStatement({super.key,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.red.shade50,
              child: Icon(icon, color: iconColor, size: 25),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateTime,
                    style: const TextStyle(color: Colors.black38, fontSize: 8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}