import 'package:bushra_mobile/change-pin/forgot-pin-set-pin/page-forgot-pin-account-verify.dart';
import 'package:flutter/material.dart';

import '../../page-landing/page-home-landing-support.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});
  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Forgot PIN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If you forgot your pin select one of the methods to use to Reset your mobile banking PIN.',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.black54),
            ),

            const SizedBox(height: 30),
            _buildOptionCard(
              icon: Icons.question_answer,
              title: "Security question",
              subtitle: "To reset your password please answer the Security question provided.",
              value: _isChecked1,
              onChanged: (val) {
                setState(() {
                  _isChecked1 = val ?? false;
                  _isChecked2 = false;
                  _isChecked3 = false;
                });
              },
            ),

            const SizedBox(height: 20),
            _buildOptionCard(
              icon: Icons.verified_user,
              title: "Verify identity",
              subtitle: "To reset your password please verify your Identity yourself.",
              value: _isChecked2,
              onChanged: (val) {
                setState(() {
                  _isChecked1 = false;
                  _isChecked2 = val ?? false;
                  _isChecked3 = false;
                });
              },
            ),

            const SizedBox(height: 20),
            _buildOptionCard(
              icon: Icons.account_balance,
              title: "Visit branch",
              subtitle: "Please visit our nearest branch to be assisted In reseting your password",
              value: _isChecked3,
              onChanged: (val) {
                setState(() {
                  _isChecked1 = false;
                  _isChecked2 = false;
                  _isChecked3 = val ?? false;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_isChecked1 == true) {
                    //TODO Account reset with security question
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPinAccountVerifyScreen()));
                  } else if (_isChecked2 == true) {
                    //TODO Account reset with identity verification
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPinAccountVerifyScreen()));
                  } else if (_isChecked3 == true) {
                    //TODO Account reset with branch visit
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SupportScreen()));
                  } else {
                    showSnackBar(context, 'Select one option for account reset', Colors.red);
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
                  "CONTINUE",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      elevation: 0.0,
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.red.shade50,
          child: Icon(icon, color: Colors.red.shade900, size: 16,),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.normal),
        ),
        trailing: Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.red.shade900,
        ),
      ),
    );
  }
}