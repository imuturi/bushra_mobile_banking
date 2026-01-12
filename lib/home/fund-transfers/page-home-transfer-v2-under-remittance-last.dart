import 'package:bushra_mobile/home/fund-transfers/page-home-transfer-v2-under-remittance-pin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/api-customer-transfers.dart';
import '../../utils/dto/api-response-get-charges.dart';

class FundsTransferRemittanceLastScreen extends StatefulWidget {
  final String transactionReference;
  final String debitAccount;
  final String debitCurrency;
  final String debitAmount;
  final String convertedAmount;
  final String fees;
  final String exchangeRate;
  final String toCurrency;
  final String totalDebitAmount;
  final String beneficiaryNetAmount;
  final String phoneNumber;
  final String destinationChannelCode;
  final String destinationChannelName;
  final String destinationCountry;
  final String paymentMode;

  const FundsTransferRemittanceLastScreen({
    super.key,
    required this.transactionReference,
    required this.debitAccount,
    required this.debitCurrency,
    required this.debitAmount,
    required this.convertedAmount,
    required this.fees,
    required this.exchangeRate,
    required this.toCurrency,
    required this.totalDebitAmount,
    required this.beneficiaryNetAmount,
    required this.phoneNumber,
    required this.destinationChannelCode,
    required this.destinationChannelName,
    required this.destinationCountry,
    required this.paymentMode,
  });
  @override
  State<FundsTransferRemittanceLastScreen> createState() => _FundsTransferRemittanceLastScreenState();
}

class _FundsTransferRemittanceLastScreenState extends State<FundsTransferRemittanceLastScreen> {
  bool favouriteFlag = false;
  bool isFetchingCharges = false;
  String loginId = 'FALSE';
  FocusNode focusNode = FocusNode();
  final apiCustomerFundsTransfer = ApiCustomerFundsTransfers();

  TextEditingController beneficiaryPhoneNumber = TextEditingController();
  TextEditingController beneficiaryAccountNumber = TextEditingController();
  TextEditingController beneficiaryFullName = TextEditingController();
  TextEditingController beneficiaryNarration = TextEditingController();
  String phoneNumber = '';


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

