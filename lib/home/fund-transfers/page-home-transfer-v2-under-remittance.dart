
import 'package:bushra_mobile/home/fund-transfers/page-home-transfer-v2-under-remittance-last.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../utils/api-customer-transfers.dart';
import '../../utils/providers/provider-balances.dart';
import '../../utils/reference-generator.dart';
import '../../utils/providers/provider-session.dart';

class FundsTransferRemittanceScreen extends StatefulWidget {
  const FundsTransferRemittanceScreen({super.key});
  @override
  State<FundsTransferRemittanceScreen> createState() => _FundsTransferRemittanceScreenState();

}

class _FundsTransferRemittanceScreenState extends State<FundsTransferRemittanceScreen> {

  String loginId = 'FALSE';
  final apiCustomerFundsTransfer = ApiCustomerFundsTransfers();
  final referenceGenerator = ReferenceGenerator();

  TextEditingController beneficiaryAccountNumber = TextEditingController();
  TextEditingController beneficiaryAccountName = TextEditingController();
  TextEditingController beneficiaryNarration = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final List<double> quickAmounts = [50, 100, 500, 1000];
  double? selectedAmount;

  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;
  String _currentIndexAccountNumber = '';
  String _currentIndexCurrency = '';

  String? selectedAccount;
  String debitAccountNumber ='';
  String debitAccountCurrency ='';

  List<Map<String, dynamic>> remittanceTypes = [];
  List<Map<String, dynamic>> availablePaymentMethods = [];

  String? selectedCountry;
  String? selectedCountryCurrency;
  String? selectedPaymentMethod;

  String destinationChannelCode ='';
  String destinationChannelName ='';

  String fees = '0.0';
  String exchangeRate = '1 USD = 129 KES';
  String recipientGets = '0.0 KES';
  String convertedAmount = '0.0';

