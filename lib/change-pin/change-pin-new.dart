import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'change-pin-new-confirm.dart';

class ChangePinNewScreen extends StatefulWidget {
  final String oldPin;
  const ChangePinNewScreen({super.key, required this.oldPin});

  @override
  State<ChangePinNewScreen> createState() => _ChangePinNewScreenState();
}

class _ChangePinNewScreenState extends State<ChangePinNewScreen> {
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
      if(widget.oldPin == enteredPin) {
        // If the old PIN matches the entered PIN, show an error or handle accordingly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New PIN cannot be the same as the old PIN.')),
        );
      } else {
        // Proceed to the confirmation screen with the new PIN
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChangePinNewConfirmationScreen(
          oldPin: widget.oldPin,
          newPin: enteredPin,
        )));
      }
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
                      'Set New PIN',
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
                        'Please enter your new PIN to continue.',
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
