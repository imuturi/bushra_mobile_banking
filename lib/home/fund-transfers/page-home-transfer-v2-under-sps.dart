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
import '../../utils/providers/provider-transfer-favourite-data.dart';
import '../../utils/reference-generator.dart';
import '../../utils/providers/provider-session.dart';
import '../../utils/util-log-service.dart';
import '../../widgets/dialog-transaction-charges.dart';

class FundsTransferSpsScreen extends StatefulWidget {
  const FundsTransferSpsScreen({super.key});

  @override
  State<FundsTransferSpsScreen> createState() => _FundsTransferSpsScreenState();

}

class _FundsTransferSpsScreenState extends State<FundsTransferSpsScreen> {
  bool favouriteFlag = false;
  bool isFetchingCharges = false;
  FocusNode accountNumberFocusNode = FocusNode();
  bool isFetchingAccountName = false;
  bool showAccountNameField = false;

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
  int _currentIndex = 0; // Stores the current page index
  late String _currentIndexAccountNumber;
  late String _currentIndexCurrency;
  String? selectedAccount;
  String debitAccountNumber ='';
  String debitAccountCurrency ='';


  String? selectedBicCode;
  List<Map<String, dynamic>> banks = [];
  String? selectedSpsBank;

  String? selectedOptionMobileSelf;
  bool showPhoneTextField = false;

  String? selectedSpsTransferType;
  final List<Map<String, dynamic>> spsTransferType = [
    {"name": "P2P"},
    {"name": "P2M"},
  ];

  @override
  void initState() {
    super.initState();
    showPhoneTextField = false;
    _loadSharedPreferencesValue();
    getSpsParticipantBanks();
    _amountController.addListener(() {
      setState(() {
        selectedAmount = double.tryParse(_amountController.text);
      });
    });
    accountNumberFocusNode.addListener(() {
      if (!accountNumberFocusNode.hasFocus) {
        // User left the field
        if (beneficiaryAccountNumber.text.isNotEmpty) {
          fetchAccountName(beneficiaryAccountNumber.text);
        }
      }
    });
    _favouritesPrefilledForm();
  }


  @override
  void dispose() {
    super.dispose();
  }

