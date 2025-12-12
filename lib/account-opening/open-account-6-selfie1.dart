import 'dart:io';

import 'package:flutter/material.dart';
import 'open-account-7-selfie2.dart';

class OpenAccountSelfie1 extends StatefulWidget {
  final File frontImage;
  final File backImage;
  final String accountType;
  final String passportNumber;
  final String phoneNumber;
  final String dateOfBirth;

  const OpenAccountSelfie1({
    super.key,
    required this.frontImage,
    required this.backImage,
    required this.accountType,
    required this.passportNumber,
    required this.phoneNumber,
    required this.dateOfBirth
  });

  @override
  State<OpenAccountSelfie1> createState() => _OpenAccountSelfie1StateScreen();
}
class _OpenAccountSelfie1StateScreen extends State<OpenAccountSelfie1> {

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
          "Take Selfie",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Take a selfie of yourself",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Take a selfie and we will do a face match with the photo on your National ID.",
              //textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 0)),
                child: Image.asset(
                  'assets/images/gif/face-scan.gif',
                  fit: BoxFit.cover,
                  height: 300, // set your height
                  width: 300, // and width here
                ),
              ),
            ),

            const SizedBox(height: 180,),
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //TODO
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OpenAccountSelfie2(
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
                  "TAKE SELFIE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}