import 'package:bushra_mobile/loans/page-home-loan-payment-pin.dart';
import 'package:bushra_mobile/loans/page-home-loans-schedule.dart';
import 'package:bushra_mobile/loans/page-home-loans-statement.dart';
import 'package:bushra_mobile/loans/widget-loan-status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../utils/api-customer-loans.dart';
import '../utils/dto/api-response-login.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-log-service.dart';
import '../widgets/dialog-error.dart';
import '../widgets/progress-dialog.dart';
import 'dto/loan-accounts-response.dart';
import 'dto/loan-accounts-schedule-response.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  int selectedIndex = 0; // Tracks the selected tab

  //TODO - for LOAN STATEMENT
  final TextEditingController _loanTypeController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();

  final TextEditingController _loanTypeRepaymentController = TextEditingController();
  final TextEditingController _loanRepaymentDrAccountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final List<double> quickAmounts = [50, 100, 500, 1000];
  double? selectedAmount;

  String selectedValueFullPartial = 'full';

  bool isLoading = false;
  bool _isLoadingLoans = true;
  String loginId = 'FALSE';
  String loginPin = 'FALSE';

  Uuid uuid = const Uuid();

  //FOR drop downs
  final apiCustomerLoans = ApiCustomerLoans();
  String selectedCustomerAccount ='';
  String selectedRepaymentLoanAccount = '';
  List<LoanAccount> loanAccountsList = [];

  //STATEMENT VARIABLES
  String selectedStartDate = '';
  String selectedEndDate ='';


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
        _fetchLoans();
      }
    });
  }

  //Fetch Loans & Loan Status Api
  Future<void> _fetchLoans() async {
    try{
      setState(() {
        _isLoadingLoans = true; // Set loading to true when starting
      });
      final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
      final accounts = authProvider?.accounts;
      final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
      String cif = '';
      if(accounts!.isNotEmpty){
        String account = accounts.first.accountNumber.toString();
        cif = account.substring(3, account.length - 3);
      }
      final response = await apiCustomerLoans.getCustomerLoans(cif);
      if(response['data']['response_code']=='00'){
        final dynamic loansData = response['data']['loans'];
        List<dynamic> loans = [];
        if (loansData is Map && loansData.containsKey('loan')) {
          loans = loansData['loan'] as List<dynamic>;
        } else if (loansData is List) {
          loans = loansData;
        }
        setState(() {
          loanAccountsList = loans.map((loan) => LoanAccount.fromJson(loan)).toList();
          _isLoadingLoans = false;
        });
      }else{
        setState(() {
          _isLoadingLoans = false; // Set loading to false on error too
        });
        showSnackBar(context, 'Error Loading Loans ${response['data']['response']}', Colors.red);
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      setState(() {
        _isLoadingLoans = false; // Set loading to false on error too
      });
      print(error);
      showSnackBar(context, 'Error Loading Loans ${error.toString()}', Colors.red);
    }
  }

  @override
  void dispose() {
    _loanTypeController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
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

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
      loginPin = prefs.getString('USER_LOGIN_PIN') ?? "FALSE";
    });
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
        title: Text(
          AppLocalizations.of(context)!.loans,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Scrollable Tabs
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab('Loan Status', 0, Icons.hourglass_top),
                _buildTab('Loan Repayment', 1, Icons.monetization_on_outlined),
                _buildTab('Statements', 2, Icons.receipt_long),
                _buildTab('Payment Schedule', 3, Icons.calendar_today_outlined),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              selectedIndex == 0
                  ? 'Loan Status'
                  : selectedIndex == 1
                  ? 'Loan Repayment'
                  : selectedIndex == 2
                  ? 'Statements'
                    : 'Payment Schedule',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: selectedIndex == 0
            //TODO - INDEX-0 ----------------------------- Loan Status
                ? _mainTabLoanStatus()
            //TODO - INDEX-1 ----------------------------- Loan Repayment
                : selectedIndex == 1
                ? _mainTabLoanRepayment()
            //TODO - INDEX-2 ----------------------------- Loan Statements
                : selectedIndex == 2
                ? _mainTabLoanStatement()
            //TODO - INDEX-3 ----------------------------- Payment Schedule
                : _mainTabLoanPaymentSchedule(),
          ),
        ],
      ),
    );
  }
  // Function to build tabs
  Widget _buildTab(String label, int index, IconData icon,) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index; // Change selected tab
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          height: 108,
          width: 158,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo.shade800 : Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.indigo.shade300,
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10), // Adds spacing between avatar and text
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //TODO - (1 )LOAN STATUS WIDGET
  Widget _mainTabLoanStatus() {
    return Column(
      children: [
        const SizedBox(height: 16),
        LoanDetailsWidget(
          hintText: AppLocalizations.of(context)!.selectTheLoan, // Optional custom hint
          // loansData: yourCustomLoansData, // Optional custom data
          loanAccountsList: loanAccountsList, // Use the fetched loan accounts
        ),
      ],
    );
  }
  Widget _mainTabLoanStatusXXXX() {
    final authProvider = Provider.of<SessionProvider>(context).user;
    final accounts = authProvider?.accounts;
    final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: _isLoadingLoans
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: CircularProgressIndicator(color: Colors.red.shade900,),
          ),
        )
            : Table(
          border: TableBorder.all(color: Colors.transparent),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.5),
          },
          children: [
            _buildTableHeader(),
            ...loanAccountsList.asMap().entries.map((entry) {
              final index = entry.key;
              final loan = entry.value;
              final last4 = loan.loanAccount.length >= 4
                  ? loan.loanAccount.substring(loan.loanAccount.length - 4)
                  : loan.loanAccount;

              return _buildTableRow(
                'A/C **$last4',
                '${loan.currency} ${loan.amountFinanced}',
                '${loan.currency} ${loan.amountDue}',
                "View",
                index % 2 == 0, // Highlight every even ROW
                onViewTap: () {
                  print('Tapped View for loan ${loan.loanAccount}');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoanScheduleScreen(
                    loanAccountsList: loanAccountsList,
                    loanAccount: loan.loanAccount,
                  )));
                },
              );
            }),
          ],
        ),
      ),
    );
  }
  Widget _mainTabLoanStatus1() {
    final authProvider = Provider.of<SessionProvider>(context).user;
    final accounts = authProvider?.accounts;
    final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(color: Colors.transparent),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.5),
          },
          children: [
            _buildTableHeader(),
            ...loanAccountsList.asMap().entries.map((entry) {
              final index = entry.key;
              final loan = entry.value;
              final last4 = loan.loanAccount.length >= 4
                  ? loan.loanAccount.substring(loan.loanAccount.length - 4)
                  : loan.loanAccount;

              return _buildTableRow(
                'A/C **$last4',
                '${loan.currency} ${loan.amountFinanced}',
                '${loan.currency} ${loan.amountDue}',
                "View",
                index % 2 == 0, // Highlight every even ROW
                onViewTap: () {
                  print('Tapped View for loan ${loan.loanAccount}');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoanScheduleScreen(
                    loanAccountsList: loanAccountsList,
                    loanAccount: loan.loanAccount,
                  )));
                  // You can navigate or show a details dialog here
                },
              );
            }),
          ],
        ),
      ),
    );
  }
  TableRow _buildTableRow(
      String loanAccount,
      String loanAmount,
      String loanOutstanding,
      String viewMoreText,
      bool highlight, {
        VoidCallback? onViewTap,
      }) {
    final backgroundColor = highlight ? Colors.white : const Color(0xFFF5F5F5); // Light grey
    return TableRow(
      decoration: BoxDecoration(color: backgroundColor),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(loanAccount,
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(loanAmount,
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(loanOutstanding,
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: onViewTap,
            child: Text(
              viewMoreText,
              style: const TextStyle(
                color: Colors.blue,
                //decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
  //TODO - (2 )LOAN REPAYMENT WIDGET
  Widget _mainTabLoanRepayment(){
    final authProvider = Provider.of<SessionProvider>(context).user;
    final accounts = authProvider?.accounts;
    final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
           Text(AppLocalizations.of(context)!.selectLoanAccount, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          _buildTextInputDropDownFieldRedRepayment(),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.debitFrom, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          _buildTextInputDropDownFieldGrayRepayment(accounts!),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.howMuchWouldYouLikeToRepay, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          //TODO -- NEW ------------------------
          Text(AppLocalizations.of(context)!.enterTransferAmount,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14,),
          ),
          const SizedBox(height: 8),
          _buildTextInputFieldGrayAmount(AppLocalizations.of(context)!.enterTransferAmount, "eg 1000.00", _amountController, maxLines: 1),
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
          //const Spacer(),
          const SizedBox(height: 24,),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO
                if(selectedAmount == 0){
                  showSnackBar(context, 'Invalid Repayment Loan Amount', Colors.red);
                  return;
                }
                if(selectedCustomerAccount == '' || selectedCustomerAccount.isEmpty){
                  showSnackBar(context, 'Invalid Debit Account Number', Colors.red);
                  return;
                }
                if(selectedRepaymentLoanAccount == '' || selectedRepaymentLoanAccount.isEmpty){
                  showSnackBar(context, 'Invalid Loan Account Number', Colors.red);
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (context) => PinInputLoanRepaymentScreen(
                  transferType: 'LOANREPAYMENT',
                  debitAccountNumber: selectedCustomerAccount,
                  creditAccountNumber: selectedRepaymentLoanAccount,
                  debitPhoneNumber: phoneNumber,
                  transactionAmount: selectedAmount!,
                  transactionCurrency: 'USD',
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
                'PAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 50,)
        ]
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
  Widget _buildTextInputDropDownFieldRedRepayment(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            value: loanAccountsList.any((a) => a.loanAccount == selectedRepaymentLoanAccount)
                ? selectedRepaymentLoanAccount
                : null, // Avoid invalid value error
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Eg. Loan account", style: TextStyle(fontSize: 12),),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            items: loanAccountsList.map<DropdownMenuItem<String>>((account) {
              return DropdownMenuItem<String>(
                value: account.loanAccount,
                child: Text("${account.loanAccount} (${account.currency})", style: TextStyle(fontSize: 12),),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedRepaymentLoanAccount = newValue!;
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
  Widget _buildTextInputDropDownFieldGrayRepayment(List<Account> accounts){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            value: accounts.any((a) => a.accountNumber == selectedCustomerAccount) == true
                ? selectedCustomerAccount
                : null,  // Avoid invalid value error
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Eg. Current AC #0001*****111", style: TextStyle(fontSize: 12),),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            items: accounts.map<DropdownMenuItem<String>>((account) {
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
                selectedCustomerAccount = newValue!;
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
  //TODO - (3 )LOAN STATEMENT WIDGET
  Widget _mainTabLoanStatement(){
    final authProvider = Provider.of<SessionProvider>(context).user;
    final accounts = authProvider?.accounts;
    final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8,),
          Text(AppLocalizations.of(context)!.selectLoanType, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          _buildTextInputDropDownFieldRedRepayment(),
          const SizedBox(height: 8,),
           Text(AppLocalizations.of(context)!.selectStartDate, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Stack(
            children: [
              TextField(
                controller: _dateStartController,
                maxLines: 1,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Eg 01-01-2025',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900), // Earliest selectable date
                        lastDate: DateTime.now(),
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
                        },// Prevent future dates
                      );
                      if (pickedDate != null) {
                        _dateStartController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        setState(() {
                          selectedStartDate = _dateStartController.text;
                        });
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 0,
                child: Container(
                  height: 1,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
           Text(AppLocalizations.of(context)!.selectEndDate, style: TextStyle(color: Colors.grey)),
          Stack(
            children: [
              TextField(
                controller: _dateEndController,
                maxLines: 1,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Eg 31-01-2025',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900), // Earliest selectable date
                        lastDate: DateTime.now(),
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
                        },// Prevent future dates
                      );
                      if (pickedDate != null) {
                        _dateEndController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        setState(() {
                          selectedEndDate = _dateEndController.text;
                        });
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 0,
                child: Container(
                  height: 1,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 50,),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO
                if(selectedRepaymentLoanAccount == '' || selectedRepaymentLoanAccount!.isEmpty){
                  showSnackBar(context, 'Invalid Loan Account Selection', Colors.red);
                  return;
                }
                if(selectedStartDate == '' || selectedStartDate.isEmpty){
                  showSnackBar(context, 'Invalid Start Date Selection', Colors.red);
                  return;
                }
                if(selectedEndDate == '' || selectedEndDate.isEmpty){
                  showSnackBar(context, 'Invalid End Date Selection', Colors.red);
                  return;
                }else{
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoanStatementScreen(
                    loanAccount: selectedRepaymentLoanAccount,
                    startDate: selectedStartDate,
                    endDate: selectedEndDate,)
                  ),);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.submit,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //TODO - (4 )LOAN PAYMENT SCHEDULE WIDGET
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return '';
    }
  }
  List<LoanSchedules> loanSchedulesList = [];
  LoanAccount? selectedLoanAccount;
  Future<void> _fetchLoansRepaymentSchedule(String loanAccount) async {
    try {
      final response = await apiCustomerLoans.loanPaymentSchedule(loanAccount);
      if (response['data']['response_code'] == '00') {
        final loans = response['data']['repayment_schedule']['loanschedule'] as List<dynamic>;
        setState(() {
          loanSchedulesList = loans.map((loan) => LoanSchedules.fromJson(loan)).toList();
        });
      } else {
        showSnackBar(context, response['data']['response'] ?? 'Unknown error', Colors.orange);
      }
    } catch (error) {
      showSnackBar(context, 'Error Loading Loans: ${error.toString()}', Colors.red);
    }
  }
  Widget _mainTabLoanPaymentSchedule(){
    final authProvider = Provider.of<SessionProvider>(context).user;
    final accounts = authProvider?.accounts;
    final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;

    final index = loanAccountsList.indexWhere((loan) => loan.loanAccount == selectedLoanAccount?.loanAccount);
    final amountFinanced = index != -1 ? loanAccountsList[index].amountFinanced : '';
    final amountDue = index != -1 ? loanAccountsList[index].amountDue : '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          DropdownButtonFormField<LoanAccount>(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0)),
              labelText: 'Select the loan',
            ),
            value: selectedLoanAccount,
            items: loanAccountsList.map((loan) {
              return DropdownMenuItem<LoanAccount>(
                value: loan,
                child: Text(loan.loanAccount,style: TextStyle(fontSize: 12),),
              );
            }).toList(),
            onChanged: (LoanAccount? newLoan) {
              if (newLoan == null) return;
              setState(() {
                selectedLoanAccount = newLoan;
                loanSchedulesList.clear();
              });
              _fetchLoansRepaymentSchedule(newLoan.loanAccount);
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.amountDisbursed, style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
              Text('\$$amountFinanced', style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.outstanding, style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
              Text('\$$amountDue', style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 16),
          Container(
            color: Colors.red.shade900,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: Center(child: Text(AppLocalizations.of(context)!.dueDate, style: TextStyle(color: Colors.white)))),
                Expanded(child: Center(child: Text(AppLocalizations.of(context)!.outstanding, style: TextStyle(color: Colors.white)))),
                Expanded(child: Center(child: Text(AppLocalizations.of(context)!.dueAmount, style: TextStyle(color: Colors.white)))),
                Expanded(child: Center(child: Text(AppLocalizations.of(context)!.paidAmount, style: TextStyle(color: Colors.white)))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: loanSchedulesList.length,
              itemBuilder: (context, index) {
                final row = loanSchedulesList[index];
                final backgroundColor = index % 2 == 0 ? Colors.white : Colors.grey.shade100;
                return Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: Center(child: Text(_formatDate(row.dueDate), style: TextStyle(fontSize: 11,)))),
                      Expanded(child: Center(child: Text('\$${row.amountOutStanding.toStringAsFixed(2)}', style: TextStyle(fontSize: 11,)))),
                      Expanded(child: Center(child: Text('\$${row.amountDue.toStringAsFixed(2)}', style: TextStyle(fontSize: 11,)))),
                      Expanded(child: Center(child: Text('\$${row.amountSettled.toStringAsFixed(2)}', style: TextStyle(fontSize: 11,)))),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

}




//TODO - LOAN STATUS WIDGETS - START
TableRow _buildTableHeader() {
  return TableRow(
    decoration: const BoxDecoration(
      color: Color(0xFFF4F4F4),
    ),
    children: [
      _buildHeaderCell('Account'),
      _buildHeaderCell('Amount'),
      _buildHeaderCell('Outstanding'),
      _buildHeaderCell('More'),
    ],
  );
}
Widget _buildHeaderCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 10,
      ),
    ),
  );
}

//TODO - LOAN STATUS WIDGETS -- END

//TODO - LOAN SCHEDULE WIDGETS -- START
TableRow _buildTableHeaderSchedule() {
  return const TableRow(
    decoration: BoxDecoration(
      color: Color(0xFFF4F4F4),
    ),
    children: [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Date',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10,),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Amount',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10,),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Status',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10,),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Action',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10,),
        ),
      ),
    ],
  );
}

TableRow _buildTableRowSchedule(String date, String amount, String status, String action) {
  return TableRow(
    decoration: const BoxDecoration(
      color: Colors.white,
    ),
    children: [
      _buildTableCell(date),
      _buildTableCell(amount),
      _buildTableCell(
        status,
        statusColor: status == 'Paid' ? Colors.green : Colors.orange,
      ),
      _buildTableCell(action, actionColor: Colors.red),
    ],
  );
}

Widget _buildTableCell(String text, {Color? statusColor, Color? actionColor}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: text == 'PAY'
        ? ElevatedButton(
      onPressed: () {
        //TODO
      },
      style: ElevatedButton.styleFrom(backgroundColor: actionColor),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10,),
      ),
    )
        : Text(
      text,
      style: TextStyle(color: statusColor ?? Colors.black, fontSize: 10,),
    ),
  );
}
//TODO - LOAN SCHEDULE WIDGETS -- END