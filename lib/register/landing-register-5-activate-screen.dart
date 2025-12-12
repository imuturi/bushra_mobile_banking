import 'dart:async';

import 'package:bushra_mobile/remote-config-services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/landing-login-3-login.dart';
import '../utils/api-otp-functions.dart';
import '../utils/providers/provider-registration.dart';
import '../utils/util-log-service.dart';
import '../widgets/progress-dialog.dart';

class ActivateMobileBankingScreen extends StatefulWidget {
  final String phoneNumber;
  const ActivateMobileBankingScreen({super.key, required this.phoneNumber});
  @override
  State<ActivateMobileBankingScreen> createState() => _ActivateMobileBankingScreen();
}

class _ActivateMobileBankingScreen extends State<ActivateMobileBankingScreen> {
  bool isLoading = false;
  bool isResendLoading = false;
  FocusNode focusNode = FocusNode();
  final apiOtpFunctions = ApiOtpFunctions();

  Timer? _countdownTimer;
  int _remainingSeconds = 120; // 2 minutes
  bool isTimerExpired = false;

  TextEditingController otpCodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startOtpProcess();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    otpCodeController.dispose();
    phoneController.dispose();
    super.dispose();
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

  void startOtpProcess() {
    otpGenerateResend(widget.phoneNumber, widget.phoneNumber); // Pass debitAccount if needed
    startCountdownTimer();
  }

  void startCountdownTimer() {
    _countdownTimer?.cancel(); // cancel previous if exists
    setState(() {
      _remainingSeconds = 120;
      isTimerExpired = false;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() {
          isTimerExpired = true;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> otpVerification(String phone, String otpCode) async {
    final registrationData = Provider.of<RegistrationData>(context, listen: false);
    try {
      final prefs = await SharedPreferences.getInstance();
      if(phone.startsWith('+')){
        phone = phone.replaceFirst('+', '');
      }else if(phone.length == 9){ // 252615501352
        phone = '252$phone'; //TODO - REMOVE THIS - Check Selected Code
      }
      var responseData = await apiOtpFunctions.verifyOtp(phone, otpCode);
      if (responseData != null) {
        setState(() {
          isLoading = false;
          Navigator.pop(context);
        });
        //TODO - MOCK THIS NOW
        if(responseData['data']['response']['response_code']=='00'){
          await prefs.setString('IS_SELF_REGISTERED_SUCCESS', 'TRUE');
          //await prefs.setString('USER_LOGIN_ID', registrationData.phoneNumber!);
          await prefs.setString('IS_ACCOUNT_ACTIVATED', 'TRUE');
          showSnackBar(context, responseData['data']['response']['response'], Colors.green);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PinInputLoginScreen()),);
        }else{
          // Failed OTP Verification --
          if(RemoteConfigService.isProdBuild != 'true') {
             await prefs.setString('IS_SELF_REGISTERED_SUCCESS', 'TRUE');
             //await prefs.setString('USER_LOGIN_ID', registrationData.phoneNumber!);
             await prefs.setString('IS_ACCOUNT_ACTIVATED', 'TRUE');
             showSnackBar(context, responseData['data']['response']['error_data'], Colors.red);
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PinInputLoginScreen()),);
          }else{
            await prefs.setString('IS_ACCOUNT_ACTIVATED', 'FALSE');
            showSnackBar(context, responseData['data']['response']['error_data'], Colors.red);
            setState(() {
              isLoading = false;
              Navigator.pop(context);
            });
          }
        }
      }else{
        setState(() {
          isLoading = false;
          Navigator.pop(context);
        });
        showSnackBar(context, 'Error Occurred in OTP Verification', Colors.red);
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      showSnackBar(context, error.toString(), Colors.red);
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      throw Exception('ERROR OTP VALIDATION : $error');
    }
  }

  Future<void> otpGenerateResend(String phone, String debitAccount) async {
    try {
      if(phone.startsWith('+')){
        phone = phone.replaceFirst('+', '');
      }else if(phone.length == 9){ // 252615501352
        phone = '252$phone'; //TODO - REMOVE THIS - Check Selected Code
      }
      var responseData = await apiOtpFunctions.generateOtp(phone, debitAccount);
      if (responseData != null) {
        setState(() {
          isLoading = false;
        });
        if(responseData['data']['response']['response_code']=='00'){
          // OTP - RESEND SUCCESS
          showSnackBar(context, responseData['data']['response']['response'], Colors.green);
        }else{
          // OTP - RESEND FAILURE
          showSnackBar(context, responseData['data']['response']['error_data'], Colors.red);
        }
      }else{
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Error Occurred in OTP Verification', Colors.red);
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      showSnackBar(context, error.toString(), Colors.red);
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      throw Exception('ERROR OTP VALIDATION : $error');
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade900, Colors.purple.shade900],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "       Activate Mobile Banking",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Activation Code'),
                // Activation Code Field
                TextField(
                  controller: otpCodeController,
                  decoration: InputDecoration(
                    //labelText: "Activation code",
                    hintText: "Eg. *****",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Phone Number Field
                const Text('Phone Number'),
                TextField(
                  readOnly: true,
                  //controller: phoneController,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/icons/somalia-flag.png', // Add your flag asset here
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8.0),
                          Text(widget.phoneNumber),
                        ],
                      ),
                    ),
                    //labelText: "Phone Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24.0),
                Text(
                  isTimerExpired
                      ? "Didn't receive the code?"
                      : "Code expires in ${formatTime(_remainingSeconds)}",
                  style: TextStyle(
                    fontSize: 14,
                    color: isTimerExpired ? Colors.red : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                // Activate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isTimerExpired
                        ? () async {
                      setState(() => isResendLoading = true);
                      await otpGenerateResend(widget.phoneNumber, widget.phoneNumber);
                      setState(() => isResendLoading = false);
                      startCountdownTimer(); // restart timer
                    }
                        : () async {
                      String code = otpCodeController.text;
                      if (code.isEmpty) {
                        showSnackBar(context, 'Please enter the OTP code.', Colors.red);
                        return;
                      }
                      setState(() => isLoading = true);
                      showCrossingBallsProgressDialog(context, 'We are verifying your answer\nPlease Wait...',);
                      await otpVerification(widget.phoneNumber, code);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: isLoading || isResendLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      isTimerExpired ? "RESEND OTP" : "ACTIVATE",
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
