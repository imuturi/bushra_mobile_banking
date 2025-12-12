import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api-customer-accounts.dart';
import '../utils/dto/api-response-get-acc-status.dart' as AccountStatus;
import '../utils/reference-generator.dart';
import '../utils/providers/provider-session.dart';
import 'package:bushra_mobile/utils/dto/api-response-login.dart';

class StandingOrderCreate1Screen extends StatefulWidget {
  const StandingOrderCreate1Screen({super.key});

  @override
  State<StandingOrderCreate1Screen> createState() => _StandingOrderCreate1ScreenState();
}

class _StandingOrderCreate1ScreenState extends State<StandingOrderCreate1Screen> {
  String loginId = 'FALSE';
  FocusNode accountNumberFocusNode = FocusNode();
  bool isFetchingCharges = false;
  bool isFetchingAccountName = false;
  bool showAccountNameField = false;

  final apiCustomerAccountDetails = ApiCustomerAccounts();
  final referenceGenerator = ReferenceGenerator();

  TextEditingController beneficiaryAccount = TextEditingController();
  TextEditingController beneficiaryAccountName = TextEditingController();
  TextEditingController beneficiaryNarration = TextEditingController();
  TextEditingController beneficiaryAmount = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();

  String? selectedAccount;
  String? selectedPaymentFrequency;
  String debitAccountNumber ='';
  String debitAccountCurrency ='';
  String? selectedStartDate;
  String? selectedEndDate;

  @override
  void initState(){
    super.initState();
    _loadSharedPreferencesValue();
    accountNumberFocusNode.addListener(() {
      if (!accountNumberFocusNode.hasFocus) {
        _accountVerification(beneficiaryAccount.text);
      }
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

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
    });
  }

  Future<void> _accountVerification(String inputAccount) async {
    if (inputAccount.isEmpty) {
      return;
    }
    try {
      setState(() {
        isFetchingAccountName = true;
        showAccountNameField = false;
      });
      // Call the API to fetch account details
      var response = await apiCustomerAccountDetails.customerAccountStatus(inputAccount);
      AccountStatus.AccountStatusResponse accountStatusResponse = AccountStatus.AccountStatusResponse.fromJson(response);
      AccountStatus.ResponseData responseData = accountStatusResponse.data;
      if (responseData.responseCode != '00') {
        setState(() {
          beneficiaryAccountName.text = 'Unknown';
          showAccountNameField = true;
        });
        return;
      }
      if(responseData.accountStatus?.accountName == "" || responseData.accountStatus!.accountName.isEmpty){
        setState(() {
          beneficiaryAccountName.text = 'Unknown';
          showAccountNameField = true;
        });
        return;
      }else{
        setState(() {
          beneficiaryAccountName.text = responseData.accountStatus!.accountName;
          showAccountNameField = true;
        });
      }
    } catch (e) {
      showSnackBar(context, 'Failed to Fetch Account Name.$e', Colors.red);
    } finally {
      setState(() {
        isFetchingAccountName = false;
      });
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
        title: const Text('Create new standing order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //TODO -- NEW ------------------------
            const SizedBox(height: 7),
            const Text("Debit from", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildTextInputDropDownFieldRed(accounts),
            const SizedBox(height: 7),
            const Text('Beneficiary Account Number/IBAN', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildTextInputFieldGrayFocused('Eg. A/C #0001*******6789', beneficiaryAccount, TextInputType.number, focusNode: accountNumberFocusNode),
            if (isFetchingAccountName)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                    child: SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red.shade900,
                        )
                    )
                ),
              )
            else if (showAccountNameField)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 7),
                  const Text("Beneficiary Name", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 7),
                  _buildTextInputFieldGrayFocused('Beneficiary Name', beneficiaryAccountName, TextInputType.text, enabled: false),
                ],
              ),
            const SizedBox(height: 7),
            _buildInputField("Transfer Amount", "Eg. USD 50", beneficiaryAmount),
            const SizedBox(height: 7),
            const Text("Frequency", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildPaymentFrequencyDropdown(),
            const SizedBox(height: 10),
            const Text('Select start date', style: TextStyle(color: Colors.grey)),
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
            const Text('Select end date', style: TextStyle(color: Colors.grey)),
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
            const SizedBox(height: 7),
            _buildInputField("Narration", "Eg. Reason", beneficiaryNarration),
            const SizedBox(height: 7),
            const SizedBox(height: 22),
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //TODO
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => const StandingOrderCreate2Screen()));
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

  Widget _buildTextInputDropDownFieldRed(List<Account>? accounts){
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Light red background
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
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Select an account"),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            items: accounts?.map<DropdownMenuItem<String>>((account) {
              String maskedAccount =
                  "A/C #${account.accountNumber.substring(0, 4)}****${account.accountNumber.substring(account.accountNumber.length - 4)}";
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
              color: Colors.red.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentFrequencyDropdown() {
    final List<String> frequencies = [
      "DAILY",
      "WEEKLY",
      "MONTHLY",
      "QUARTERLY",
      "YEARLY"
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Light red background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            value: selectedPaymentFrequency,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("PAYMENT FREQUENCY"),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            items: frequencies.map((frequency) {
              return DropdownMenuItem<String>(
                value: frequency,
                child: Text(frequency),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedPaymentFrequency = newValue;
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

  Widget _buildTextInputFieldGrayFocused(String hint, TextEditingController controller, TextInputType inputType, {FocusNode? focusNode, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: inputType,
        style: TextStyle(color: Colors.grey.shade800),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // decoration: InputDecoration(
        //   hintText: hint,
        //   border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
        //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // ),
      ),
    );
  }

}