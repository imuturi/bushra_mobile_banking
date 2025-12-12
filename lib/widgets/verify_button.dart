import 'package:flutter/material.dart';

class ResendOTPButton extends StatelessWidget {

  final double screenHeight;
  final double screenWidth;

  const ResendOTPButton({super.key, required this.screenHeight, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Container(
                  alignment: Alignment.center,
                  height: screenHeight * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/password-entry.png',
                        height: 100,
                        width: 100,
                      ),
                      const Text(
                        'SUCCESS',
                        style: TextStyle(
                            color: Color(0xFFFF5840),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
      child: Container(
        alignment: Alignment.center,
        height: screenHeight * 0.06,
        // width: screenWidth * 0.4,
        decoration: const BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: const Text(
          'RESEND ',
          style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 25
          ),
        ),
      ),
    );
  }
}