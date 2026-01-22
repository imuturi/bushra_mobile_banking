import 'package:bushra_mobile/bill-payment/page-home-bill-payment-pin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api-billers.dart';
import '../utils/dto/api-response-login.dart';
import '../utils/providers/provider-balances.dart';
import '../utils/reference-generator.dart';
import '../utils/providers/provider-session.dart';
import '../main.dart';
import '../widgets/dialog-transaction-charges.dart';
import 'api/dto-get-biller.dart';

class PayBillGovtBillScreen extends StatefulWidget {
  const PayBillGovtBillScreen({super.key});

  @override
  State<PayBillGovtBillScreen> createState() => _PayBillGovtBillScreenState();

}

class _PayBillGovtBillScreenState extends State<PayBillGovtBillScreen> {
  bool favouriteFlag = false;
  String loginId = 'FALSE';

  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;
  late String _currentIndexAccountNumber;
  late String _currentIndexCurrency;



  final referenceGenerator = ReferenceGenerator();
  final apiBillers = ApiBillers();
  Biller? selectedBiller;
  late Future<List<Biller>> futureBillers;

  TextEditingController billCommonField = TextEditingController();
  TextEditingController billNarration = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final List<double> quickAmounts = [50, 100, 500, 1000];
  double? selectedAmount;
  String selectedAccount ='';
  String debitAccountNumber ='';
  String debitAccountCurrency ='';

