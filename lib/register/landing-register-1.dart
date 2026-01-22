import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../page-landing/page-home-landing-login.dart';
import '../remote-config-services.dart';
import '../utils/api-customer-accounts.dart';
import '../utils/api-login.dart';
import '../utils/dto/api-response-get-acc-status.dart' as AccountStatus;
import '../utils/providers/provider-registration.dart';
import '../utils/util-check-internet.dart';
import '../widgets/date-picker-custom.dart';
import '../widgets/dialog-error.dart';
import '../widgets/progress-dialog.dart';
import 'dto/customer-details-cif.dart';
import 'dto/customer-verification-details.dart';
import 'landing-register-2-security-qsn.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _dialogShown = false;
  bool _isNoInternet = false;

  bool isLoading = false;
  FocusNode focusNode = FocusNode();
  final apiLogin = ApiLogin();
  final apiCustomerAccountDetails = ApiCustomerAccounts();

  TextEditingController idController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  String phoneNumber = '';
  String selectedDocumentLabel = 'ID Number / Passport Number';
  String? _selectedDocumentValue;
  DocumentType? selectedDocumentType; // Starts as null (no selection)
  final List<DocumentType> documentTypes = [
    DocumentType(value: 'NATIONALID', description: 'National ID'),
    DocumentType(value: 'PASSPORT', description: 'Passport'),
  ];

  void clearInputFields(){
    idController.clear();
    phoneController.clear();
    accountNumberController.clear();
    dobController.clear();
  }

  void _startListening() {
    _connectivitySubscription = InternetCheckerService().connectivityStream.listen((results) async {
      bool noNetwork = results.contains(ConnectivityResult.none);
      if (noNetwork) {
        //_showNoInternetDialog();
        _showNoInternetNotification();
      } else {
        // Even if network is connected, check if internet is available
        bool hasInternet = await InternetCheckerService().hasInternetConnection();
        if (!hasInternet) {
          //_showNoInternetDialog();
          _showNoInternetNotification();
        } else {
          _dismissDialogIfAny();
        }
      }
    });
  }

  void _dismissDialogIfAny() {
    if (_dialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
      _dialogShown = false;
    }
  }

  void _showNoInternetNotification() {
    if (!_isNoInternet) {
      setState(() {
        _isNoInternet = true;
      });
      // Show a bottom sheet notification
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: Colors.yellow.shade500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.signal_wifi_off, // Broken WiFi icon
                  color: Colors.black,
                  size: 30,
                ),
                const SizedBox(width: 10),
                 Text(
                  AppLocalizations.of(context)!.noInternetConnection,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    _dismissNoInternetNotification();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _dismissNoInternetNotification() {
    if (_isNoInternet) {
      setState(() {
        _isNoInternet = false;
      });
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
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

  void showAlertDialogAccountActivation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('assets/images/icons/success-check.png', width: 70,),
              const SizedBox(height: 18),
              Text(AppLocalizations.of(context)!.accountFoundSuccessfully,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(AppLocalizations.of(context)!.weFoundTheAccountWithTheDetailsYouProvidedToUsPleaseClickActivateButtonToContinue),
            ],
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  //TODO
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterSecurityQuestions()),);
                },
                child: const Text('CONTINUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void onRetry(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LandingPageLogin()),);
  }

  void showErrorDialog(BuildContext context, String messageParent, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorAlertDialog(message: message, onRetry: onRetry, messageParent: messageParent,),
    );
  }

  void showCrossingBallsProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CrossingBallsProgressDialog(message: message,),
    );
  }

  Future<void> customerRegistrationVerification(String phone, String account, String email, String passport, String dob) async {
    // Store Screen1 data using Provider
    final registrationData = Provider.of<RegistrationData>(context, listen: false);
    try {
      String cif = account.substring(3, account.length - 3);
      if(phone.startsWith('+')){
        phone = phone.replaceFirst('+', '');
      }
      /// 1.0.0 - API REGISTRATION STATUS
      var responseData = await apiLogin.customerRegistrationStatus(phone, account, email, passport, formatDateString(dob), 'true', _selectedDocumentValue!);
      ApiResponseModelCustomerVerification verificationResponse = ApiResponseModelCustomerVerification.fromJson(responseData);
      if (verificationResponse.customer != null) {
        //TODO - CUSTOMER ALREADY REGISTERED
        setState(() {
          isLoading = false;
          Navigator.pop(context);
          showErrorDialog(context, 'Oops! Your Registration Failed', 'Customer Details are already registered with the phoneNumber. Proceed to login', onRetry);
        });
      }else{
        /// 2.0.0 - API ACCOUNT STATUS
        //TODO - CUSTOMER NOT REGISTERED - CONTINUE TO REGISTER
        //TODO - INVOKE ACCOUNT STATUS API TO CHECK ACCOUNT STATUS
        var responseAccountStatus = await apiCustomerAccountDetails.customerAccountStatus(account);
        AccountStatus.AccountStatusResponse accountStatusResponse = AccountStatus.AccountStatusResponse.fromJson(responseAccountStatus);
        AccountStatus.ResponseData responseData = accountStatusResponse.data;

        if (responseData.accountStatus == null) {
          setState(() {
            isLoading = false;
            Navigator.pop(context);
            showErrorDialog(context, 'Oops! Your registration failed', responseData.errorData ?? 'Account details are not available', onRetry,);
          });
          return;
        }

        if (responseData.responseCode != '00') {
          setState(() {
            setState(() {
              isLoading = false;
              Navigator.pop(context);
              showErrorDialog(context, 'Oops! Your registration failed', 'Your account details are not valid', onRetry);
            });
          });
          return;
        }
        if(responseData.accountStatus?.accountName == ""
            || responseData.accountStatus!.accountName.isEmpty
            || responseData.accountStatus?.accountNumber == ""
            || responseData.accountStatus!.accountNumber.isEmpty
            || responseData.accountStatus?.accountStatus != "NORM"
        ) {
          setState(() {
            isLoading = false;
            Navigator.pop(context);
            showErrorDialog(context, 'Oops! Your registration failed', 'Your account details are not valid', onRetry);
            return;
          });
          return;
        }else if(responseData.accountStatus?.accountNumber != account){
          setState(() {
            isLoading = false;
            Navigator.pop(context);
            showErrorDialog(context, 'Oops! Your Registration Failed', 'Account Number Entered Does Not match banks Account No During Account opening', onRetry);
          });
          return;
        }else{
          //TODO SUCCESS - CONTINUE NOW
          if (kDebugMode) {
            print('Account Status: ${responseData.accountStatus?.accountStatus}');
          }
        }

        /// 3.0.0 - API CUSTOMER DETAILS BY CIF
        //TODO INVOKE GET CUSTOMER DETAILS BY CIF FOR MORE DETAILS
        var response = await apiLogin.customerDetailsByCif(cif);
        ApiResponseCustomerDetails customerDetailsResponse = ApiResponseCustomerDetails.fromJson(response);
        CustomerDetails customerDetails = customerDetailsResponse.data.customerDetails;
        final accountDetails = customerDetails.account;
        if(accountDetails != null){
          if(passport != accountDetails.passportNumber.toUpperCase() && selectedDocumentType!.value == 'PASSPORT'){
            setState(() {
              isLoading = false;
              Navigator.pop(context);
              showErrorDialog(context, 'Oops! Your Registration Failed', 'Passport Number Entered Does Not match banks Passport No During Account opening', onRetry);
            });
            clearInputFields();
            return;
          }
          if(idController.text != accountDetails.nationalId && selectedDocumentType!.value == 'NATIONALID'){
            setState(() {
              isLoading = false;
              Navigator.pop(context);
              showErrorDialog(context, 'Oops! Your Registration Failed', 'ID Number Entered Does Not match banks ID No During Account opening', onRetry);
            });
            clearInputFields();
            return;
          }
          if (compareDates(dob, accountDetails.dateOfBirth.toString())) {
            print('Dates match!');
          } else {
            print('Dates do not match');
            setState(() {
              isLoading = false;
              Navigator.pop(context);
              showErrorDialog(context, 'Oops! Your Registration Failed', 'Date of Birth Entered Does Not match banks Date of Birth During Account opening', onRetry);
            });
            return;
          }
          
          String phoneNumberFormated; //252615566243 // 254718908314
          String responsePhone;
          if(RemoteConfigService.isProdBuild == 'true'){
            if(accountDetails.phoneNumber != null && accountDetails.phoneNumber!.isNotEmpty){
              if(accountDetails.phoneNumber!.startsWith('+')){
                responsePhone = accountDetails.phoneNumber!.replaceFirst('+', '');
              } else{
                responsePhone = accountDetails.phoneNumber!;
              }
              if(responsePhone.length == 12){
                phoneNumberFormated = responsePhone;
              }else if(responsePhone.length < 12 && responsePhone.startsWith("0")) {
                String countryCode = phone.substring(0, 3);
                phoneNumberFormated = countryCode + responsePhone.replaceFirst('0','');
              }else if(responsePhone.length < 12 && !responsePhone.startsWith("0")) {
                String countryCode = phone.substring(0, 3);
                phoneNumberFormated = countryCode + responsePhone;
              }else{
                phoneNumberFormated = responsePhone;
              }
              if(phoneNumberFormated != phone){
                setState(() {
                  isLoading = false;
                  Navigator.pop(context);
                  showErrorDialog(context, 'Oops! Your Registration Failed', 'Phone Number Entered Does Not match banks Phone No During Account opening', onRetry);
                });
                return;
              }
            }else{
              //Phone Number Not Found in Bank Records
              setState(() {
                isLoading = false;
                Navigator.pop(context);
                showErrorDialog(context, 'Oops! Your Registration Failed', 'Phone Number Not Found in Bank Records. Please Visit Branch', onRetry);
              });
              return;
            }
          }

          //STATE PROVIDER
          registrationData.updateScreen1Data(
            debitAccount: account,
            phoneNumber: phone,
            accountNumber: account,
            firstName: accountDetails.firstName,
            lastName: accountDetails.lastName,
            middleName: accountDetails.middleName,
            passportNumber: passport,
            dateOfBirth: accountDetails.dateOfBirth!.isNotEmpty ? accountDetails.dateOfBirth! : dob,
            gender: accountDetails.gender,
            email: accountDetails.email!.isNotEmpty ? accountDetails.email! : email,
            documentType: _selectedDocumentValue!,
          );

          setState(() {
            isLoading = false;
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterSecurityQuestions()),);
          });
        }else{
          //Details Not Found By CIF
          setState(() {
            isLoading = false;
            Navigator.pop(context);
            showErrorDialog(context, 'Oops! Your Registration Failed', 'Your Registration Details Cannot Be Validated Please Visit Branch', onRetry);
          });
        }
      }
    } catch (error) {
      showSnackBar(context, error.toString(), Colors.red);
      setState(() {
        isLoading = false;
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LandingPageLogin()));
      });
      throw Exception('FAILED to validate customer details : $error');
    }
  }

  bool compareDates(String inputDate, String accountDate) {
    try {
      final parsedInputDate = parseInputDate(inputDate);
      if (parsedInputDate == null) return false;
      // Normalize accountDate to extract only date part
      String dateOnly;
      if (accountDate.contains('T')) {
        dateOnly = accountDate.split('T')[0];
      } else {
        dateOnly = accountDate.split(' ')[0];
      }
      final accountDateParts = dateOnly.split('-');
      final accountYear = int.parse(accountDateParts[0]);
      final accountMonth = int.parse(accountDateParts[1]);
      final accountDay = int.parse(accountDateParts[2]);
      final parsedAccountDate = DateTime(accountYear, accountMonth, accountDay);
      return parsedInputDate.year == parsedAccountDate.year &&
          parsedInputDate.month == parsedAccountDate.month &&
          parsedInputDate.day == parsedAccountDate.day;
    } catch (e) {
      print('Error comparing dates: $e');
      return false;
    }
  }

  String formatDateString(String inputDate) {
    try {
      // Parse using the known and consistent format: dd/MM/yyyy
      final parsedDate = DateFormat('dd/MM/yyyy').parseStrict(inputDate);
      // Format as "yyyy-MM-dd 00:00:00.0"
      final formattedDate =
          "${parsedDate.year.toString().padLeft(4, '0')}-"
          "${parsedDate.month.toString().padLeft(2, '0')}-"
          "${parsedDate.day.toString().padLeft(2, '0')} 00:00:00.0";
      return formattedDate;
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting date: $inputDate -> $e');
      }
      return inputDate;
    }
  }

  DateTime? parseInputDate(String inputDate) {
    try {
      // Force a consistent format, e.g., dd/MM/yyyy
      final format = DateFormat('dd/MM/yyyy');
      return format.parseStrict(inputDate);
    } catch (e) {
      print('Error parsing input date: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrationData = Provider.of<RegistrationData>(context);
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
        title:  Text(
          AppLocalizations.of(context)!.register,
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      AppLocalizations.of(context)!.pleaseProvideTheFollowingDetails,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                     Text(AppLocalizations.of(context)!.selectDocumentType, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildDocumentTypeDropDown(),

                    const SizedBox(height: 16),
                     Text(AppLocalizations.of(context)!.idNumberPassportNumber, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextInputFieldRed("Eg. P12345678", idController, TextInputType.text),
                    const SizedBox(height: 20),

                     Text(AppLocalizations.of(context)!.phoneNumber, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextInputFieldPhoneNumber('Eg 615566243', phoneController),
                    const SizedBox(height: 20),

                     Text(AppLocalizations.of(context)!.dateOfBirth, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    CustomDatePickerWidget(
                      context: context,
                      hint: 'Eg dd/MM/yyyy',
                      controller: dobController,
                    ),
                    const SizedBox(height: 20),

                     Text(AppLocalizations.of(context)!.accountNumber, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextInputFieldGray("Eg. 0013000006100", accountNumberController, TextInputType.number),

                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0), // Add padding for spacing
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  showCrossingBallsProgressDialog(context, 'We are verifying your account \n Please Wait...');
                  String id = idController.text;
                  String dob = dobController.text;
                  String accountNumber = accountNumberController.text;

                  if (_selectedDocumentValue == null) {
                    showSnackBar(context, 'Document type is not selected', Colors.red);
                    setState(() {
                      isLoading = false;
                      Navigator.pop(context);
                    });
                    return;
                  }

                  if(id=='' || dob=='' || accountNumber=='' || phoneNumber ==''){
                    showSnackBar(context, 'All fields are mandatory', Colors.red);
                    setState(() {
                      isLoading = false;
                      Navigator.pop(context);
                    });
                    return;
                  }

                  if(id.isEmpty || dob.isEmpty || accountNumber.isEmpty || phoneNumber.isEmpty){
                    showSnackBar(context, 'All fields are mandatory', Colors.red);
                    setState(() {
                      isLoading = false;
                      Navigator.pop(context);
                    });
                    return;
                  }else if(accountNumber.length > 13 || accountNumber.length < 13) {
                    showSnackBar(context, 'Invalid Account Number Length. 13 Characters recommended', Colors.red);
                    setState(() {
                      isLoading = false;
                      Navigator.pop(context);
                    });
                    return;
                  }else if(phoneNumber.length != 13) {
                    showSnackBar(context, 'Invalid Phone Number Input Length (9 length required)', Colors.red);
                    setState(() {
                      isLoading = false;
                      Navigator.pop(context);
                    });
                    return;
                  } else{
                    String email = 'default@system.com';
                    customerRegistrationVerification(phoneNumber, accountNumber, email, id.toString().toUpperCase(), dob);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }

  Widget _buildTextInputFieldRed(String hint, TextEditingController controller, TextInputType textInputType, {int maxLines = 1}){
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Light red background
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
              fillColor: Colors.red.shade50,
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
              color: Colors.red.shade900,
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
            languageCode: "en",
            initialCountryCode: "SO",
            onChanged: (phone) {
              if (kDebugMode) {
                print(phone.completeNumber);
              }
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
          // TextField(
          //   controller: controller,
          //   readOnly: true,
          //   decoration: InputDecoration(
          //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //     hintText: hint,
          //     filled: true,
          //     fillColor: Colors.grey.shade100,
          //     border: OutlineInputBorder(
          //       borderSide: BorderSide.none,
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     suffixIcon: const Icon(Icons.calendar_today),
          //   ),
          //   onTap: () async {
          //     DateTime? pickedDate = await showDatePicker(
          //       context: context,
          //       initialDate: DateTime.now(),
          //       firstDate: DateTime(1900), // Earliest selectable date
          //       lastDate: DateTime.now(), // Prevent future dates
          //     );
          //     if (pickedDate != null) {
          //       String formattedDate =
          //           "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          //       controller.text = formattedDate;
          //     }
          //   },
          // ),
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

  Widget _buildDocumentTypeDropDown() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          DropdownButtonFormField<DocumentType>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.red.shade50,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: Text(AppLocalizations.of(context)!.selectDocumentType, style: TextStyle(fontSize: 12)),
            value: selectedDocumentType, // Can be null initially
            items: documentTypes.map((docType) {
              return DropdownMenuItem<DocumentType>(
                value: docType,
                child: Text(docType.description, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.normal)),
              );
            }).toList(),
            onChanged: (DocumentType? newValue) {
              setState(() {
                selectedDocumentType = newValue;
                _selectedDocumentValue = newValue?.value;
                selectedDocumentLabel = newValue?.description ?? AppLocalizations.of(context)!.idNumberPassportNumber;
              });
            },
          ),
        ],
      ),
    );
  }

}

class DocumentType {
  final String value;
  final String description;
  DocumentType({required this.value, required this.description});
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentType &&
        other.value == value &&
        other.description == description;
  }

  @override
  int get hashCode => value.hashCode ^ description.hashCode;
}