import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../utils/api-customer-accounts.dart';
import '../utils/api-customer-transfers.dart';
import '../utils/dto/api-response-balance.dart';
import '../utils/reference-generator.dart';
import '../utils/providers/provider-session.dart';

class QRPaymentMerchantScreen extends StatefulWidget {
  const QRPaymentMerchantScreen({super.key});

  @override
  State<QRPaymentMerchantScreen> createState() => _QRPaymentMerchantScreenState();
}

class _QRPaymentMerchantScreenState extends State<QRPaymentMerchantScreen> {

  int _sliderValue = 1200;
  double sliderMin = 5.0;
  double sliderMax = 10000.0;

  final apiCustomerAccounts = ApiCustomerAccounts();
  final apiCustomerFundsTransfer = ApiCustomerFundsTransfers();
  final referenceGenerator = ReferenceGenerator();

  String? selectedAccount;
  String debitAccountNumber ='';
  String loginId = 'FALSE';

  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0; // Stores the current page index
  late String _currentIndexAccountNumber;
  late String _currentIndexCurrency;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<SessionProvider>(context, listen: false);
    setState(() {
      _currentIndexAccountNumber = authProvider.user!.accounts[0].accountNumber;
      _currentIndexCurrency = authProvider.user!.accounts[0].currency;
    });
  }

  @override
  void initState(){
    super.initState();
    _loadSharedPreferencesValue();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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

  void _onPageChanged(int index, String account, String currency) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      if (kDebugMode) {
        print('Context is null');
      }
      throw Exception('Context is null');
    }
    setState(() {
      _currentIndex = index;
      _currentIndexAccountNumber = account;
      _currentIndexCurrency = currency;
    });
    //TODO - Change Balance Values
    //TODO - Change Recent Transactions Values - Mini Statements
  }

  Future<void> fetchAccountBalance(String accountNumber, String currency, String phone) async {
    try {
      var responseData = await apiCustomerAccounts.fetchAccountBalance(accountNumber, currency);
      if (responseData["data"]["response_code"] == "00") {
        TransactionResponse balance = TransactionResponse.fromJson(responseData);
        Provider.of<SessionProvider>(context, listen: false).setBalance(balance);
      }else{
        showSnackBar(context, responseData["data"]["response"], Colors.red);
      }
    } catch (error) {
      showSnackBar(context, error.toString(), Colors.red);
      throw Exception('FAILED to get balance : $error');
    }
  }

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SessionProvider>(context).user;
    final accounts = authProvider?.accounts;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.scanAQrCode),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 130,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  _onPageChanged(index,
                    authProvider.accounts[index].accountNumber,
                    authProvider.accounts[index].currency,
                  );
                },
                children: authProvider!.accounts.asMap().entries.map<Widget>((entry) {
                  int index = entry.key;
                  var account = entry.value;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _currentIndex = index; // Update when tapped
                        _currentIndexAccountNumber = account.accountNumber;
                        _currentIndexCurrency = account.currency;
                      });
                    },
                    child: _buildAccountCard(
                        account.accountType,
                        account.currency,
                        account.accountNumber,
                        authProvider.phoneNumber,
                        authProvider.token
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const MerchantDetails(),
            const SizedBox(height: 16),
             Text(AppLocalizations.of(context)!.howMuchWouldYouLikeToPay, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconButton(Icons.remove),
                Text(
                  "USD $_sliderValue",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                _buildIconButton(Icons.add),
              ],
            ),
            Slider(
              value: _sliderValue.toDouble(),
              min: sliderMin,
              max: sliderMax,
              activeColor: Colors.indigo,
              inactiveColor: Colors.indigo.withOpacity(0.2),
              onChanged: (double value) {
                setState(() {
                  _sliderValue = value.round();
                });
              },
            ),
            const SizedBox(height: 16),
             Text(AppLocalizations.of(context)!.selectDebitAccount),
            DropdownButtonFormField<String>(
              value: accounts?.any((a) => a.accountNumber == selectedAccount) == true
                  ? selectedAccount
                  : null,  // Avoid invalid value error
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              hint:  Text(AppLocalizations.of(context)!.selectDebitAccount),
              items: accounts?.map<DropdownMenuItem<String>>((account) {
                String maskedAccount =
                    "A/C #${account.accountNumber}";
                // String maskedAccount =
                //     "A/C #${account.accountNumber.substring(0, 4)}****${account.accountNumber.substring(account.accountNumber.length - 4)}";
                return DropdownMenuItem<String>(
                  value: account.accountNumber,
                  child: Text(maskedAccount),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedAccount = newValue;
                  debitAccountNumber = newValue!;
                });
              },
            ),
            const Spacer(),
            const PayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(String title, String currency, String account, String phone, String token) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'A/C # $account',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "Actual Balance\n$currency 100.00",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.indigo),
        onPressed: () {
          //TODO
          if(icon == Icons.add){
            //ADD
            setState(() {
              if(_sliderValue < sliderMax){
                /// Add as many as you want
                _sliderValue++;
              }
            });
          }else if(icon == Icons.remove){
            //REMOVE
            setState(() {
              if(_sliderValue > sliderMin){
                /// Subtract as many as you want
                _sliderValue--;
              }
            });
          }
        },
      ),
    );
  }

}

class MerchantDetails extends StatelessWidget {
  const MerchantDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.grey.shade300,
                child: const Text(
                  "AJ",
                  style: TextStyle(color: Colors.lightBlue, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12,),
          SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child:  Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.merchantDetails,
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    // Text("Merchant Name: Tasima Kumasi",
                    Text("${AppLocalizations.of(context)!.merchantName}: Tasima Kumasi",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text("Merchant ID: 2345678",style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

class PayButton extends StatelessWidget {
  const PayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          //TODO
        },
        child:  Text(AppLocalizations.of(context)!.pay, style: TextStyle(color: Colors.white, fontSize: 16 ,fontWeight: FontWeight.bold)),
      ),
    );
  }
}
