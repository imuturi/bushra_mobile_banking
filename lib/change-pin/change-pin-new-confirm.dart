import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/landing-login-3-login.dart';
import '../utils/api-login.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-log-service.dart';
import '../widgets/dialog-error.dart';
import '../widgets/progress-dialog.dart';

class ChangePinNewConfirmationScreen extends StatefulWidget {
  final String oldPin;
  final String newPin;
  const ChangePinNewConfirmationScreen({super.key, required this.oldPin, required this.newPin});

  @override
  State<ChangePinNewConfirmationScreen> createState() => _ChangePinNewConfirmationScreenState();
}

class _ChangePinNewConfirmationScreenState extends State<ChangePinNewConfirmationScreen> {

  String enteredPin = "";
  final apiLogin = ApiLogin();

  String isSelfRegistered = 'FALSE'; //IS_SELF_REGISTERED_SUCCESS
  String isPasswordChanged = 'FALSE'; //IS_SELF_PASSWORD_CHANGED_SUCCESS
  String loginId = 'FALSE'; //LOGIN_ID
  String loginPin = 'FALSE';

  @override
  void initState() {
    super.initState();
    _loadSharedPreferencesValue();
  }

  void onKeyPressed(String key) {
    if (enteredPin.length >= 6) return; // prevent extra digits
    setState(() {
      enteredPin += key;
    });
    if (enteredPin.length == 6) {
      onOkPressed(); // Automatically call the OK handler
    }
  }

  void onClearPressed() {
    setState(() {
      if (enteredPin.isNotEmpty) {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
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
    });
  }

  Future<void> onOkPressed() async {
    final prefs = await SharedPreferences.getInstance();
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
      });
      showCrossingBallsProgressDialog(context, 'We are changing your password \n Please Wait...');
      var responseData = await apiLogin.customerChangePin(phoneNumberFormatted, widget.oldPin, enteredPin);
      if (responseData["data"]["response_code"] == "00") {
        setState(() {
          showSnackBar(context, responseData['data']['message'], Colors.green);
          prefs.setString('IS_SELF_PASSWORD_CHANGED_SUCCESS','TRUE');
          prefs.setString('USER_LOGIN_ID',phoneNumberFormatted);
          prefs.setString('IS_ACCOUNT_ACTIVATED', 'FALSE');
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PinInputLoginScreen()),);
        });
      } else {
        Navigator.of(context).pop();
        showErrorDialog(context, 'Oops! Password change failed', '${responseData["data"]["response"]} : ${responseData["data"]["error_data"]}', onRetry);
        setState(() {
        });
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      Navigator.of(context).pop();
      showErrorDialog(context, 'Oops! Password change failed', error.toString(), onRetry);
      setState(() {
      });
    }
  }

  void onRetry(){
    Navigator.pop(context);
  }

  void showErrorDialog(BuildContext context, String messageParent, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorAlertDialog(message: message, onRetry: onRetry, messageParent: messageParent,),
    );
  }

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
                      'PIN CHANGE',
                      style: TextStyle(
                        fontSize: isPortrait ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Text(
                      'Confirm Your PIN',
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
                        'Please confirm your new PIN to continue.',
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
