import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/api-customer-accounts.dart';
import '../utils/api-customer-details.dart';
import '../utils/api-customer-term-deposits.dart';
import '../utils/api-login.dart';
import '../utils/util-get-imei.dart';
import '../widgets/dialog-error.dart';
import '../widgets/dialog-transaction-status-check.dart';
import '../widgets/progress-dialog.dart';

class PinInputCommitTDScreen extends StatefulWidget {
  final String transferType;
  final String transactionReference;
  final String debitAccountNumber;
  final String creditAccountNumber;
  final String transactionCurrency;
  final String termDepositType;
  final String maturityInstruction;
  final String debitPhoneNumber;
  final String amount;
  const PinInputCommitTDScreen({
    super.key,
    required this.transferType,
    required this.transactionReference,
    required this.debitAccountNumber,
    required this.creditAccountNumber,
    required this.transactionCurrency,
    required this.termDepositType,
    required this.maturityInstruction,
    required this.debitPhoneNumber,
    required this.amount,
  });

  @override
  State<PinInputCommitTDScreen> createState() => _PinInputCommitTDScreenState();
}

class _PinInputCommitTDScreenState extends State<PinInputCommitTDScreen> {

  final apiCustomerTermDeposit = ApiCustomerTermDeposits();

  bool isLoading = false;
  bool isLoadingShare = false;
  String loginId = 'FALSE';
  String loginPin = 'FALSE';
  String _enteredPin = "";

  final apiLogin = ApiLogin();
  final apiCustomerDetails = ApiCustomerDetails();
  final apiCustomerAccounts = ApiCustomerAccounts();

  @override
  void initState() {
    super.initState();
    _loadSharedPreferencesValue();
  }

  void onKeyPressed(String key) {
    if (_enteredPin.length >= 6) return; // prevent extra digits
    setState(() {
      _enteredPin += key;
    });

    if (_enteredPin.length == 6 && _enteredPin == loginPin) {
      onOkPressed();
    }else if(_enteredPin.length == 6 && _enteredPin != loginPin){
      setState(() {
        _enteredPin = "";
      });
      showSnackBar(context, 'Incorrect PIN entered', Colors.red);
    }
  }

