import 'package:bushra_mobile/home/fund-transfers/page-home-transfer-v2-pin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../utils/api-customer-transfers.dart';
import '../../utils/dto/api-response-get-charges.dart';
import '../../utils/dto/api-response-login.dart';
import '../../utils/providers/provider-balances.dart';
import '../../utils/reference-generator.dart';
import '../../utils/providers/provider-session.dart';
import '../../widgets/dialog-transaction-charges.dart';

class FundsTransferOwnScreen extends StatefulWidget {
  const FundsTransferOwnScreen({super.key});

  @override
  State<FundsTransferOwnScreen> createState() => _FundsTransferOwnScreenState();

}

class _FundsTransferOwnScreenState extends State<FundsTransferOwnScreen> {
  bool favouriteFlag = false;
  bool isFetchingCharges = false;
  String loginId = 'FALSE';

  final apiCustomerFundsTransfer = ApiCustomerFundsTransfers();
  final referenceGenerator = ReferenceGenerator();

  TextEditingController beneficiaryAccount = TextEditingController();
  TextEditingController beneficiaryAccountName = TextEditingController();
  TextEditingController beneficiaryNarration = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final List<double> quickAmounts = [50, 100, 500, 1000];
  double? selectedAmount;

  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0; // Stores the current page index
  late String _currentIndexAccountNumber;
  late String _currentIndexCurrency;
  String? selectedAccountDebit;
  String? selectedAccountCredit;
  String debitAccountNumber='';
  String debitAccountCurrency ='';
  String creditAccountNumber='';

  @override
  void initState(){
    super.initState();
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
  }

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
    });
  }

  Future<void> _fetchCharges(String phone, String transactionReference, String beneficiaryName) async{
    try{
      setState(() {
        isFetchingCharges = true;
      });
      var response = await apiCustomerFundsTransfer.transactionCharges(
        debitAccountNumber,
        beneficiaryAccount.text,
        phone,
        debitAccountCurrency,
        selectedAmount!,
      );
      ApiResponseGetTransactionCharges transactionCharges = ApiResponseGetTransactionCharges.fromJson(response);
      if(transactionCharges.data == null){
        showSnackBar(context, 'Failed to Fetch Charges', Colors.red);
        setState(() {
          isFetchingCharges = false;
        });
        return;
      }
      if(transactionCharges.data?.response == null){
        showSnackBar(context, 'Failed to Fetch Charges', Colors.red);
        setState(() {
          isFetchingCharges = false;
        });
        return;
      }

      if(transactionCharges.data?.responseCode == '00'){
        showDialog(
          context: context,
          builder: (context) => ConfirmTransferDialog(
            dialogDescription: "Please confirm you are making an own Transfer",
            amount: '$debitAccountCurrency ${_amountController.text}',
            recipientAccount: creditAccountNumber,
            sourceAccount: debitAccountNumber,
            charges: '$debitAccountCurrency ${transactionCharges.data?.chargeAmount.toString()}',
            onCancel: () {
              // Handle cancel
              Navigator.pop(context);
            },
            onConfirm: () {
              // Handle confirmation
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  PinInputCommitTransactionScreen(
                transferType: 'INTERNALFUNDSTRANSFER-SELF',
                transactionReference: transactionReference,
                debitAccount: debitAccountNumber,
                debitPhoneNumber: phone,
                beneficiaryAccount: creditAccountNumber,
                beneficiaryName: beneficiaryName,
                currency: debitAccountCurrency,
                transactionAmount: selectedAmount.toString(),
                narration: beneficiaryNarration.text,
                isFavorite: favouriteFlag,
              )
              ));
            },
          ),
        );
      }else{
        showSnackBar(context, 'Failed to Fetch Charges', Colors.red);
        setState(() {
          isFetchingCharges = false;
        });
      }
    }
    catch(e){
      showSnackBar(context, 'Failed to Fetch Charges.$e', Colors.red);
      setState(() {
        isFetchingCharges = false;
      });
    }finally{
      setState(() {
        isFetchingCharges = false;
      });
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Own transfer',
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
            const SizedBox(height: 12),
            //TODO -- NEW ------------------------
            Text('Enter Transfer Amount',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14,),
            ),
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
            const Text("Account from", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildTextInputDropdownFieldRed(accounts),
            const SizedBox(height: 7),
            const Text("Account to", style: TextStyle(color: Colors.grey)),
            _buildTextInputDropdownFieldGray(accounts),
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
            const SizedBox(height: 40),
            // Transfer Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  //TODO
                  String transactionReference = referenceGenerator.generateUniqueReference(false);
                  if(debitAccountNumber.isEmpty || debitAccountNumber.length<10){
                    showSnackBar(context, 'Invalid Debit Account Number', Colors.red);
                    return;
                  }else if(creditAccountNumber.isEmpty || creditAccountNumber.length<10){
                    showSnackBar(context, 'Invalid Credit Account Number', Colors.red);
                    return;
                  }else if(_amountController.text.isEmpty || _amountController.text == '0.00'){
                    showSnackBar(context, 'Invalid Transaction Amount', Colors.red);
                    return;
                  }else if(debitAccountNumber == creditAccountNumber) {
                    showSnackBar(
                        context, 'Debit and Credit Account cannot be the same',
                        Colors.red);
                    return;
                  }

                  String phone = phoneNumber;
                  if(phoneNumber.isEmpty || phoneNumber ==''){
                    phone = loginId;
                  }
                  //TODO
                  _fetchCharges(phone, transactionReference, '${authProvider?.customerDetails.firstName} ${authProvider?.customerDetails.lastName}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isFetchingCharges ?
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ) : const Text(
                  "TRANSFER",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            // Extra spacing at the bottom
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputDropdownFieldRed(List<Account>? accounts){
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            value: accounts?.any((a) => a.accountNumber == selectedAccountDebit) == true
                ? selectedAccountDebit
                : null,  // Avoid invalid value error
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Account from", style: TextStyle(fontSize: 12),),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            items: accounts?.map<DropdownMenuItem<String>>((account) {
              String maskedAccount =
                  "A/C #${account.accountNumber.substring(0, 4)}****${account.accountNumber.substring(account.accountNumber.length - 4)}";
              return DropdownMenuItem<String>(
                value: account.accountNumber,
                child: Text(maskedAccount, style: TextStyle(fontSize: 12),),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedAccountDebit = newValue;
                debitAccountNumber = newValue!;
                debitAccountCurrency = accounts?.firstWhere((a) => a.accountNumber == newValue).currency ?? '';
              });
            },
          ),
          Positioned(
            left: 10, // Aligning with the inner curve
            right: 10, // Aligning with the inner curve
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.red.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputDropdownFieldGray(List<Account>? accounts){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            value: accounts?.any((a) => a.accountNumber == selectedAccountCredit) == true
                ? selectedAccountCredit
                : null,  // Avoid invalid value error
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Account to", style: TextStyle(fontSize: 12),),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            items: accounts?.map<DropdownMenuItem<String>>((account) {
              String maskedAccount =
                  "A/C #${account.accountNumber.substring(0, 4)}****${account.accountNumber.substring(account.accountNumber.length - 4)}";
              return DropdownMenuItem<String>(
                value: account.accountNumber,
                child: Text(maskedAccount, style: TextStyle(fontSize: 12),),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedAccountCredit = newValue;
                creditAccountNumber = newValue!;
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