import 'dart:io';

import 'package:bushra_mobile/change-pin/forgot-pin-set-pin/page-forgot-pin-create.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/api-login.dart';
import '../../utils/dto/api-request-security-questions-verification.dart';
import '../../utils/providers/provider-session.dart';
import '../../utils/reference-generator.dart';
import '../../utils/util-get-imei.dart';
import '../../widgets/progress-dialog.dart';

class ForgotPinSecurityQuestions extends StatefulWidget {
  const ForgotPinSecurityQuestions({super.key});

  @override
  State<ForgotPinSecurityQuestions> createState() => _ForgotPinSecurityQuestionsState();
}

class _ForgotPinSecurityQuestionsState extends State<ForgotPinSecurityQuestions> {

  bool isLoading = false;
  final apiLogin = ApiLogin();
  final referenceGenerator = ReferenceGenerator();
  TextEditingController securityQuestionAnswerController = TextEditingController();

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

  void showCrossingBallsProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CrossingBallsProgressDialog(message: message,),
    );
  }

  void showProgressLoaderDialog(BuildContext context){
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      content: Row(
        children: [
          const CircularProgressIndicator(
            color: Colors.red,
          ),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child:const Text('We are verifying your answer \n Please Wait...'
              )
          ),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  void showAlertDialogSecurityQuestion(BuildContext context) {
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
              const Text('Verification successfully',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text('You can now proceed change your PIN details'),
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
                onPressed: () async {
                  //TODO
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString('IS_SELF_PASSWORD_CHANGED_SUCCESS','TRUE');
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForgotPinPinInputScreen1()),);
                },
                child: const Text('ACTIVATE',
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

  Future<void> verifySecurityQuestion(String phone, String securityAnswer) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      setState(() {
        isLoading = true;
      });
      showCrossingBallsProgressDialog(context, 'We are verifying your answer \n Please Wait...');
      String deviceId = await DeviceIdentifier.getDeviceIdentifier();
      final response = await apiLogin.customerSecurityQuestionVerify(
        SecurityQuestionValidationRequest(
          txntimestamp: DateTime.now().toUtc().toIso8601String(),
          xref: referenceGenerator.generateUniqueReference(false),
          transactionDetails: TransactionDetails(
            direction: "0200",
            transactionType: "SECURITY_QUESTIONS_VERIFICATION",
            transactionCode: "SECURITY_QUESTIONS_VERIFY",
            hostCode: "MOBILE",
            phoneNumber: phone,
            securityQuestions: [
              {'questionAsked': "What's your pet name?", 'questionAnswered': securityAnswer}, //TODO remove the numbering E.g questionAnswered2 = questionAnswered
              //{'questionAsked': "What's your favourite car?", 'questionAnswered': securityAnswer},
              //{'questionAsked': "What's the name of your best friend?", 'questionAnswered': securityAnswer},
            ],
          ),
          channelDetails: ChannelDetails(
            host: "IP",
            geolocation: "1.2921,36.8219",
            userAgent: Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
            userAgentVersion: "1.0",
            channel: "MOBILE",
            clientId: "client123",
            deviceId: deviceId,
          ),
        ),
      );
      if (response != null) {
        if (response['response_code'] == '00') {
          if (kDebugMode) {
            print('Response: ${response['response']} Message: ${response['message']}');
          }
          setState(() {
            isLoading = false;
            Navigator.pop(context);
            showAlertDialogSecurityQuestion(context); // TODO SHOW SUCCESS MESSAGE
          });
        } else {
          if (kDebugMode) {
            print('Response: ${response['data']['response']['response']}');
          }
          setState(() {
            isLoading = false;
            Navigator.pop(context);
            showSnackBar(context, 'Error: ${response['data']['response']['response']}', Colors.red);
          });
        }
      }else{
        setState(() {
          isLoading = false;
          Navigator.pop(context);
        });
        showSnackBar(context, 'Error occurred while verifying security question', Colors.red);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        Navigator.pop(context);
        showSnackBar(context, 'ERROR $e', Colors.red);
      });
      if (kDebugMode) {
        print('Error: $e');
      }
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
        title: const Text(
          'Security question',
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide answers to the following questions.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Answer the following questions with the answers you gave during registration',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 26),
            const Text('Q1. Whats your pet name ?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildTextInputFieldGray("Give your answer here", securityQuestionAnswerController, TextInputType.text),
            const SizedBox(height: 20),
            const Spacer(),
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // TODO
                  if(securityQuestionAnswerController.text.isEmpty || securityQuestionAnswerController.text == '') {
                    showSnackBar(context, 'You have not answered the question', Colors.red);
                    return;
                  }
                  //TODO API CALL
                  final prefs = await SharedPreferences.getInstance();
                  String phone = '';
                  final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
                  if(phoneNumber.isEmpty) {
                    phone = prefs.getString('USER_LOGIN_ID') ?? '';
                  }else{
                    phone = phoneNumber;
                  }
                  verifySecurityQuestion(phone, securityQuestionAnswerController.text);
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
          ],
        ),
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

}