  void onClearPressed() {
    setState(() {
      if (_enteredPin.isNotEmpty) {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      }
    });
  }

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10), // Set to any duration
        backgroundColor: color,
        action: SnackBarAction(
          label: "DISMISS",
          textColor: Colors.white,
          onPressed: () {
            //
          }, // Dismiss action
        ),
      ),
    );
  }

  void showCrossingBallsProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CrossingBallsProgressDialog(message: message,),
    );
  }

  void showErrorDialog(BuildContext context, String messageParent, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorAlertDialog(message: message, onRetry: onRetry, messageParent: messageParent,),
    );
  }

  void onRetry(){
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void onConfirmed(){
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
      loginPin = prefs.getString('USER_LOGIN_PIN') ?? "FALSE";
    });
  }

  Future<void> onOkPressed() async {
    try {
      setState(() {
        isLoading = true;
      });
      //TODO - API
      showCrossingBallsProgressDialog(context, 'We are initiating your payment \n Please Wait...');
      createTermDeposit();
    } catch (error) {
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! An error occurred', error.toString(), onRetry);
      });
    }
  }

  Future<void> createTermDeposit() async {
    try {
      String deviceId = await DeviceIdentifier.getDeviceIdentifier();
      var responseData = await apiCustomerTermDeposit.createTermDeposit(
          deviceId,
          widget.transactionReference,
          widget.debitAccountNumber,
          widget.creditAccountNumber,
          widget.transactionCurrency,
          widget.termDepositType,
          widget.maturityInstruction,
          widget.debitPhoneNumber,
          double.parse(widget.amount),
      );
      if (responseData["data"]["response_code"] == "00" || responseData["data"]["response_code"] == "PM-SAVE-002") {
        setState(() {
          isLoading = false;
          Navigator.pop(context);
        });

        final GlobalKey dialogKey = GlobalKey();
        showDialog(
          context: context,
          builder: (context) => TransactionStatusCheckDialog(
            repaintKey: dialogKey,
            data: TransactionStatusCheckData(
              title: "Term Deposit Request Successful",
              dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.now()),
              reference: widget.transactionReference,
              source: widget.debitAccountNumber,
              destination: widget.creditAccountNumber,
              sourceName: '',
              recipient: 'Self',
              amount: widget.amount.toString(),
              transactionCode: '',
              narration:  'Term Deposit Request',
            ),
            onConfirmed: onConfirmed,
            onShare: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => isLoadingShare = true);
                _shareWidget(dialogKey); // will now find the boundary
                setState(() => isLoadingShare = false);
              });
            },
            isLoading: false,
          ),
        );
      }else{
        setState(() {
          isLoading = false;
          showErrorDialog(context, 'Oops! Your request was not successful', responseData["data"]["response"], onRetry);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! Your request was not successful', error.toString(), onRetry);
      });
      throw Exception('FAILED TO POST BILL-PAYMENT : $error');
    }
  }

  Future<void> _shareWidget(GlobalKey repaintKey) async {
    try {
      if (repaintKey.currentContext == null) {
        debugPrint("Widget not ready yet");
        return;
      }
      RenderRepaintBoundary boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return _shareWidget(repaintKey);
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/receipt.png';
      await File(filePath).writeAsBytes(pngBytes);
      //File imgFile = File(filePath)..writeAsBytesSync(pngBytes);
      await SharePlus.instance.share(
        ShareParams(
          text: "Here is your receipt for the transaction.",
          files: [XFile(filePath)],
        ),
      );
    } catch (e) {
      debugPrint("Error sharing receipt: $e");
    }
  }

  //TODO - Share PDF Code
  // Future<void> _generateStyledPdf() async {
  //   setState(() => isLoadingShare = true);
  //   final pdf = pw.Document();
  //   // Load logo image
  //   //final logoData = await rootBundle.load('assets/images/logo/logo-icon.png'); //Door Logo
  //   //final logoData = await rootBundle.load('assets/images/logo/logo.png'); // Full Logo
  //   //final logo = pw.MemoryImage(logoData.buffer.asUint8List());
  //
  //   final svgLogoData = await rootBundle.loadString('assets/images/logo/logo.svg'); // SVG Logo
  //
  //   const green = PdfColor.fromInt(0xFF48BB78);
  //   const blue = PdfColors.blue;
  //
  //   const name = 'CUSTOMER';
  //   var amount = '${widget.transactionCurrency} ${widget.amount}';
  //   var phoneNumber = widget.debitPhoneNumber;
  //   var date = DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.now());
  //   var paidTo = '${widget.transferType} : SELF';
  //   var transactionNo = widget.transactionReference;
  //   const paymentType = 'Term Deposit Request';
  //   var paybill = widget.creditAccountNumber;
  //
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (context) {
  //         final qrCode = Barcode.qrCode();
  //         final qrSvg = qrCode.toSvg('https://www.bbbank.so/', width: 100, height: 100);
  //
  //         return pw.Padding(
  //           padding: const pw.EdgeInsets.all(24),
  //           child: pw.Column(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               // Existing content ...
  //               //pw.Center(child: pw.Image(logo, height: 50)), // PNG Logo
  //               pw.SvgImage(svg: svgLogoData, height: 50), // SVG Logo
  //               // ✅ Add header line here
  //               pw.Divider(thickness: 1, color: PdfColors.grey),
  //               pw.SizedBox(height: 16),
  //
  //               pw.SizedBox(height: 10),
  //               pw.Text('https://www.bbbank.so',
  //                   style: const pw.TextStyle(
  //                       fontSize: 12,
  //                       color: blue,
  //                       decoration: pw.TextDecoration.underline)
  //               ),
  //               pw.SizedBox(height: 24),
  //               pw.Text('Hi $name,',
  //                   style: pw.TextStyle(
  //                       fontSize: 18, fontWeight: pw.FontWeight.bold)),
  //               pw.SizedBox(height: 16),
  //               pw.Text('Total Amount Paid:',
  //                   style: const pw.TextStyle(fontSize: 14)),
  //               pw.Text(amount,
  //                   style: pw.TextStyle(
  //                       fontSize: 24,
  //                       fontWeight: pw.FontWeight.bold,
  //                       color: green)),
  //               pw.SizedBox(height: 24),
  //               _info('Phone Number:', phoneNumber),
  //               _info('Date:', date),
  //               pw.SizedBox(height: 10),
  //               _info('Paid To:', paidTo),
  //               pw.SizedBox(height: 10),
  //               _info('Transaction No:', transactionNo),
  //               _info('Payment Type:', paymentType),
  //               _info('Beneficiary Account:', paybill),
  //
  //               pw.Spacer(), // Push the QR code to the bottom
  //
  //               // ✅ Add footer line here
  //               pw.Divider(thickness: 1, color: PdfColors.grey),
  //               pw.SizedBox(height: 10),
  //               // ⬇️ QR code addition starts here
  //               pw.Center(
  //                 child: pw.Container(
  //                   width: 100,
  //                   height: 100,
  //                   child: pw.SvgImage(svg: qrSvg),
  //                 ),
  //               ),
  //               pw.SizedBox(height: 10),
  //               pw.Center(
  //                 child: pw.Text('Scan to visit our website',
  //                     style: const pw.TextStyle(fontSize: 10)),
  //               ),
  //               // ⬆️ QR code addition ends here
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  //
  //   final output = await getTemporaryDirectory();
  //   final file = File('${output.path}/payment_receipt.pdf');
  //   await file.writeAsBytes(await pdf.save());
  //
  //   setState(() => isLoadingShare = false);
  //   await Share.shareXFiles([XFile(file.path)], text: 'Here is your Transaction receipt.');
  // }
  // pw.Widget _info(String title, String value) {
  //   return pw.Padding(
  //     padding: const pw.EdgeInsets.only(bottom: 6),
  //     child: pw.RichText(
  //       text: pw.TextSpan(
  //         children: [
  //           pw.TextSpan(
  //               text: '$title ',
  //               style: pw.TextStyle(
  //                   fontWeight: pw.FontWeight.bold, fontSize: 13)),
  //           pw.TextSpan(
  //               text: value,
  //               style: const pw.TextStyle(fontSize: 13)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait = constraints.maxHeight > constraints.maxWidth;
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // Background Image
              Container(
                width: screenWidth,
                height: screenHeight,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/logo/background-image.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Back Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8, // Push below status bar
                left: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 26,
                    weight: 60,
                  ),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                    }
                  },
                ),
              ),
              // Main Content
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: screenHeight),
                  child: Column(
                    children: [
                      SizedBox(height: isPortrait ? 90 : 45),
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
                        'Enter PIN',
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
                          'Please enter your PIN to continue.',
                          style: TextStyle(
                            fontSize: isPortrait ? 14 : 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.blue.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          bool isFilled = index < _enteredPin.length;
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
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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

//TODO - DOTTED DIVIDER
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

//TODO - TRANSFER DONE DIALOG
class TransferDoneDialog extends StatefulWidget {
  final String referenceNumber;
  final String debitAccount;
  final String debitPhoneNumber;
  final String beneficiaryAccount;
  final String beneficiaryName;
  final String currency;
  final double transactionAmount;
  final String narration;

  const TransferDoneDialog({
    super.key,
    required this.referenceNumber,
    required this.debitAccount,
    required this.debitPhoneNumber,
    required this.beneficiaryAccount,
    required this.beneficiaryName,
    required this.currency,
    required this.transactionAmount,
    required this.narration,
  });

  @override
  _TransferDoneDialogState createState() => _TransferDoneDialogState();
}

class _TransferDoneDialogState extends State<TransferDoneDialog> {

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat('MMM d, y | h:mm:ss a').format(now);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 60.0,
              color: Colors.green,
            ),
            const SizedBox(height: 8.0),
            Text(
              "Transfer Done",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 8.0),
            const DottedDivider(
              height: 1.0,  // Thickness of the dots
              width: 10.0,   // Length of each dot
              color: Colors.black,
            ),
            const SizedBox(height: 10.0),
            InfoRow(label: "Date & time", value: formattedDate),
            InfoRow(label: "Reference number", value: widget.referenceNumber),
            InfoRow(label: "Source of funds", value: widget.debitAccount),
            InfoRow(label: "Destination Account", value: widget.beneficiaryAccount),
            InfoRow(label: "Recipient alias", value: widget.beneficiaryName),
            InfoRow(label: "Note(s)", value: widget.narration),
            const SizedBox(height: 8.0),
            const DottedDivider(
              height: 1.0,  // Thickness of the dots
              width: 10.0,   // Length of each dot
              color: Colors.black,
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Transaction",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.currency} ${widget.transactionAmount}',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    //TODO - SHARED
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  label: const Text("Share",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  icon: const Icon(Icons.share, color: Colors.white,),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  icon: const Icon(Icons.done, color: Colors.white,),
                  label: const Text("Done",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

