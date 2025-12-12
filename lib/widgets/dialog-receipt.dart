import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'dialog-transaction-status-check.dart';

class TransactionStatusCheckDialog2 extends StatelessWidget {
  final TransactionStatusCheckData data;
  final VoidCallback onConfirmed;
  final VoidCallback onShare;
  final bool isLoading;
  final GlobalKey repaintKey;

  const TransactionStatusCheckDialog2({
    Key? key,
    required this.data,
    required this.onConfirmed,
    required this.onShare,
    required this.isLoading,
    required this.repaintKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Screenshot only this section
            RepaintBoundary(
              key: repaintKey,
              child: Column(
                children: [
                  Text(data.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(data.dateTime),
                  const SizedBox(height: 8),
                  Text("Reference: ${data.reference}"),
                  const SizedBox(height: 8),
                  Text("Amount: ${data.amount}"),
                  const SizedBox(height: 8),
                  Text("Narration: ${data.narration}"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Buttons (not inside the repaint boundary)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onConfirmed, child: const Text("OK")),
                TextButton(onPressed: onShare, child: const Text("Share")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
