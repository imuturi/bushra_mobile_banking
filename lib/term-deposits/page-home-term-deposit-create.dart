import 'package:bushra_mobile/term-deposits/page-home-term-deposit-pin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../utils/api-customer-term-deposits.dart';
import '../utils/dto/api-response-login.dart';
import '../utils/reference-generator.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-get-imei.dart';
import '../widgets/dialog-error.dart';
import '../widgets/progress-dialog.dart';
import 'dto/td-class-response.dart';

class TermDepositCreateScreen extends StatefulWidget {
  const TermDepositCreateScreen({super.key});

  @override
  State<TermDepositCreateScreen> createState() => _TermDepositCreateScreenState();
}

class _TermDepositCreateScreenState extends State<TermDepositCreateScreen> {
  final referenceGenerator = ReferenceGenerator();
  final customerTermDepositApi = ApiCustomerTermDeposits();
  bool acceptedTerms = false;

  TextEditingController amountController = TextEditingController();
  TextEditingController profitRateController = TextEditingController();

  String? selectedDebitAccount;
  String debitAccountNumber='';
  String debitAccountCurrency ='';

  String? selectedCreditAccount;
  String creditAccountNumber='';
  String creditAccountCurrency ='';

  String? selectedTermDepositType;
  String? selectedTermDepositProfitRate;
  List<TermDepositClass> termDepositClassList = [];

  String? selectedMaturityInstructions;
  final List<Map<String, dynamic>> termMaturityInstructions = [
    {"name": "Renew principal & Profit"},
    {"name": "Renew principal only"},
    {"name": "Transfer to account"},
  ];

  @override
  void initState(){
    super.initState();
    _fetchTermDepositClass();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showErrorDialog(BuildContext context, String messageParent, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorAlertDialog(message: message, onRetry: onRetry, messageParent: messageParent,),
    );
  }

  void onRetry(){
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void showCrossingBallsProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CrossingBallsProgressDialog(message: message,),
    );
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

