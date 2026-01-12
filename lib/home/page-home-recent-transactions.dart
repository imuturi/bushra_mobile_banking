import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../utils/providers/provider-balances.dart';
import '../utils/providers/provider-mini-recent.dart';
import '../widgets/dialog-transaction-status-check.dart';

class RecentTransactionsScreen extends StatefulWidget {
  const RecentTransactionsScreen({super.key});
  @override
  State<RecentTransactionsScreen> createState() => _RecentTransactionsScreenState();
}

class _RecentTransactionsScreenState extends State<RecentTransactionsScreen> {
  bool compactView = true;
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
      _miniRecentProvider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
      _miniRecentProvider.addListener(_onMiniRecentChanged);
      final balanceProvider = Provider.of<BalanceProvider>(context, listen: false);
      if (balanceProvider.accounts.isNotEmpty) {
        final firstAcc = balanceProvider.accounts.first;
        _currentAccountCardIndexAccountNumber = firstAcc.accountNumber;
        _currentAccountCardIndexCurrency = firstAcc.currency;
      }
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _miniRecentProvider.removeListener(_onMiniRecentChanged);
    _pageControllerAccountCard.dispose();
    super.dispose();
  }

  void _onMiniRecentChanged() {
    if (!mounted) return;
    _applyFilters();
  }

  void onConfirmed(){
    Navigator.pop(context);
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

  String _maskAccount(String account) {
    if (account.length <= 4) return account;
    return '${"*" * 5}${account.substring(account.length - 4)}';
  }

  void _onPageAccountCardChanged(int index, String account, String currency) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    setState(() {
      _currentAccountCardIndex = index;
      _currentAccountCardIndexAccountNumber = account;
      _currentAccountCardIndexCurrency = currency;
    });
    // ✅ Refresh transactions for this account
    _applyFilters();
  }

  void _applyFilters() {
    final provider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
    final allTransactions = provider.allTransactions ?? <RecentTransaction>[];
    final q = searchQuery.trim().toLowerCase();
    setState(() {
      filteredTransactions = allTransactions.where((txn) {
        // ✅ Only transactions for the active account
        final matchesAccount = txn.debtorsAccount == _currentAccountCardIndexAccountNumber
            || txn.creditorsAccount == _currentAccountCardIndexAccountNumber;

        final matchesFilter = selectedFilter == "ALL" || txn.drcrTag == selectedFilter;

        final matchesSearch = q.isEmpty
            ? true
            : ((txn.debtorsName?.toLowerCase().contains(q) ?? false)
            || (txn.creditorName?.toLowerCase().contains(q) ?? false)
            || (txn.debtorsAccount?.contains(q) ?? false)
            || (txn.transactionDate?.toLowerCase().contains(q) ?? false));

        return matchesAccount && matchesFilter && matchesSearch;
      }).toList();
    });
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

  @override
  Widget build(BuildContext context) {
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.recentTransactions,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4,),
            //TODO - SLIDER
            // Swipe-able Account Cards
            SizedBox(
              height: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.height * 0.16 : MediaQuery.of(context).size.height * 0.3,
              width: double.infinity * 0.9,
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
                        onTap: () async {
                          setState(() {
                            _currentAccountCardIndex = index;
                            _currentAccountCardIndexAccountNumber = account.accountNumber;
                            _currentAccountCardIndexCurrency = account.currency;
                          });
                        },
                        child: _buildAccountCardDetail(
                          accountType,
                          account.currency,
                          account.accountNumber,
                          account.iban,
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
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)!.recentTransactions,
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
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: AppLocalizations.of(context)!.searchByAccountNameDate,
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
                      AppLocalizations.of(context)!.noTransactionsAvailable,
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
                                      title: AppLocalizations.of(context)!.transactionDetails,
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
                          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(color: Colors.black.withOpacity(0)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCardDetail(String accountTitle, String currency, String account, String iban, double balance, bool isDarkMode, bool isActiveCard) {
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
                accountTitle,
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
                    // Text(
                    //   'IBAN: ${_maskAccount(iban)}',
                    //   style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    // ),
                    Text(
                      AppLocalizations.of(context)!.actualBalance,
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
      // child: Row(
      //   children: [
      //     CircleAvatar(
      //       radius: 22,
      //       backgroundColor: Colors.white,
      //       child: SvgPicture.asset(
      //         'assets/icons/account-icon.svg',
      //         width: 50, // You can adjust width as needed
      //         height: 50, // You can adjust height as needed
      //       ),
      //     ),
      //     const SizedBox(width: 16),
      //     Expanded(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             accountTitle,
      //             style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      //           ),
      //           const SizedBox(height: 3),
      //           Text(
      //             'A/C # $account',
      //             style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      //           ),
      //           const SizedBox(height: 3),
      //           Text(
      //             'IBAN: $iban',
      //             style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      //           ),
      //           RichText(
      //             //textAlign: TextAlign.center,
      //             text: TextSpan(
      //               children: [
      //                 TextSpan(
      //                   text: "Actual Balance\n",
      //                   style: const TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 11,
      //                     fontWeight: FontWeight.w600,
      //                   ),
      //                 ),
      //                 TextSpan(
      //                   text: hideBalance == false ? "$currency ${NumberFormat("#,##0.00").format(balance)}" : "**** ****",
      //                   style: const TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 14, // Larger font for balance
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildAccountCard(String title, String currency, String account, double balance, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isActive ? Colors.red.shade900 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(20), // More rounded corners
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
                      AppLocalizations.of(context)!.actualBalance,
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
              // Leading Icon
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
