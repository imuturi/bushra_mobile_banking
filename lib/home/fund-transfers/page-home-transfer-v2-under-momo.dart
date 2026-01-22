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

class FundsTransferMomoScreen extends StatefulWidget {
  const FundsTransferMomoScreen({super.key});

  @override
  State<FundsTransferMomoScreen> createState() => _FundsTransferMomoScreenState();

}

class _FundsTransferMomoScreenState extends State<FundsTransferMomoScreen> {
  bool favouriteFlag = false;
  bool isFetchingCharges = false;
  String loginId = 'FALSE';

  final apiCustomerFundsTransfer = ApiCustomerFundsTransfers();
  final referenceGenerator = ReferenceGenerator();

  TextEditingController beneficiaryPhoneNumber = TextEditingController();
  TextEditingController beneficiaryNarration = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final List<double> quickAmounts = [50, 100, 500, 1000];
  double? selectedAmount;

  final PageController _pageControllerAccountCard = PageController(viewportFraction: 0.9);
  int _currentAccountCardIndex = 0; // Stores the current page index
  late String _currentAccountCardIndexAccountNumber;
  late String _currentAccountCardIndexCurrency;
  String? selectedAccount;
  String debitAccountNumber ='';
  String debitAccountCurrency ='';

  String? selectedOptionMobileSelf;
  String? selectedNetwork;
  bool showPhoneTextField = false;
  final List<Map<String, dynamic>> networks = [
    {"name": "SOMTEL", "icon": Icons.wifi},
    {"name": "Hormuud Telkom", "icon": Icons.network_cell},
    {"name": "Airtel", "icon": Icons.signal_cellular_alt},
    {"name": "AMTEL Telkom", "icon": Icons.wifi},
    {"name": "GOLIS Telkom", "icon": Icons.cell_tower},
  ];