  void _favouritesPrefilledForm() {
    final favorite = context.read<FavoriteTransferDataProvider>().selectedFavorite;
    if (favorite != null) {
      _amountController.text = favorite.amount;
      beneficiaryAccountName.text = favorite.name;
      beneficiaryAccountNumber.text = favorite.recipient;
      setState(() {
        showAccountNameField = true;
      });
      // Immediately clear to avoid reuse
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<FavoriteTransferDataProvider>().clearFavorite();
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

  Future<void> getSpsParticipantBanks() async {
    try {
      final data = await apiCustomerFundsTransfer.getSpsParticipantBanks();
      setState(() {
        banks = (data["spsParticipatingBanks"]["spsParticipatingBank"] as List)
            .map((bank) => {"bicName": bank["bicName"], "bicCode": bank["bicCode"]})
            .toList();
        // Deduplicate by bicCode
        banks = banks.fold([], (list, element) {
          if (!list.any((item) => item["bicCode"] == element["bicCode"])) {
            list.add(element);
          }
          return list;
        });
      });
    } catch (error) {
      showSnackBar(context, error.toString(), Colors.red);
      throw Exception('FAILED TO GET SPS PARTICIPANTS : $error');
    }
  }

  Future<void> fetchAccountName(String accountNumber) async {
    setState(() {
      isFetchingAccountName = true;
      showAccountNameField = false;
    });
    try {
      final result = await apiCustomerFundsTransfer.getSpsBeneficiaryName(
          selectedSpsBank!,
          debitAccountNumber,
          accountNumber,
          loginId
      );
      setState(() {
        if(result['data']['response_code']=="1"){
          beneficiaryAccountName.text = 'Unknown Customer';
          showSnackBar(context, 'Customer not found on account lookup', Colors.red);
        }else{
          beneficiaryAccountName.text = result['data']?['accountName'] ?? 'Unknown Customer';
        }
        showAccountNameField = true;
      });
    } catch (e) {
      showSnackBar(context, 'Failed to fetch account name.$e', Colors.red);
    } finally {
      setState(() {
        isFetchingAccountName = false;
      });
    }
  }

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
    });
  }

  Future<void> _fetchCharges(String phone, String transactionReference) async{
    try{
      setState(() {
        isFetchingCharges = true;
      });
      var response = await apiCustomerFundsTransfer.transactionCharges(
        debitAccountNumber,
        beneficiaryAccountNumber.text,
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
            dialogDescription: "Please confirm you are making an SPS Transfer",
            amount: '$debitAccountCurrency ${_amountController.text}',
            recipientAccount: beneficiaryAccountNumber.text,
            sourceAccount: debitAccountNumber,
            charges: '$debitAccountCurrency ${transactionCharges.data?.chargeAmount.toString()}',
            onCancel: () {
              // Handle cancel
              Navigator.pop(context);
            },
            onConfirm: () {
              // Handle confirmation
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  PinInputCommitTransactionScreen(
                transferType: 'SPSOUTGOINGTRANSFER',
                spsTransferType: selectedSpsTransferType,
                transactionReference: transactionReference,
                debitAccount: debitAccountNumber,
                debitPhoneNumber: phone,
                beneficiaryAccount: beneficiaryAccountNumber.text,
                beneficiaryName: beneficiaryAccountName.text,
                currency: debitAccountCurrency,
                transactionAmount: selectedAmount.toString(),
                narration: beneficiaryNarration.text,
                beneficiaryBankCode: selectedSpsBank,
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
    } catch(error, stack){
      LoggerService.reportUnexpectedError(error, stack);
      showSnackBar(context, 'Failed to Fetch Charges.$error', Colors.red);
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
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('SPS', style: TextStyle(color: Colors.black, fontSize: 15),),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
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
                    // const SizedBox(height: 7),
                    // const Text("Select transfer type", style: TextStyle(color: Colors.grey)),
                    // const SizedBox(height: 7),
                    // _buildTextInputDropDownFieldRed(),

                    const SizedBox(height: 7),
                    const Text("Select transfer type", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 7),
                    _buildTextInputDropDownFieldRedSpsType(),

                    const SizedBox(height: 7),
                    const Text("Select provided bank", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 7),
                    _buildTextInputBankDropDownFieldGray(),

                    //TODO - SPS ACCOUNT VALIDATION
                    const SizedBox(height: 7),
                    const Text("Enter Beneficiary Account Number", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 7),
                    //_buildTextInputFieldGray('Eg. SO380013000300000510106', beneficiaryAccountNumber, TextInputType.text, focusNode: accountNumberFocusNode),
                    _buildTextInputFieldGray('Eg. SO380013000300000510106', beneficiaryAccountNumber, TextInputType.text, focusNode: accountNumberFocusNode),
                    if (isFetchingAccountName)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2,
                            color: Colors.red.shade900)
                          )
                        ),
                      )
                    else if (showAccountNameField)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Beneficiary Account Name", style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 7),
                          _buildTextInputFieldGray('Beneficiary Name', beneficiaryAccountName, TextInputType.text, enabled: false),
                        ],
                      ),

                    const SizedBox(height: 7),
                    const Text("Select Debit Account", style: TextStyle(color: Colors.grey)),
                    _buildTextInputAccountDropDownFieldGray(accounts),

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
                            phone = phoneNumber;
                          }

                          String transactionReference = referenceGenerator.generateUniqueReference(true);
                          if(debitAccountNumber.isEmpty || debitAccountNumber ==''){
                            showSnackBar(context, 'Invalid Debit Account / IBAN Number', Colors.red);
                            return;
                          }else if(beneficiaryAccountNumber.text.isEmpty || beneficiaryAccountNumber.text==''){
                            showSnackBar(context, 'Invalid Credit Account / IBAN Number', Colors.red);
                            return;
                          }else if(beneficiaryAccountName.text.isEmpty || beneficiaryAccountName.text.length<3){
                            showSnackBar(context, 'Invalid Credit Account Name', Colors.red);
                            return;
                          }else if(beneficiaryNarration.text.isEmpty || beneficiaryNarration.text.length<3){
                            showSnackBar(context, 'Invalid Narration values', Colors.red);
                            return;
                          }else if(selectedSpsBank!.isEmpty || selectedSpsBank == ''){
                            showSnackBar(context, 'Invalid Beneficiary Bank BIC Code', Colors.red);
                            return;
                          }else if(_amountController.text.isEmpty || _amountController.text == '0.00'){
                            showSnackBar(context, 'Invalid Transaction Amount', Colors.red);
                            return;
                          }
                          if(beneficiaryAccountName.text == 'Unknown Customer'){
                            showSnackBar(context, 'Customer not found on account lookup', Colors.red);
                            return;
                          }
                          //TODO
                          _fetchCharges(phone, transactionReference);

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
                            : const Text(
                          "TRANSFER",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    // Extra spacing at the bottom
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildTextInputDropDownFieldRedSpsType(){
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
            hint: const Text("Eg P2M or P2M", style: TextStyle(fontSize: 12),),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            value: selectedSpsTransferType,
            items: spsTransferType.map((sps) {
              return DropdownMenuItem<String>(
                value: sps["name"],
                child: Row(
                  children: [
                    Text(sps["name"], style: TextStyle(fontSize: 12),), // Network name
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSpsTransferType = newValue;
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

  Widget _buildTextInputBankDropDownFieldGray(){
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light red background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: const Text("Eg Baroda", style: TextStyle(fontSize: 12),),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down),
            value: selectedSpsBank,
            items: banks.map((sps) {
              return DropdownMenuItem<String>(
                value: sps["bicCode"],
                child: Row(
                  children: [
                    Text(sps["bicName"], style: TextStyle(fontSize: 12),), // Network name
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSpsBank = newValue;
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

  Widget _buildTextInputAccountDropDownFieldGray(List<Account>? accounts){
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
                selectedAccount = newValue;
                debitAccountNumber = newValue!;
                //debitAccountCurrency = accounts?.firstWhere((account) => account.accountNumber == newValue).currency ?? '';
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

  Widget _buildTextInputFieldGray(String hint, TextEditingController controller, TextInputType inputType, {FocusNode? focusNode, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            keyboardType: inputType,
            decoration: InputDecoration(
              fillColor: Colors.grey.shade100,
              hintText: hint,
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