  Future<void> _fetchTermDepositClass() async {
    try {
      String deviceId = await DeviceIdentifier.getDeviceIdentifier();
      final response = await customerTermDepositApi.getTermDepositsClass(deviceId, referenceGenerator.generateUniqueReference(false));
      if(response['data']['response_code']=='00') {
        final tds = response['data']['term_deposits_class'] as List<dynamic>;
        setState(() {
          termDepositClassList = tds.map((loan) => TermDepositClass.fromJson(loan)).toList();
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {

    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SessionProvider>(context).user;
    final accounts = authProvider?.accounts;
    final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.createTermDeposit),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 16),
             Text(AppLocalizations.of(context)!.termDepositType, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildTextInputDropDownFieldRedTermDepositType(),

            const SizedBox(height: 8),
             Text(AppLocalizations.of(context)!.debitFrom, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildTextInputDropDownFieldRedAccountsDebit(accounts),

            const SizedBox(height: 7),
            _buildInputField(AppLocalizations.of(context)!.amount, "Eg. USD 50", amountController),

            const SizedBox(height: 8),
            _buildInputField("Profit Rate", "Eg. 50", profitRateController, maxLines: 1, readOnly: true),

            const SizedBox(height: 7),
            const Text("Maturity Instructions", style: TextStyle(color: Colors.grey)),
            _buildTextInputDropDownFieldGrayMaturityInstructions(),

            const SizedBox(height: 8),
            const Text("Payout Account", style: TextStyle(color: Colors.grey)),
            _buildTextInputDropdownFieldGrayAccountsCredit(accounts),

            const SizedBox(height: 12),
            _buildTermsCheckbox(
              value: acceptedTerms,
              onChanged: (val) {
                setState(() {
                  acceptedTerms = val ?? false;
                });
              },
            ),
            const SizedBox(height: 70),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //TODO VALIDATIONS
                  String debitAccountNumber = selectedDebitAccount ?? '';
                  String creditAccountNumber = selectedCreditAccount ?? '';
                  String termDepositType = selectedTermDepositType ?? '';
                  String maturityInstruction = selectedMaturityInstructions ?? '';
                  if(!acceptedTerms){
                    showSnackBar(context, 'You must accept terms and conditions', Colors.red);
                    return;
                  }
                  if(termDepositType.isEmpty || termDepositType == ''){
                    showSnackBar(context, 'Deposit Type has not been selected', Colors.red);
                    return;
                  }
                  if(amountController.text.isEmpty || amountController.text == ''){
                    showSnackBar(context, 'Please input amount', Colors.red);
                    return;
                  }
                  if(debitAccountNumber.isEmpty || debitAccountNumber== ''){
                    showSnackBar(context, 'Select debit account number', Colors.red);
                    return;
                  }
                  if(creditAccountNumber.isEmpty || creditAccountNumber== ''){
                    showSnackBar(context, 'Select deposit / maturity account number', Colors.red);
                    return;
                  }
                  if(maturityInstruction.isEmpty || maturityInstruction== ''){
                    showSnackBar(context, 'Select maturity instructions', Colors.red);
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PinInputCommitTDScreen(
                    transferType: 'CREATETERMDEPOSIT',
                    transactionReference: referenceGenerator.generateUniqueReference(false),
                    debitAccountNumber: debitAccountNumber,
                    creditAccountNumber: creditAccountNumber,
                    transactionCurrency: debitAccountCurrency,
                    termDepositType: termDepositType,
                    maturityInstruction: maturityInstruction,
                    debitPhoneNumber: phoneNumber,
                    amount: amountController.text,
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
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {int maxLines = 1,bool readOnly = false,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
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

  Widget _buildTextInputDropDownFieldRedTermDepositType() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
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
            hint: const Text("Eg Monthly", style: TextStyle(fontSize: 12),),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            value: selectedTermDepositType,
            items: termDepositClassList.map((term) {
              return DropdownMenuItem<String>(
                value: term.accountClass,
                child: Text(term.description, style: TextStyle(fontSize: 12),),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedTermDepositType = newValue!;
                final selectedItem = termDepositClassList.firstWhere(
                      (item) => item.accountClass == newValue,
                );
                selectedTermDepositProfitRate = selectedItem.profitRate;
                profitRateController.text = selectedTermDepositProfitRate!;
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
  }

  Widget _buildTextInputDropDownFieldGrayMaturityInstructions(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint:  Text(AppLocalizations.of(context)!.selectMaturityTenure, style: TextStyle(fontSize: 12),),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            value: selectedMaturityInstructions,
            items: termMaturityInstructions.map((termType) {
              return DropdownMenuItem<String>(
                value: termType["name"],
                child: Row(
                  children: [
                    Text(termType["name"], style: TextStyle(fontSize: 12),), // Network name
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedMaturityInstructions = newValue!;
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

  Widget _buildTextInputDropDownFieldRedAccountsDebit(List<Account>? accounts){
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            value: accounts?.any((a) => a.accountNumber == selectedDebitAccount) == true
                ? selectedDebitAccount
                : null,  // Avoid invalid value error
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint:  Text(AppLocalizations.of(context)!.selectAnAccount, style: TextStyle(fontSize: 12),),
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
                selectedDebitAccount = newValue;
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
              color: Colors.red.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputDropdownFieldGrayAccountsCredit(List<Account>? accounts){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            value: accounts?.any((a) => a.accountNumber == selectedCreditAccount) == true
                ? selectedCreditAccount
                : null,  // Avoid invalid value error
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint:  Text(AppLocalizations.of(context)!.payoutAccount, style: TextStyle(fontSize: 12),),
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
                selectedCreditAccount = newValue;
                creditAccountNumber = newValue!;
                creditAccountCurrency = accounts?.firstWhere((account) => account.accountNumber == newValue).currency ?? '';
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

  Widget _buildTermsCheckbox({
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.red.shade900,
        ),
         Expanded(
          child: Text(
            AppLocalizations.of(context)!.acceptTermsAndConditions,
            style: TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

}


