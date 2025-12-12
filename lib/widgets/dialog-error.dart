import 'package:flutter/material.dart';

class ErrorAlertDialog extends StatelessWidget {
  final String messageParent;
  final String message;
  final VoidCallback onRetry;
  const ErrorAlertDialog({super.key, required this.message, required this.onRetry, required this.messageParent});

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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: CustomPaint(
                painter: SadFacePainter(),
              ),
            ),
            //const Icon(Icons.sentiment_dissatisfied, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              messageParent,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("TRY AGAIN!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

}

class SadFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw eyes
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.3, size.height * 0.4),
        radius: 8,
      ),
      0,
      -3.14,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.7, size.height * 0.4),
        radius: 8,
      ),
      0,
      -3.14,
      false,
      paint,
    );

    // Draw mouth
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.7),
        radius: 20,
      ),
      3.14,
      3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}