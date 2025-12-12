import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api-login.dart';
import '../utils/providers/provider-registration.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-log-service.dart';
import '../widgets/progress-dialog.dart';
import 'landing-register-5-activate-screen.dart';

class RegisterPinInputScreen2 extends StatefulWidget {
  final String customerPin;
  const RegisterPinInputScreen2({super.key, required this.customerPin});

  @override
  State<RegisterPinInputScreen2> createState() => _RegisterPinInputScreen2();
}

class _RegisterPinInputScreen2 extends State<RegisterPinInputScreen2> {

  String enteredPin = "";
  bool isLoading = false;
  final apiLogin = ApiLogin();

  @override
  void initState() {
    super.initState();
  }

  void onKeyPressed(String key) {
    if (enteredPin.length >= 6) return; // prevent extra digits
    setState(() {
      enteredPin += key;
    });
    if (enteredPin.length == 6 && enteredPin == widget.customerPin) {
      onOkPressed();
    }else if(enteredPin.length == 6 && enteredPin != widget.customerPin){
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, 'Please enter a 6-digit PIN that matches the other to complete registration', Colors.red);
    }
  }

  void onClearPressed() {
    setState(() {
      if (enteredPin.isNotEmpty) {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      }
    });
  }

  void onOkPressed() {
    if (enteredPin.length == 6 && enteredPin == widget.customerPin) {
      setState(() {
        isLoading = true;
      });
      showCrossingBallsProgressDialog(context, 'We are creating your login account \n Please Wait...');
      customerRegistration(enteredPin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit PIN that matches the other to complete registration')),
      );
    }
  }

  Future<void> customerRegistration(String pin) async {
    try {
      final registrationData = Provider.of<RegistrationData>(context, listen: false);
      registrationData.updateScreen3Data(
        pin: pin,
      );

      final dto = await registrationData.toDto();
      var response = await apiLogin.customerRegistration(dto);
      // Handle the response as needed
      if (response["data"]["response_code"] == "00") {
        final prefs = await SharedPreferences.getInstance();
        bool isRegistered = await prefs.setString('IS_SELF_REGISTERED_SUCCESS', 'TRUE');
        bool isLoginIdPresent = await prefs.setString('USER_LOGIN_ID', registrationData.phoneNumber!);
        bool isAccountActivated = await prefs.setString('IS_ACCOUNT_ACTIVATED', 'FALSE');
        Provider.of<SessionProvider>(context, listen: false).setUserLoginId(registrationData.phoneNumber!);
        if (isRegistered && isLoginIdPresent && isAccountActivated) {
          setState(() {
            isLoading = false;
            Navigator.pop(context);
          });
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ActivateMobileBankingScreen(
            phoneNumber: registrationData.phoneNumber!,)
          ),);
        }else{
          setState(() {
            isLoading = false;
            Navigator.pop(context);
          });
          showSnackBar(context, 'FAILED TO SET APP STATE', Colors.blue);
        }
      }else{
        showSnackBar(context, response["data"]["response"], Colors.red);
        setState(() {
          isLoading = false;
          Navigator.pop(context);
        });
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      showSnackBar(context, error.toString(), Colors.red);
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      throw Exception('ERROR REGISTERING USER : $error');
    }
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
                      'Confirm your New PIN',
                      style: TextStyle(
                        fontSize: isPortrait ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.all(12.0),
                      child: Text(
                        'Set your personal 6-digit code, it will be used for secure and last sign-in.',
                        style: TextStyle(
                          fontSize: isPortrait ? 12 : 10,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 30),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 30,
                      padding: const EdgeInsets.all(64),
                      childAspectRatio: isPortrait ? 1 : 1.3,
                      children: [
                        ...List.generate(9, (index) {
                          String number = (index + 1).toString();
                          return _buildKey(number, () => onKeyPressed(number));
                        }),
                        const SizedBox.shrink(), // Replaces OK button
                        _buildKey("0", () => onKeyPressed("0")),
                        _buildKey("⌫", onClearPressed, isActionKey: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This keeps your account secure',
                      style: TextStyle(
                        fontSize: isPortrait ? 12 : 10,
                        fontWeight: FontWeight.normal,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  // Function to build a key button
  Widget _buildKey(String label, VoidCallback onPressed, {bool isActionKey = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12), // Smaller padding = smaller circle
        backgroundColor: isActionKey ? Colors.blue.shade900 : Colors.grey.shade100,
        foregroundColor: isActionKey ? Colors.grey.shade100 : Colors.blue.shade900,
        elevation: 4,
        shadowColor: Colors.black26,
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ), // Smaller font if needed
      ),
      child: Text(label,
        style: TextStyle(
          color: isActionKey ? Colors.white : Colors.indigo.shade900,
          fontSize: 24,
        ),
      ),
    );
  }

}