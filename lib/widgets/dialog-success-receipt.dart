import 'package:flutter/material.dart';

class SuccessTransactionData {
  final String title;
  final String dateTime;
  final String reference;
  final String source;
  final String destination;
  final String recipient;
  final String amount;
  final String narration;

  SuccessTransactionData({
    required this.title,
    required this.dateTime,
    required this.reference,
    required this.source,
    required this.destination,
    required this.recipient,
    required this.amount,
    required this.narration,
  });
}

class SuccessReceiptDialog extends StatelessWidget {
  final SuccessTransactionData data;
  final VoidCallback onConfirmed;
  final VoidCallback onShare;
  final bool isLoading;

  const SuccessReceiptDialog({
    super.key,
    required this.data,
    required this.onConfirmed,
    required this.onShare,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {

    final Size screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;
    final double fontSizeTitle = isLandscape ? 22 : 18;
    final double fontSizeDetail = isLandscape ? 16 : 14;
    final double fontSizeAmount = isLandscape ? 24 : 20;

    return Stack(
      alignment: Alignment.center,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLandscape ? 500 : 400,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ClipPath(
                    clipper: TicketClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: fontSizeAmount + 50, color: Colors.green.shade500),
                          Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fontSizeTitle,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const DottedDivider(),
                          const SizedBox(height: 10),
                          _transactionDetail(context, "Date & time", data.dateTime, fontSizeDetail),
                          _transactionDetail(context, "Reference No", data.reference, fontSizeDetail),
                          _transactionDetail(context, "Source of funds", data.source, fontSizeDetail),
                          _transactionDetail(context, "Destination Account", data.destination, fontSizeDetail),
                          _transactionDetail(context, "Recipient alias", data.recipient, fontSizeDetail),
                          _transactionDetail(context, "Note(s)", data.narration, fontSizeDetail),
                          const SizedBox(height: 10),
                          const DottedDivider(),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Transaction",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSizeDetail,
                                  ),
                                ),
                                Text(
                                  "\$${data.amount}",
                                  style: TextStyle(
                                    fontSize: fontSizeAmount,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo.shade900,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: isLoading ? null : onShare,
                                  label: const Text("Share", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  icon: const Icon(Icons.share, size: 16, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade900,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: isLoading ? null : onConfirmed,
                                  label: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  icon: const Icon(Icons.check, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );


    // return Dialog(
    //   backgroundColor: Colors.transparent,
    //   insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // minimal margin to edges
    //   child: SingleChildScrollView(
    //     child: Center(
    //       child: ConstrainedBox(
    //         constraints: BoxConstraints(
    //           maxWidth: isLandscape ? 500 : 400, // Wider in portrait, still max cap
    //         ),
    //         child: ClipRRect(
    //           borderRadius: BorderRadius.circular(20),
    //           child: ClipPath(
    //             clipper: TicketClipper(),
    //             child: Container(
    //               decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.circular(20),
    //                 boxShadow: const [
    //                   BoxShadow(
    //                     color: Colors.black26,
    //                     blurRadius: 5,
    //                     spreadRadius: 1,
    //                     offset: Offset(0, 3),
    //                   ),
    //                 ],
    //               ),
    //               padding: const EdgeInsets.all(20),
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Icon(Icons.check_circle, size: fontSizeAmount + 20, color: Colors.green.shade500),
    //                   const SizedBox(height: 10),
    //                   Text(
    //                     data.title,
    //                     textAlign: TextAlign.center,
    //                     style: TextStyle(
    //                       fontSize: fontSizeTitle,
    //                       fontWeight: FontWeight.bold,
    //                       color: Colors.red.shade900,
    //                     ),
    //                   ),
    //                   const SizedBox(height: 10),
    //                   const DottedDivider(),
    //                   const SizedBox(height: 10),
    //                   _transactionDetail(context, "Date & time", data.dateTime, fontSizeDetail),
    //                   _transactionDetail(context, "Reference No", data.reference, fontSizeDetail),
    //                   _transactionDetail(context, "Source of funds", data.source, fontSizeDetail),
    //                   _transactionDetail(context, "Destination Account", data.destination, fontSizeDetail),
    //                   _transactionDetail(context, "Recipient alias", data.recipient, fontSizeDetail),
    //                   _transactionDetail(context, "Note(s)", data.narration, fontSizeDetail),
    //                   const SizedBox(height: 10),
    //                   const DottedDivider(),
    //                   const SizedBox(height: 10),
    //                   Padding(
    //                     padding: const EdgeInsets.symmetric(vertical: 8),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text(
    //                           "Total Transaction",
    //                           style: TextStyle(
    //                             fontWeight: FontWeight.bold,
    //                             fontSize: fontSizeDetail,
    //                           ),
    //                         ),
    //                         Text(
    //                           "\$${data.amount}",
    //                           style: TextStyle(
    //                             fontSize: fontSizeAmount,
    //                             fontWeight: FontWeight.bold,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   const SizedBox(height: 10),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //
    //                       Expanded(
    //                         child: ElevatedButton.icon(
    //                           style: ElevatedButton.styleFrom(
    //                             backgroundColor: Colors.indigo.shade900,
    //                             padding: const EdgeInsets.symmetric(vertical: 12),
    //                           ),
    //                           onPressed: onShare,
    //                           label: const Text("Share", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    //                           icon: const Icon(Icons.share, size: 16, color: Colors.white),
    //                         ),
    //                       ),
    //
    //                       const SizedBox(width: 10),
    //                       Expanded(
    //                         child: ElevatedButton.icon(
    //                           style: ElevatedButton.styleFrom(
    //                             backgroundColor: Colors.red.shade900,
    //                             padding: const EdgeInsets.symmetric(vertical: 12),
    //                           ),
    //                           onPressed: onConfirmed,
    //                           label: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    //                           icon: const Icon(Icons.check, size: 16, color: Colors.white),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _transactionDetail(BuildContext context, String title, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : '-',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }

}

// Custom Clipper for Ticket Shape
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 20.0;
    double holeRadius = 8.0;
    int holes = 10;
    double spacing = size.width / holes;

    Path path = Path();

    // Top left rounded corner
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Top edge with circular cutouts
    for (double i = radius; i < size.width - radius; i += spacing) {
      path.arcToPoint(
        Offset(i + spacing / 2, 0),
        radius: Radius.circular(holeRadius),
        clockwise: false,
      );
      path.arcToPoint(
        Offset(i + spacing, 0),
        radius: Radius.circular(holeRadius),
        clockwise: true,
      );
    }

    // Top right rounded corner
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Right side
    path.lineTo(size.width, size.height - radius);

    // Bottom right rounded corner
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);

    // Bottom edge with circular cutouts
    for (double i = size.width - radius; i > radius; i -= spacing) {
      path.arcToPoint(
        Offset(i - spacing / 2, size.height),
        radius: Radius.circular(holeRadius),
        clockwise: false,
      );
      path.arcToPoint(
        Offset(i - spacing, size.height),
        radius: Radius.circular(holeRadius),
        clockwise: true,
      );
    }

    // Bottom left rounded corner
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // Left side
    path.lineTo(0, radius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class DottedDivider extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const DottedDivider({
    super.key,
    this.height = 1.0,
    this.width = 5.0,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: DashPainter(width: width, color: color),
    );
  }
}

class DashPainter extends CustomPainter {
  final double width;
  final Color color;
  DashPainter({required this.width, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final space = width;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + width, size.height / 2),
        paint,
      );
      startX += width + space;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