  Future<void> _fetchCharges() async{
    try{
      setState(() {
        isFetchingCharges = true;
      });
      var response = await apiCustomerFundsTransfer.transactionCharges(
        'REMITTANCE',
        widget.debitAccount,
        widget.phoneNumber,
        widget.debitCurrency,
        double.tryParse(widget.debitAmount) ?? 0.0,
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
            transferAmount: "USD ${widget.debitAmount}",
            recipientAmount: widget.beneficiaryNetAmount,
            sourceAccount: widget.debitAccount,
            destinationAccount: beneficiaryAccountNumber.text.isEmpty ? phoneNumber : beneficiaryAccountNumber.text,
            phoneNumber: phoneNumber,
            charges: widget.exchangeRate,
            vat: "USD 0.00",
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  PinInputCommitTransactionRemittanceScreen(
                transferType: 'REMITTANCE',
                debitPhoneNumber: widget.phoneNumber,
                debitCustomerName: '',
                fromCurrency: widget.debitCurrency,
                toCurrency: widget.toCurrency,
                receiverPhoneNumber: phoneNumber.replaceFirst('+', ''),
                receiverAccountName: beneficiaryFullName.text.toString().toUpperCase().trim(),
                receiverAccount: beneficiaryAccountNumber.text,
                senderName: '',
                senderDOB: '',
                senderCountryISO: '',
                senderNationality: '',
                senderIDType: '',
                senderIDNumber: '',
                narration: beneficiaryNarration.text,
                isFavorite: favouriteFlag,
                transactionReference: widget.transactionReference,
                debitAccount:  widget.debitAccount,
                debitCurrency: widget.debitCurrency,
                debitAmount: double.tryParse(widget.debitAmount) ?? 0.0,
                convertedAmount: double.tryParse(widget.convertedAmount) ?? 0.0,
                destinationChannelCode: widget.destinationChannelCode,
                destinationChannelName: widget.destinationChannelName,
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

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          AppLocalizations.of(context)!.foreignRemittance,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 7),
            Text(AppLocalizations.of(context)!.fullName, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 3),
            _buildTextInputFieldGray('Enter the recipient full name', beneficiaryFullName, TextInputType.text),

            const SizedBox(height: 7),
            const Text("Recipient Mobile No", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 3),
            _buildTextInputFieldPhoneNumber('Enter Mpesa Number', beneficiaryPhoneNumber),

            // Only show Account Number if NOT mobile money
            if (!(widget.paymentMode == 'M-PESA' ||
                widget.paymentMode == 'AIRTEL MONEY' ||
                widget.paymentMode == 'MTN MONEY')) ...[
              const SizedBox(height: 7),
              const Text("Account Number", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 3),
              _buildTextInputFieldGray(
                'Enter the recipient account number',
                beneficiaryAccountNumber,
                TextInputType.text,
              ),
            ]
            else ...[

            ],

            // const SizedBox(height: 7),
            // const Text("Account Number", style: TextStyle(color: Colors.grey)),
            // const SizedBox(height: 3),
            // _buildTextInputFieldGray('Enter the recipient account number', beneficiaryAccountNumber, TextInputType.text),

            const SizedBox(height: 7),
            _buildInputField(AppLocalizations.of(context)!.narration, "Enter your narration here", beneficiaryNarration),
            const SizedBox(height: 7),

            const SizedBox(height: 100),
            // Transfer Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  if(beneficiaryFullName.text.isEmpty){
                    showSnackBar(context, 'Please enter the recipient full name', Colors.red);
                    return;
                  }
                  if(beneficiaryPhoneNumber.text.isEmpty){
                    showSnackBar(context, 'Please enter the recipient mobile number', Colors.red);
                    return;
                  }
                  if(phoneNumber.isEmpty || phoneNumber.length < 10){ //254 0718908314
                    showSnackBar(context, 'Please enter a valid mobile number $phoneNumber' , Colors.red);
                    return;
                  }
                  // if(!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(beneficiaryPhoneNumber.text)){
                  //   showSnackBar(context, 'Please enter a valid mobile number', Colors.red);
                  //   return;
                  // }

                  if(!(widget.paymentMode == 'M-PESA' || widget.paymentMode == 'AIRTEL MONEY' || widget.paymentMode == 'MTN MONEY')){
                    if(beneficiaryAccountNumber.text.isEmpty){
                      showSnackBar(context, 'Please enter the recipient account number', Colors.red);
                      return;
                    }
                    if(beneficiaryAccountNumber.text.length < 8){
                      showSnackBar(context, 'Account number is too short', Colors.red);
                      return;
                    }
                  }else{
                    // For mobile money, we can set the account number to be the phone number
                    beneficiaryAccountNumber.text = phoneNumber;
                  }
                  if(beneficiaryNarration.text.isEmpty){
                    showSnackBar(context, 'Please enter the narration', Colors.red);
                    return;
                  }
                  await _fetchCharges();
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
                )
                    :  Text(
                  AppLocalizations.of(context)!.transfer,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildTextInputFieldPhoneNumber(String hint, TextEditingController controller){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          IntlPhoneField(
            controller: controller,
            focusNode: focusNode,
            disableLengthCheck: true,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            pickerDialogStyle: PickerDialogStyle(
              searchFieldInputDecoration: InputDecoration(
                hintText: 'Search Country',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey.shade100,
                  ),
                ),
              ),
            ),
            // dropdownDecoration: BoxDecoration(
            //   border: Border.all(color: Colors.grey.shade900),
            // ),
            languageCode: "en",
            initialCountryCode: "KE",
            onChanged: (phone) {
              setState(() {
                phoneNumber = phone.completeNumber;
              });
            },
            onCountryChanged: (country) {
              if (kDebugMode) {
                print('Country changed to: ${country.name}');
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
              color: Colors.grey.shade400,
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

}

class ConfirmTransferDialog extends StatelessWidget {
  final String transferAmount;
  final String recipientAmount;
  final String sourceAccount;
  final String destinationAccount;
  final String phoneNumber;
  final String charges;
  final String vat;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmTransferDialog({
    super.key,
    required this.transferAmount,
    required this.recipientAmount,
    required this.sourceAccount,
    required this.destinationAccount,
    required this.phoneNumber,
    required this.charges,
    required this.vat,
    required this.onConfirm,
    required this.onCancel,
  });

  Widget _buildRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? Colors.black : Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.confirmTransfer,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.pleaseConfirmYouAreMakingRemittanceTransfer,
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const Divider(height: 24),

            // Details
            _buildRow("Transfer Amount", transferAmount, bold: true),
            _buildRow("Amount Recipient gets", recipientAmount, bold: true),
            _buildRow("Source of funds", sourceAccount),
            _buildRow("Destination Account", destinationAccount),
            _buildRow("Phone number", phoneNumber),
            _buildRow("Charges", charges),
            _buildRow("VAT(0%)", vat),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