  Future<void> fetchCountriesAndPayments() async {
    try {
      final response = await apiCustomerFundsTransfer.getRemittanceTypes();
      if (response["remittanceTypes"] != null) {
        setState(() {
          remittanceTypes = List<Map<String, dynamic>>.from(response["remittanceTypes"]);
        });
      } else {
        print("API Error: ${response.statusCode}");
        showSnackBar(context, "API Error: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      print("Error fetching data: $e");
      showSnackBar(context, "Error fetching data: $e", Colors.red);
    }
  }

  Future<void> _callExchangeRatesApi(String amount) async {
    if(selectedCountryCurrency == null || selectedCountryCurrency!.isEmpty){
      return;
    }
    if(amount.isEmpty || double.tryParse(amount) == null || double.tryParse(amount)! <= 0){
      return;
    }
    if (_currentIndexAccountNumber.isEmpty || _currentIndexCurrency.isEmpty) {
      showSnackBar(context, "Please select an account first", Colors.red);
      return;
    }
    try {
      final response = await apiCustomerFundsTransfer.getRemittanceExchangeRates(
        _currentIndexAccountNumber,
        _currentIndexCurrency,
        selectedCountryCurrency ?? '',
        double.tryParse(amount) ?? 0.0,
        loginId,
      );
      if (response["data"]["response_code"] == "00") {
        setState(() {
          if(kDebugMode) {
            print("Converted: ${response["data"]["convertedAmount"]}");
            print("Currency: ${response["data"]["currency"]}");
            print("Charge: ${response["data"]["chargeAmount"]}");
            print("BuyRate: ${response["data"]["buyRate"]}");
          }
          double rate = (double.tryParse(response["data"]["convertedAmount"].toString()) ?? 0.0) /
              (double.tryParse(amount) ?? 1.0);

          fees = response["data"]["chargeAmount"].toString();
          exchangeRate = '1 $_currentIndexCurrency = ${response["data"]["buyRate"]} ${response["data"]["toCurrency"]}';
          recipientGets = '${response["data"]["convertedAmount"]} ${response["data"]["toCurrency"]}';
          convertedAmount = response["data"]["convertedAmount"].toString();
        });
      } else {
        showSnackBar(context, "API Error: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      showSnackBar(context, "Error fetching data: $e", Colors.red);
    }
  }

  @override
  void initState(){
    super.initState();
    _loadSharedPreferencesValue();
    fetchCountriesAndPayments();
    _amountController.addListener(() {
      final value = _amountController.text.trim();
      if (value.isNotEmpty) {
        setState(() {
          selectedAmount = double.tryParse(_amountController.text);
        });
        _callExchangeRatesApi(value);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final balanceProvider = Provider.of<BalanceProvider>(context, listen: false);
    if (balanceProvider.accounts.isNotEmpty && _currentIndexAccountNumber.isEmpty) {
      final firstAccount = balanceProvider.accounts.first;
      setState(() {
        _currentIndexAccountNumber = firstAccount.accountNumber ?? '';
        _currentIndexCurrency = firstAccount.currency ?? '';
      });
    }
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
  }

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
    });
  }

  String _maskAccount(String account) {
    if (account.length <= 4) return account;
    return '${"*" * 5}${account.substring(account.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SessionProvider>(context).user;
    final accounts = authProvider?.accounts;
    final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Foreign Remittance',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: remittanceTypes.isEmpty ?
          Center(child: CircularProgressIndicator(color: Colors.red.shade900,))
            :
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Swipe-able Account Cards
              SizedBox(
                height: 130,
                child: Consumer<BalanceProvider>(
                  builder: (context, balanceProvider, child) {
                    return PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        final account = balanceProvider.accounts[index]; // Get account from provider
                        _onPageChanged(index, account.accountNumber, account.currency);
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
                        if(account.accountType=='SAVING' || account.accountType=='SAVINGS' || account.accountType=='S'){
                          accountType = 'Saving AC';
                        }else if(account.accountType=='CURRENT' || account.accountType=='C'){
                          accountType = 'Current AC';
                        }else if(account.accountType=='DEPOSIT' || account.accountType=='D'){
                          accountType = 'Term Deposit AC';
                        }else{
                          accountType = account.accountType;
                        }
                        bool isActive = index == _currentIndex; // Check if this is the active card
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              _currentIndex = index;
                              _currentIndexAccountNumber = account.accountNumber;
                              _currentIndexCurrency = account.currency;
                            });
                          },
                          child: _buildAccountCard(
                            accountType,
                            account.currency,
                            account.accountNumber,
                            availableBalance,
                            isActive,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text('How much would you like to transfer?'),
              //TODO -- NEW ------------------------
              const SizedBox(height: 8),
              _buildTextInputFieldGrayAmountMain("Enter Amount", "eg 1000.00", _amountController, maxLines: 1),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'The minimum transfer amount is 0.1',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40, // Fixed height for the chip row
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: quickAmounts.map((amount) {
                      final isSelected = selectedAmount == amount;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(
                            '\$${amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _amountController.text = amount.toStringAsFixed(2);
                            });
                            // ✅ Call API immediately when quick amount is chosen
                            _callExchangeRatesApi(amount.toStringAsFixed(2));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: isSelected ? Colors.red.shade900 : Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          showCheckmark: false,
                          selectedColor: Colors.red.shade900,
                          backgroundColor: Colors.grey[200],
                          elevation: 2,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              //TODO -- NEW ------------------------
              const SizedBox(height: 7),
              const Text("Select the country", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 3),
              _buildTextInputDropDownFieldRedCountry(),

              const SizedBox(height: 7),
              const Text("Payment mode", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 3),
              _buildTextInputDropDownFieldRedPaymentMode(),

              const SizedBox(height: 7),
              const Text("Fee", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 3),
              _buildTextInputFieldGray(fees, beneficiaryAccountNumber, TextInputType.text),

              const SizedBox(height: 7),
              const Text("Exchange rate", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 3),
              _buildTextInputFieldGray(exchangeRate, beneficiaryAccountNumber, TextInputType.text),

              const SizedBox(height: 7),
              const Text("Recipient gets", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 3),
              _buildTextInputFieldGray(recipientGets, beneficiaryAccountNumber, TextInputType.text),

              const SizedBox(height: 10),
              // Transfer Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
                    //TODO
                    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null || double.tryParse(_amountController.text)! <= 0) {
                      showSnackBar(context, "Please enter a valid amount", Colors.red);
                      return;
                    }
                    if(selectedCountry == null || selectedCountry!.isEmpty){
                      showSnackBar(context, "Please select a country", Colors.red);
                      return;
                    }
                    if(selectedPaymentMethod == null || selectedPaymentMethod!.isEmpty){
                      showSnackBar(context, "Please select a payment mode", Colors.red);
                      return;
                    }
                    if (_currentIndexAccountNumber.isEmpty || _currentIndexCurrency.isEmpty) {
                      showSnackBar(context, "Please select a debit account", Colors.red);
                      return;
                    }
                    if(loginId.isEmpty || loginId == 'FALSE'){
                      showSnackBar(context, "User not logged in, please login again", Colors.red);
                      return;
                    }
                    if(recipientGets == '0.0 KES' || convertedAmount == '0.0'){
                      //showSnackBar(context, "Invalid amount to transfer, please check", Colors.red);
                      return;
                    }

                    String transactionReference = referenceGenerator.generateUniqueReference(false);
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  FundsTransferRemittanceLastScreen(
                      transactionReference: transactionReference,
                      phoneNumber: loginId,
                      debitAccount: _currentIndexAccountNumber,
                      debitCurrency: _currentIndexCurrency,
                      debitAmount: _amountController.text,
                      convertedAmount: convertedAmount,
                      fees: fees,
                      exchangeRate: exchangeRate,
                      toCurrency: selectedCountryCurrency ?? '',
                      totalDebitAmount: '${(double.tryParse(_amountController.text) ?? 0.0) + (double.tryParse(fees) ?? 0.0)}',
                      beneficiaryNetAmount: recipientGets,
                      destinationChannelCode: destinationChannelCode,
                      destinationChannelName: destinationChannelName,
                      destinationCountry: selectedCountry!,
                      paymentMode: selectedPaymentMethod!,
                    )));

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "CONTINUE",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              // Extra spacing at the bottom
              const SizedBox(height: 50),
            ],
          ),
      ),
    );
  }

  Widget _buildTextInputDropDownFieldRedCountry(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Select the country you are sending money to",
                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.normal)
            ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            value: selectedCountry,
            items: remittanceTypes.map((country) {
              return DropdownMenuItem<String>(
                value: country["country"],
                child: Text(country["country"],
                  style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.normal)
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCountry = newValue;
                selectedCountryCurrency = remittanceTypes.firstWhere((c) => c["country"] == newValue)["currency"];
                selectedPaymentMethod = null; // reset payment
                availablePaymentMethods = List<Map<String, dynamic>>.from(
                  remittanceTypes
                      .firstWhere((c) => c["country"] == newValue)["paymentMethods"],
                );
              });
            },
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.red.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputDropDownFieldRedPaymentMode(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Select the receiver payment mode",
                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.normal)
            ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            value: selectedPaymentMethod,
            items: availablePaymentMethods.map((pm) {
              return DropdownMenuItem<String>(
                value: pm["destinationChannelName"],
                child: Text(pm["destinationChannelName"],
                  style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.normal)
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedPaymentMethod = newValue;
                final selectedPM = availablePaymentMethods.firstWhere((pm) => pm["destinationChannelName"] == newValue);
                destinationChannelCode = selectedPM["destinationChannelCode"].toString();
                destinationChannelName = selectedPM["destinationChannelName"];
                _callExchangeRatesApi(_amountController.text.trim());
              });
            },
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.red.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputFieldGray(String hint, TextEditingController controller, TextInputType textInputType, {int maxLines = 1}){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: textInputType,
            readOnly: true, // 🔒 make input read-only
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputFieldGrayAmountMain(String label, String hint,TextEditingController controller, {int maxLines = 1}){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(
                Icons.attach_money,
                color: Colors.red.shade900,
              ),
              suffixIcon: _amountController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.red.shade900,
                ),
                onPressed: () {
                  _amountController.clear();
                },
              ) : null,
            ),
            onSubmitted: (value) {
              print('INPUT VALUE AMOUNT ===== : $value');
              if (value.isNotEmpty) {
                _callExchangeRatesApi(value);
              }
            },
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard1(String title, String currency, String account, double balance, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isActive ? Colors.red.shade900 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // const Icon(Icons.account_balance_wallet, size: 40, color: Colors.white),
          CircleAvatar(
            radius: 22,
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
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'A/C # $account',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Actual Balance\n$currency ${NumberFormat("#,##0.00").format(balance)}",
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
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

}