import 'package:flutter/material.dart';
import 'open-account-4-scan-id.dart';

class OpenAccountVerifyIdentityScreen3 extends StatefulWidget {
  final String accountType;
  final String passportNumber;
  final String phoneNumber;
  final String dateOfBirth;

  const OpenAccountVerifyIdentityScreen3({
    super.key,
    required this.accountType,
    required this.passportNumber,
    required this.phoneNumber,
    required this.dateOfBirth
  });

  @override
  State<OpenAccountVerifyIdentityScreen3> createState() => _OpenAccountVerifyIdentityScreen3();
}

class _OpenAccountVerifyIdentityScreen3 extends State<OpenAccountVerifyIdentityScreen3> {

  TextEditingController idController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Verify identity",
          style: TextStyle(color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Subtitle
                    const Text(
                      "Provide your ID",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You will have to capture your ID and take a selfie of yourself for matching.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 35),
                    const Text('ID Number', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildTextInputFieldRed("Eg. P12345678", idController, TextInputType.text),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            /// Button at the Bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OpenAccountVerifyIdentityScreen4(
                      accountType: widget.accountType,
                      passportNumber: widget.passportNumber,
                      phoneNumber: widget.phoneNumber,
                      dateOfBirth: widget.dateOfBirth,)
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "SCAN IDENTIFICATION CARD",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
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


}