  @override
  void initState(){
    super.initState();
    futureBillers = fetchBillers("GOVERNMENT");
    _loadSharedPreferencesValue();
    _amountController.addListener(() {
      setState(() {
        selectedAmount = double.tryParse(_amountController.text);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    billCommonField.dispose();
    billNarration.dispose();
    _amountController.dispose();
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

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
    });
  }

  Future<List<Biller>> fetchBillers(String category) async {
    final dynamic response = await apiBillers.fetchBillers(category);
    if (response != null &&
        response is Map<String, dynamic> &&
        response.containsKey('billers')) {
      final List<dynamic> billersJson = response['billers'];
      return billersJson
          .map((item) => Biller.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Invalid response format");
    }
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
          'Government payment',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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

                      bool isActive = index == _currentIndex;
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
                          isActive
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            const Text("Select Government Payment", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildBillersDropDown(),

            const SizedBox(height: 10),
            const Text("Enter the name you registered with/enter your company name", style: TextStyle(color: Colors.grey)),
            _buildTextInputFieldGray('Eg Mohamed Abdi Fara', billCommonField, TextInputType.text),

            const SizedBox(height: 8),
            const Text("Select Debit Account", style: TextStyle(color: Colors.grey)),
            _buildTextInputDropDownFieldGray(accounts),

            const SizedBox(height: 12),
            // Amount Section
            const Text('How much would you like to pay?'),
            //TODO -- NEW ------------------------
            const SizedBox(height: 8),
            _buildTextInputFieldGrayAmount("Enter Amount", "eg 1000.00", _amountController, maxLines: 1),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'The minimum transfer amount is 0.1',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 48, // Fixed height for the chip row
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
                            fontSize: 15,
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _amountController.text = amount.toStringAsFixed(2);
                          });
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

            const SizedBox(height: 10),
            const Text("Narration", style: TextStyle(color: Colors.grey)),
            _buildTextInputFieldGray('Eg Reason', billNarration, TextInputType.text),

            const SizedBox(height: 7),
            // Add to Favourite Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Add to favourite", style: TextStyle(color: Colors.grey)),
                Transform.scale(
                  scale: 0.7, // Adjust this value to change the size (0.7 means 70% of the original size)
                  child: Switch(
                    value: favouriteFlag,
                    onChanged: (value) {
                      setState(() {
                        favouriteFlag = value;
                      });
                    },
                    activeColor: Colors.blue.shade700,
                    inactiveTrackColor: Colors.grey.shade100,
                    inactiveThumbColor: Colors.grey.shade700,
                    activeTrackColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Transfer Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  //TODO
                  String phone = '';
                  if(phoneNumber.isEmpty || phoneNumber ==''){
                    if(loginId != 'FALSE'){
                      phone = loginId;
                    }else{
                      phone = phoneNumber;
                    }
                  }else{
                    phone = phoneNumber;
                  }

                  String debitAccountNumber = selectedAccount;
                  String billerId = selectedBiller?.billerId ?? '';
                  String billerCommonField = billCommonField.text;
                  String billerCollectionAccount = selectedBiller?.billerAccount ?? '';
                  String billerCategory = selectedBiller?.category ?? '';
                  String narration = billNarration.text;
                  String transactionReference = referenceGenerator.generateUniqueReference(false);
                  if(debitAccountNumber.isEmpty || debitAccountNumber.length<10){
                    showSnackBar(context, 'Invalid Debit Account Number', Colors.red);
                    return;
                  }else if(billerId.isEmpty || billerId =='' || billerId == 'Select biller'){
                    showSnackBar(context, 'Invalid Biller Company Name Selected', Colors.red);
                    return;
                  }else if(billerCommonField.isEmpty || billerCommonField == ''){
                    showSnackBar(context, 'Invalid Bill Common Field Value', Colors.red);
                    return;
                  }else if(_amountController.text.isEmpty || _amountController.text == '') {
                    showSnackBar(
                        context, 'Invalid Amount Selected', Colors.red);
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (context) => ConfirmTransferDialog(
                      dialogDescription: "Please confirm you are making a government bill payment",
                      amount: '$debitAccountCurrency ${_amountController.text}',
                      recipientAccount: billerCollectionAccount,
                      sourceAccount: debitAccountNumber,
                      charges: "USD 0.00",
                      onCancel: () {
                        // Handle cancel
                        Navigator.pop(context);
                      },
                      onConfirm: () {
                        // Handle confirmation
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  PinInputCommitBillPaymentTransactionScreen(
                          transferType: 'GOVERNMENT',
                          debitAccountNumber: debitAccountNumber,
                          debitPhoneNumber: phone,
                          transactionAmount: selectedAmount!.toDouble(),
                          transactionCurrency: debitAccountCurrency,
                          transactionNarration: narration.isEmpty ? 'Government Bill Payment' : narration,
                          billerId: billerId,
                          billerCollectionaccount: billerCollectionAccount,
                          billerCategory: billerCategory,
                          billerCommonField: billerCommonField,
                          billerReference: transactionReference,
                          favouriteFlag: favouriteFlag,
                        )
                        ));
                      },
                    ),
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
                  "PAY",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            // Spacing at the bottom
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildBillersDropDown() {
    return FutureBuilder<List<Biller>>(
      future: futureBillers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.red,),
            textAlign: TextAlign.center,
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No billers found.',
            style: TextStyle(color: Colors.red,),
            textAlign: TextAlign.center,
          );
        }

        final billers = snapshot.data!;
        return Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              DropdownButtonFormField<Biller>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.red.shade50,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                hint: const Text("Select biller", style: TextStyle(fontSize: 12),),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down),
                value: selectedBiller,
                items: billers.map((biller) {
                  return DropdownMenuItem<Biller>(
                    value: biller,
                    child: Text(biller.description, style: TextStyle(fontSize: 12),),
                  );
                }).toList(),
                onChanged: (Biller? newValue) {
                  setState(() {
                    selectedBiller = newValue;
                  });
                },
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 0,
                child: Container(
                  height: 1,
                  color: Colors.red.shade900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextInputDropDownFieldGray(List<Account>? accounts){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
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
            hint: const Text("Select account from", style: TextStyle(fontSize: 12),),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            items: accounts?.map<DropdownMenuItem<String>>((account) {
              String maskedAccount =
                  "A/C #${account.accountNumber}";
              // String maskedAccount =
              //     "A/C #${account.accountNumber.substring(0, 4)}****${account.accountNumber.substring(account.accountNumber.length - 4)}";
              return DropdownMenuItem<String>(
                value: account.accountNumber,
                child: Text(maskedAccount, style: TextStyle(fontSize: 12),),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedAccount = newValue!;
                debitAccountNumber = newValue;
                debitAccountCurrency = accounts?.firstWhere((account) => account.accountNumber == newValue).currency ?? '';
              });
            },
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.grey.shade900,
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
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputFieldGrayAmount(String label, String hint,TextEditingController controller, {int maxLines = 1}){
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
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFieldNumber(String label, String hint,TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
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
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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