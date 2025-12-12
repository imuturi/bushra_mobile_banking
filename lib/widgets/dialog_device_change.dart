import 'package:flutter/material.dart';

class DeviceChangeDialog extends StatelessWidget {
  final VoidCallback onGetDirection;
  final VoidCallback onCallCustomerCare;

  const DeviceChangeDialog({
    super.key,
    required this.onGetDirection,
    required this.onCallCustomerCare,
  });

  static Future<void> show(BuildContext context,
      {required VoidCallback onGetDirection,
        required VoidCallback onCallCustomerCare}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeviceChangeDialog(
        onGetDirection: onGetDirection,
        onCallCustomerCare: onCallCustomerCare,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Device Change',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dear customer we have noticed a device change\n'
                  'For mobile banking. Please call or visit\n'
                  'Our branch for activation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2479),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onGetDirection,
                    child: const Text(
                      'GET DIRECTION',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onCallCustomerCare,
                    child: const Text(
                      'CALL CUSTOMER CARE',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
