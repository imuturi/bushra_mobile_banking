import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class SuccessAlertDialog extends StatelessWidget {
  final String messageParent;
  final String message;
  final VoidCallback onOkay;

  const SuccessAlertDialog({super.key, required this.message, required this.onOkay, required this.messageParent});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green.shade600,
              ),
            ),
            //const Icon(Icons.sentiment_dissatisfied, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              messageParent,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onOkay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child:  Text(AppLocalizations.of(context)!.okay, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}