import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../l10n/app_localizations.dart';
import 'landing-register-4-pin-confirm.dart';

class RegisterPinInputScreen1 extends StatefulWidget {
  const RegisterPinInputScreen1({super.key});

  @override
  State<RegisterPinInputScreen1> createState() => _RegisterPinInputScreen1State();
}

class _RegisterPinInputScreen1State extends State<RegisterPinInputScreen1> {

  String enteredPin = "";
  @override
  void initState() {
    super.initState();
  }

  void onKeyPressed(String key) {
    if (enteredPin.length >= 6) return; // prevent extra digits
    setState(() {
      enteredPin += key;
    });
    if (enteredPin.length == 6) {
      // Automatically call the OK handler
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

  void onOkPressed() {
    // You can add any action here for the "OK" button
    if (enteredPin.length == 6) {
      //TODO
      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPinInputScreen2(customerPin: enteredPin,)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterA6DigitPin)),
      );
    }
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
                      AppLocalizations.of(context)!.createYourNewPin,
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
                        AppLocalizations.of(context)!.setYourPersonal6DigitCodeItWillBeUsedForSecureAndLastSignin,
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
                      AppLocalizations.of(context)!.thisKeepsYourAccountSecure,
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

