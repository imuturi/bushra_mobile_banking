import 'dart:async';
import 'package:bushra_mobile/home/page-home.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../change-pin/change-pin-old.dart';
import '../register/landing-register-5-activate-screen.dart';
import '../remote-config-services.dart';
import '../utils/api-customer-accounts.dart';
import '../utils/api-customer-details.dart';
import '../utils/api-login.dart';
import '../utils/dto/api-response-login.dart';
import '../utils/providers/provider-balances.dart';
import '../utils/providers/provider-mini-recent.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-check-internet.dart';
import '../utils/util-log-service.dart';
import '../widgets/dialog-error.dart';
import '../widgets/progress-dialog.dart';

class PinInputLoginScreen extends StatefulWidget {
  const PinInputLoginScreen({super.key});
  @override
  State<PinInputLoginScreen> createState() => _PinInputLoginScreenState();
}

class _PinInputLoginScreenState extends State<PinInputLoginScreen> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _dialogShown = false;
  bool _isNoInternet = false;

  String enteredPin = "";
  final LocalAuthentication auth = LocalAuthentication();

  final apiLogin = ApiLogin();
  final apiCustomerDetails = ApiCustomerDetails();
  final apiCustomerAccounts = ApiCustomerAccounts();

  String isOtpValidated = 'FALSE';
  String isSelfRegistered = 'FALSE'; //IS_SELF_REGISTERED_SUCCESS
  String isPasswordChanged = 'FALSE'; //IS_SELF_PASSWORD_CHANGED_SUCCESS
  String loginId = 'FALSE'; //LOGIN_ID
  String loginPin = 'FALSE';

  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSharedPreferencesValue();
    _startListening();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported),
    );
  }

  void onKeyPressed(String key) {
    if (enteredPin.length >= 6) return; // prevent extra digits
    setState(() {
      enteredPin += key;
    });
    if (enteredPin.length == 6) {
      onOkPressed();
    }
  }

  void onClearPressed() {
    setState(() {
      if (enteredPin.isNotEmpty) {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      }
    });
  }

  void _startListening() {
    _connectivitySubscription = InternetCheckerService().connectivityStream.listen((results) async {
      bool noNetwork = results.contains(ConnectivityResult.none);
      if (noNetwork) {
        _showNoInternetNotification();
      } else {
        // Even if network is connected, check if internet is available
        bool hasInternet = await InternetCheckerService().hasInternetConnection();
        if (!hasInternet) {
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
                const Text(
                  'No Internet Connection',
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
          onPressed: () {
            //
          }, // Dismiss action
        ),
      ),
    );
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
      isSelfRegistered = prefs.getString('IS_SELF_REGISTERED_SUCCESS') ?? "FALSE";
      isPasswordChanged = prefs.getString('IS_SELF_PASSWORD_CHANGED_SUCCESS') ?? "FALSE";
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
      loginPin = prefs.getString('USER_LOGIN_PIN') ?? "FALSE";
      isOtpValidated = prefs.getString('IS_ACCOUNT_ACTIVATED') ?? "FALSE";

      /*
      // **** STEP 1.0 Registration Flag Values ********
      await prefs.setString('IS_SELF_REGISTERED_SUCCESS', 'TRUE');
      await prefs.setString('USER_LOGIN_ID', registrationData.phoneNumber!);
      await prefs.setString('IS_ACCOUNT_ACTIVATED', 'TRUE');

      // **** STEP 2.0 Account Exists Verification Flag Values  ******
      await prefs.setString('IS_SELF_PASSWORD_CHANGED_SUCCESS','TRUE');
      await prefs.setString('IS_SELF_REGISTERED_SUCCESS', 'TRUE');
      await prefs.setString('IS_ACCOUNT_ACTIVATED', 'TRUE');
       */
    });
  }

  Future<void> onOkPressed() async {
    //Validate IF Account Activated With OTP
    if (kDebugMode) {
      print('IS_ACCOUNT_ACTIVATED: $isOtpValidated');
    }
    if(isOtpValidated == 'FALSE' && RemoteConfigService.isProdBuild == 'true'){
      showErrorDialog(context, 'Oops! Your login failed', 'Incomplete Account Setup. Complete OTP Validation Stage', onRetry);
      return;
    }

    try {
      String phoneNumberFormatted ='';
      String phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
      if(phoneNumber.isEmpty || phoneNumber =='' || phoneNumber.length < 9){
        if(loginId != 'FALSE'){
          phoneNumber = loginId;
        }else{
          showSnackBar(context, 'Phone number not initialized. App Reset Required', Colors.red);
          return;
        }
      }
      if(phoneNumber.startsWith('+')){
        phoneNumberFormatted = phoneNumber.replaceFirst('+', '');
      }else{
        phoneNumberFormatted = phoneNumber;
      }

      setState(() {
        _isLoading = true;
      });
      showCrossingBallsProgressDialog(context, 'We are verifying your login answer \n Please Wait...');
      var responseData = await apiLogin.customerLogin(phoneNumberFormatted, enteredPin);
      if (responseData["data"]["response_code"] == "00") {
        UserModel userLoginModel = UserModel.fromJson(responseData);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('USER_LOGIN_PIN', enteredPin);
        Provider.of<SessionProvider>(context, listen: false).setUserLoginId(phoneNumberFormatted);
        Provider.of<SessionProvider>(context, listen: false).setUserLogin(userLoginModel);
        Provider.of<SessionProvider>(context, listen: false).setUserToken(userLoginModel.token);
        Provider.of<BalanceProvider>(context, listen: false).setAccounts(userLoginModel.accounts);
        final balanceProvider = Provider.of<BalanceProvider>(context, listen: false);
        final recentStatementsProvider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
        //todo - password reset / pin change
        if(userLoginModel.customerDetails.passReset == 1){
          // If the user has reset their password, navigate to change pin screen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChangePinOldScreen()));
          return;
        }
        //todo - pin blocked
        if(userLoginModel.customerDetails.pinBlock == 1){
          // If the user has blocked their PIN, show an error dialog
          Navigator.of(context).pop();
          showErrorDialog(context, 'Oops! Your login failed', 'Your PIN is blocked. Please contact customer support.', onRetry);
          setState(() {
            _isLoading = false;
          });
          return;
         }
        //todo - fetch balances and recent statements
        balanceProvider.fetchBalances(phoneNumberFormatted).then((_) {
          recentStatementsProvider.fetchStatementsForAllAccounts(balanceProvider.accounts, phoneNumberFormatted);
        });
        Navigator.of(context).pop();
        bool isPinSet = await prefs.setString('USER_LOGIN_PIN', enteredPin);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()),);
      } else {
        Navigator.of(context).pop();
        showErrorDialog(context, 'Oops! Your login failed', '${responseData["data"]["response"]} : ${responseData["data"]["error_data"]}', onRetry);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      Navigator.of(context).pop();
      showErrorDialog(context, 'Oops! Your login failed', error.toString(), onRetry);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void onRetry(){
    if(isOtpValidated == 'FALSE'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ActivateMobileBankingScreen(
        phoneNumber: loginId,
      )),);
    }else {
      Navigator.pop(context);
    }
  }

  void showErrorDialog(BuildContext context, String messageParent, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorAlertDialog(message: message, onRetry: onRetry, messageParent: messageParent,),
    );
  }

  //TODO - BIOMETRIC SECTION ----------------------------------
  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      if (kDebugMode) {
        print(e);
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }
  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }
  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }
  Future<void> _authenticate() async {
    await _checkBiometrics();
    await _getAvailableBiometrics();
    final secureStorage = const FlutterSecureStorage();
    // Check if PIN is stored
    String? biometricsEnabled = await secureStorage.read(key: 'BIOMETRICS_ENABLED');
    if (biometricsEnabled == null) {
      showSnackBar(context, 'Please login with PIN first to enable biometrics', Colors.red);
      return;
    }
    try {

      final prefs = await SharedPreferences.getInstance();
      String? phone = await prefs.getString('USER_LOGIN_ID');
      String? password = await prefs.getString('USER_LOGIN_PIN');
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Scan your Fingerprint or Face ID to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (didAuthenticate) {
        // Center(child: CircularProgressIndicator(
        //   color: Colors.red.shade900,
        // ));
        var responseData = await apiLogin.customerLogin(phone!, password!);
        if (responseData["data"]["response_code"] == "00") {
          UserModel userLoginModel = UserModel.fromJson(responseData);
          Provider.of<SessionProvider>(context, listen: false).setUserLoginId(phone);
          Provider.of<SessionProvider>(context, listen: false).setUserLogin(userLoginModel);
          Provider.of<SessionProvider>(context, listen: false).setUserToken(userLoginModel.token);
          Provider.of<BalanceProvider>(context, listen: false).setAccounts(userLoginModel.accounts);
          final balanceProvider = Provider.of<BalanceProvider>(context, listen: false);
          final recentStatementsProvider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
          //todo - fetch balances and recent statements
          balanceProvider.fetchBalances(phone).then((_) {
            recentStatementsProvider.fetchStatementsForAllAccounts(balanceProvider.accounts, phone);
          });
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()),);
        } else {
          showErrorDialog(context, 'Oops! Your login failed', '${responseData["data"]["response"]} : ${responseData["data"]["error_data"]}', onRetry);
        }
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showSnackBar(context, 'Biometric error: ${e.message}', Colors.red);
    }
  }

  //TODO - BIOMETRIC SECTION ----------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait = constraints.maxHeight > constraints.maxWidth;
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          return Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/logo/background-image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Column(
                  children: [
                    SizedBox(height: isPortrait ? 80 : 40),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        height: 60,
                        child: SvgPicture.asset(
                          'assets/icons/logo.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Enter PIN',
                      style: TextStyle(
                        fontSize: isPortrait ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.all(12.0),
                      child: Text(
                        'Please enter your PIN to continue.',
                        style: TextStyle(
                          fontSize: isPortrait ? 14 : 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    //const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        bool isFilled = index < enteredPin.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isFilled ? Colors.blue.shade900 : Colors.grey.shade900,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isFilled ? 12 : 0,
                                height: isFilled ? 12 : 0,
                                decoration: BoxDecoration(
                                  color: isFilled ? Colors.blue.shade900 : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250), // or dynamically based on screen
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 35,
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        childAspectRatio: isPortrait ? 0.9 : 1.0,
                        children: [
                          ...List.generate(9, (index) {
                            String number = (index + 1).toString();
                            return _buildKey(number, () => onKeyPressed(number));
                          }),
                          const SizedBox.shrink(),
                          _buildKey("0", () => onKeyPressed("0")),
                          _buildKey("⌫", onClearPressed, isActionKey: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35), // Add spacing before keypad
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text(
                        'Forgot PIN?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(thickness: 1, indent: 32, endIndent: 32),
                    Text(
                      'Use Biometrics',
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _authenticate,
                          icon: Icon(Icons.fingerprint, color: Colors.indigo.shade900),
                          label: const Text('Login with fingerprint', style: TextStyle(fontSize: 10)),
                        ),
                        OutlinedButton.icon(
                          onPressed: _authenticate,
                          icon: SvgPicture.asset(
                            'assets/icons/face-id.svg',
                            width: 22,
                            height: 26,
                            colorFilter: ColorFilter.mode(Colors.indigo.shade900, BlendMode.srcIn),
                          ),
                          label: const Text('Login with face ID', style: TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKey(String label, VoidCallback onPressed, {bool isActionKey = false}) {
    return Center( // Center to avoid stretching inside GridView tile
      child: SizedBox(
        width: 70, // Control button diameter
        height: 70,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero, // No internal padding
            backgroundColor: isActionKey ? Colors.blue.shade900 : Colors.grey.shade100,
            foregroundColor: isActionKey ? Colors.grey.shade100 : Colors.blue.shade900,
            elevation: 4,
            shadowColor: Colors.black26,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActionKey ? Colors.white : Colors.indigo.shade900,
              fontSize: 20, // Adjust font size to match smaller button
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
