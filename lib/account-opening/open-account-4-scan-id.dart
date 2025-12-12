import 'package:flutter/material.dart';
import 'id-capture.dart';
import 'open-account-5-scan-id.dart';

class OpenAccountVerifyIdentityScreen4 extends StatefulWidget {
  final String accountType;
  final String passportNumber;
  final String phoneNumber;
  final String dateOfBirth;

  const OpenAccountVerifyIdentityScreen4({
    super.key,
    required this.accountType,
    required this.passportNumber,
    required this.phoneNumber,
    required this.dateOfBirth
  });

  @override
  State<OpenAccountVerifyIdentityScreen4> createState() => _OpenAccountVerifyIdentityScreen4();
}
class _OpenAccountVerifyIdentityScreen4 extends State<OpenAccountVerifyIdentityScreen4> {

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
          "Scan identification",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Subtitle
                      const Text(
                        "Take a photo of your ID",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Take a photo of the front side and back side of your ID and we will do a face match of your photo and ID.",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 24),
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
                    ],
                  ),
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //TODO
                    Navigator.push(context, MaterialPageRoute(builder: (context) => IdCaptureScreen(
                      accountType: widget.accountType,
                      passportNumber: widget.passportNumber,
                      phoneNumber: widget.phoneNumber,
                      dateOfBirth: widget.dateOfBirth,)
                    ),);
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
            )
          ],
        ),
      ),
    );
  }
  /*
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //TODO
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const OpenAccountVerifyIdentityScreen()),);
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
          ],
        ),
      ),
   */
}

