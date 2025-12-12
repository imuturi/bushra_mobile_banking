import 'dart:io';
import 'package:flutter/material.dart';
import 'open-account-6-selfie1.dart';

class OpenAccountVerifyIdentityScreen extends StatefulWidget {
  final File frontImage;
  final File backImage;
  final String accountType;
  final String passportNumber;
  final String phoneNumber;
  final String dateOfBirth;

  const OpenAccountVerifyIdentityScreen({
    super.key,
    required this.frontImage,
    required this.backImage,
    required this.accountType,
    required this.passportNumber,
    required this.phoneNumber,
    required this.dateOfBirth
  });

  @override
  State<OpenAccountVerifyIdentityScreen> createState() => _OpenAccountVerifyIdentityScreen();
}
class _OpenAccountVerifyIdentityScreen extends State<OpenAccountVerifyIdentityScreen> {

  TextEditingController idController = TextEditingController();

  bool _showFront = true; // Controls which image to show

  void _flipImage() {
    setState(() {
      _showFront = !_showFront;
    });
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
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Subtitle
                    const Text(
                      "Provide your ID",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You will have to capture your ID and take a selfie of yourself for face matching.",
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 24),
                    const Text('ID Number', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildTextInputFieldRed(widget.passportNumber, idController, TextInputType.text),
                    const SizedBox(height: 35),
                    // ID and Selfie Capture Options
                    Row(
                      children: [
                        // National ID Capture
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: _flipImage,
                            child: Container(
                              height: 150,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red.shade300, width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.file(
                                      _showFront ? widget.frontImage : widget.backImage,
                                      key: ValueKey<bool>(_showFront), // Ensures smooth image transition
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Tap to see National ID\n(Front & Back)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Expanded(
                        //   flex: 1,
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       //TODO
                        //     },
                        //     child: Container(
                        //       height: 150,
                        //       padding: const EdgeInsets.all(16),
                        //       decoration: BoxDecoration(
                        //         border: Border.all(color: Colors.red.shade300, width: 1.5),
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //       child: Column(
                        //         children: [
                        //           Icon(Icons.credit_card, size: 48, color: Colors.red.shade700),
                        //           const SizedBox(height: 8),
                        //           const Text(
                        //             "Tap to see National ID\n(Front & Back)",
                        //             textAlign: TextAlign.center,
                        //             style: TextStyle(
                        //               fontSize: 10,
                        //               color: Colors.black,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(width: 16),
                        // Take a Selfie
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              // TODO
                              Navigator.push(context, MaterialPageRoute(builder: (context) => OpenAccountSelfie1(
                                frontImage: widget.frontImage,
                                backImage: widget.backImage,
                                accountType: widget.accountType,
                                passportNumber: widget.passportNumber,
                                phoneNumber: widget.phoneNumber,
                                dateOfBirth: widget.dateOfBirth,)
                              ),);
                            },
                            child: Container(
                              height: 150,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red.shade300, width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.camera_alt, size: 48, color: Colors.blue.shade700),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Tap to take a selfie",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Action to continue
                  //TODO
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OpenAccountSelfie1(
                    frontImage: widget.frontImage,
                    backImage: widget.backImage,
                    accountType: widget.accountType,
                    passportNumber: widget.passportNumber,
                    phoneNumber: widget.phoneNumber,
                    dateOfBirth: widget.dateOfBirth,
                  )),);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "CONTINUE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
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
            readOnly: true,
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