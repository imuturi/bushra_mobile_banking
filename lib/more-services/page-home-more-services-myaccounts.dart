import 'package:bushra_mobile/home/page-home-statements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/api-customer-accounts.dart';
import '../utils/providers/provider-balances.dart';
import '../utils/providers/provider-session.dart';
import '../widgets/dialog-coming-soon.dart';

class MyAccountsScreen extends StatefulWidget {
  const MyAccountsScreen({super.key});

  @override
  State<MyAccountsScreen> createState() => _MyAccountsScreenState();
}

class _MyAccountsScreenState extends State<MyAccountsScreen> {

  bool isNormalAccountSelected = true;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SessionProvider>(context).user;
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeader(context, constraints.maxHeight * (isLandscape ? 0.4 : 0.3)),
                _buildAccountTabs(),
                Expanded(
                  child: isNormalAccountSelected
                      ? _buildNormalAccounts(context)
                      : _buildWalletAccounts(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  Widget _buildHeader(BuildContext context, double height) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            "assets/images/my-accounts-bg-half.svg",
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 16,
            top: isLandscape ? 8 : 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'My Accounts',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isNormalAccountSelected = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isNormalAccountSelected
                    ? Colors.red.shade900
                    : Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Normal Accounts',
                style: TextStyle(
                  color: isNormalAccountSelected
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isNormalAccountSelected = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !isNormalAccountSelected
                    ? Colors.red.shade900
                    : Colors.pink.shade50,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Wallet Accounts',
                style: TextStyle(
                  color: !isNormalAccountSelected
                      ? Colors.white
                      : Colors.indigo,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalAccounts(BuildContext context) {
    return Consumer<BalanceProvider>(
      builder: (context, balanceProvider, child) {
        return ListView.separated(
          shrinkWrap: true, // Prevents infinite height
          itemCount: balanceProvider.accounts.length,
          itemBuilder: (context, index) {
            final account = balanceProvider.accounts[index];

            // Get exact balance values from BalanceProvider
            final double currentBalance =
                balanceProvider.accountBalances[account.accountNumber]?.currentBalance ?? 0.0;
            final double netBalance =
                balanceProvider.accountBalances[account.accountNumber]?.netBalance ?? 0.0;
            final double availableBalance =
                balanceProvider.accountBalances[account.accountNumber]?.availableBalance ?? 0.0;

            String accountType;
            if(account.accountType=='SAVINGS'){
              accountType = 'Saving Account';
            }else if(account.accountType=='CURRENT'){
              accountType = 'Current Account';
            }else if(account.accountType=='DEPOSIT'){
              accountType = 'Term Deposit';
            }else{
              accountType = account.accountType;
            }

            return AccountCard(
              title: accountType,
              accountNumber: 'Acc NO: ${account.accountNumber}',
              iban: account.iban.isNotEmpty ? 'IBAN: ${account.iban}' : 'IBAN: N/A',
              currency: account.currency,
              phoneNumber: '',
              availableBalance: currentBalance,
              actualBalance: netBalance,
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 16); // Add space between items
          },
        );
      },
    );
  }

  Widget _buildWalletAccounts(BuildContext context) {
    if(!isNormalAccountSelected) {
      return const ComingSoonDialog();
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        AccountCard(
          title: 'Digital Wallet',
          accountNumber: 'Wallet ID: NULL',
          iban: 'IBAN',
          currency: 'USD',
          phoneNumber: 'PHONE_NO',
          availableBalance: 0.0,
          actualBalance: 0.0,
        ),
      ],
    );
  }

}


class AccountCard extends StatefulWidget {
  final String title;
  final String accountNumber;
  final String iban;
  final String currency;
  final String phoneNumber;
  final double availableBalance;
  final double actualBalance;

  const AccountCard({
    super.key,
    required this.title,
    required this.accountNumber,
    required this.iban,
    required this.currency,
    required this.phoneNumber,
    required this.availableBalance,
    required this.actualBalance,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _isBalanceVisible = false;
  String formattedAvailableBalance = '';
  String formattedActualBalance = '';
  final apiCustomerAccounts = ApiCustomerAccounts();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {}
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Function to copy IBAN to clipboard
  void _copyIbanToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.iban));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('IBAN copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade800),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.accountNumber,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Add IBAN section with copy icon
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        widget.iban,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.copy, size: 20),
                  color: Colors.red.shade800,
                  onPressed: _copyIbanToClipboard,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  tooltip: 'Copy IBAN',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        _isBalanceVisible
                            ? '${widget.currency} ${NumberFormat("#,##0.00").format(widget.availableBalance)}'
                            : '********',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.5),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Actual Balance',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        _isBalanceVisible
                            ? '${widget.currency} ${NumberFormat("#,##0.00").format(widget.actualBalance)}'
                            : '********',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isBalanceVisible = !_isBalanceVisible;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Check Balance',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    //TODO - Statement Check API
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StatementScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View Statement',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class AccountCard extends StatefulWidget {
//   final String title;
//   final String accountNumber;
//   final String iban;
//   final String currency;
//   final String phoneNumber;
//   final double availableBalance;
//   final double actualBalance;
//
//   const AccountCard({
//     super.key,
//     required this.title,
//     required this.accountNumber,
//     required this.iban,
//     required this.currency,
//     required this.phoneNumber,
//     required this.availableBalance,
//     required this.actualBalance,
//   });
//
//   @override
//   State<AccountCard> createState() => _AccountCardState();
//
// }
// class _AccountCardState extends State<AccountCard> {
//
//     bool _isBalanceVisible = false;
//     String formattedAvailableBalance ='';
//     String formattedActualBalance ='';
//     final apiCustomerAccounts = ApiCustomerAccounts();
//
//     @override
//     void initState(){
//       super.initState();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//         }
//       });
//     }
//
//     @override
//     void dispose() {
//       super.dispose();
//     }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.red.shade800),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 widget.title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 widget.accountNumber,
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.indigo.shade900,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       const Text(
//                         'Available Balance',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       Text(
//                         _isBalanceVisible
//                             ? '${widget.currency} ${NumberFormat("#,##0.00").format(widget.availableBalance)}'
//                             : '********',
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                       // Text(
//                       //   _isBalanceVisible ? '\$$formattedAvailableBalance' : '********',
//                       //   style: const TextStyle(color: Colors.white),
//                       // ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   width: 1,
//                   height: 40,
//                   color: Colors.white.withOpacity(0.5),
//                 ),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       const Text(
//                         'Actual Balance',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       Text(
//                         _isBalanceVisible
//                             ? '${widget.currency} ${NumberFormat("#,##0.00").format(widget.actualBalance)}'
//                             : '********',
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                       )
//                       // Text(
//                       //   _isBalanceVisible ? '\$$formattedActualBalance' : '********',
//                       //   style: const TextStyle(color: Colors.white),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     setState(() {
//                       _isBalanceVisible = !_isBalanceVisible;
//                     });
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.shade800,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: const Text(
//                     'Check Balance',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     //TODO - Statement Check API
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const StatementScreen()));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.shade800,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: const Text(
//                     'View Statement',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }