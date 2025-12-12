import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockedDeviceScreen extends StatelessWidget {
  const BlockedDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade900, size: 80),
              SizedBox(height: 20),
              Text(
                'Security Alert',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'This device appears to be rooted or jailbroken.\n\n'
                    'For your safety and data protection, access to the app is restricted on modified devices.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 40,),
              SizedBox(
                width: double.infinity - 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 24,),
                  label: const Text(
                    "EXIT",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed:(){
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