  @override
  void initState(){
    setState(() {
      showPhoneTextField = false;
    });
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

  void _onPageAccountCardChanged(int index, String account, String currency) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      if (kDebugMode) {
        print('Context is null');
      }
      throw Exception('Context is null');
    }
    setState(() {
      _currentAccountCardIndex = index;
      _currentAccountCardIndexAccountNumber = account;
      _currentAccountCardIndexCurrency = currency;
    });
  }

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
    });
  }

  Future<void> _fetchCharges(String phone, String transactionReference, String crAccountNo) async{
    try{
      setState(() {
        isFetchingCharges = true;
      });
      var response = await apiCustomerFundsTransfer.transactionCharges(
        debitAccountNumber,
        crAccountNo,
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
            dialogDescription: "Please confirm you are making Mobile Money Transfer",
            amount: '$debitAccountCurrency ${_amountController.text}',
            recipientAccount: crAccountNo,
            sourceAccount: debitAccountNumber,
            charges: '$debitAccountCurrency ${transactionCharges.data?.chargeAmount.toString()}',
            onCancel: () {
              // Handle cancel
              Navigator.pop(context);
            },
            onConfirm: () {
              // Handle confirmation
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  PinInputCommitTransactionScreen(
                transferType: 'ACOOUNTTOMNOTRANSFER',
                transactionReference: transactionReference,
                debitAccount: debitAccountNumber,
                debitPhoneNumber: phone,
                beneficiaryAccount: crAccountNo,
                beneficiaryName: 'Mobile',
                currency: debitAccountCurrency,
                transactionAmount: selectedAmount.toString(),
                narration: beneficiaryNarration.text,
                telco: selectedNetwork,
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
          'Mobile money',
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
                      if(account.accountType=='SAVING' || account.accountType=='SAVINGS' || account.accountType=='S'){
                        accountType = 'Saving AC';
                      }else if(account.accountType=='CURRENT' || account.accountType=='C'){
                        accountType = 'Current AC';
                      }else if(account.accountType=='DEPOSIT' || account.accountType=='D'){
                        accountType = 'Term Deposit AC';
                      }else{
                        accountType = account.accountType;
                      }

                      bool isActive = index == _currentAccountCardIndex; // Check if this is the active card
                      return GestureDetector(
                        onTap: () async {
                          setState(() {
                            _currentAccountCardIndex = index;
                            _currentAccountCardIndexAccountNumber = account.accountNumber;
                            _currentAccountCardIndexCurrency = account.currency;
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
            const Text('How much would you like to transfer?'),
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
            const Text("Select MNO", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildTextInputDropDownFieldRed(),

            const SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: "self",
                      groupValue: selectedOptionMobileSelf,
                      onChanged: (value) {
                        setState(() {
                          selectedOptionMobileSelf = value;
                          showPhoneTextField = false;
                        });
                      },
                    ),
                    const Text("My number"),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: "other",
                      groupValue: selectedOptionMobileSelf,
                      onChanged: (value) {
                        setState(() {
                          selectedOptionMobileSelf = value;
                          showPhoneTextField = true;
                        });
                      },
                    ),
                    const Text("Other phone number"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 7),
            Visibility(
                visible: showPhoneTextField == true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Phone number', style: TextStyle(color: Colors.grey)),
                    _buildTextInputFieldGray('Eg. 252615566423', beneficiaryPhoneNumber, TextInputType.text),
                  ],
                ),
            ),
            const SizedBox(height: 7),
            const Text("Account from", style: TextStyle(color: Colors.grey)),
            _buildTextInputDropDownFieldGray(accounts),

            const SizedBox(height: 7),
            _buildInputField("Narration", "Eg. Reason", beneficiaryNarration),
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
                  String phone = phoneNumber;
                  if(phoneNumber.isEmpty || phoneNumber ==''){
                    phone = loginId;
                  }

                  String transactionReference = referenceGenerator.generateUniqueReference(false);
                  String drAccountNo = debitAccountNumber;
                  String crAccountNoSelf = phone;
                  String? crAccountNameSelf = authProvider?.customerDetails.firstName;

                  String crAccountNoOther = beneficiaryPhoneNumber.text;
                  String crAccountNameOther = 'Other';

                  String selectedNetworkValue = selectedNetwork!;

                  String crAccountNo = '';
                  String? crAccountName = '';
                  if(showPhoneTextField == false){
                    crAccountNo = crAccountNoSelf;
                    crAccountName = crAccountNameSelf;
                  }else{
                    crAccountNo = crAccountNoOther;
                    crAccountName = crAccountNameOther;
                  }

                  if(debitAccountNumber.isEmpty || debitAccountNumber.length<10){
                    showSnackBar(context, 'Invalid Debit Account Number $drAccountNo', Colors.red);
                    return;
                  }else if(crAccountNo.isEmpty || crAccountNo.length<11){
                    showSnackBar(context, 'Invalid Credit Phone Account Number $crAccountNo', Colors.red);
                    return;
                  }else if(crAccountName!.isEmpty || crAccountName.length<4){
                    showSnackBar(context, 'Invalid Credit Account Name', Colors.red);
                    return;
                  }else if(beneficiaryNarration.text.isEmpty || beneficiaryNarration.text.length<4){
                    showSnackBar(context, 'Invalid Narration values length', Colors.red);
                    return;
                  }else if(selectedNetworkValue.isEmpty || selectedNetworkValue == ''){
                    showSnackBar(context, 'Invalid Telco values', Colors.red);
                    return;
                  }else if(_amountController.text.isEmpty || _amountController.text == '0.00'){
                    showSnackBar(context, 'Invalid Transaction Amount', Colors.red);
                    return;
                  }
                  //TODO
                  _fetchCharges(
                    crAccountNo,
                    transactionReference,
                    drAccountNo,
                  );
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
                  ) :
                const Text(
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


  Widget _buildTextInputDropDownFieldRed(){
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
            hint: const Text("Select Network"),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            value: selectedNetwork,
            items: networks.map((network) {
              return DropdownMenuItem<String>(
                value: network["name"],
                child: Row(
                  children: [
                    Icon(network["icon"], color: Colors.blue), // Network icon
                    const SizedBox(width: 10),
                    Text(network["name"]), // Network name
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedNetwork = newValue;
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
            hint: const Text("Select account from"),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
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

  Widget _buildAccountCard1(String accountTitle, String currency, String account, double balance, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isActive ? Colors.red.shade900 : Colors.grey.shade400,
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
                  accountTitle,
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

//TODO - DOTTED DIVIDER
class DottedDivider extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const DottedDivider({
    super.key,
    this.height = 1.0,
    this.width = 5.0,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: DashPainter(width: width, color: color),
    );
  }
}

class DashPainter extends CustomPainter {
  final double width;
  final Color color;
  DashPainter({required this.width, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final space = width;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + width, size.height / 2),
        paint,
      );
      startX += width + space;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}