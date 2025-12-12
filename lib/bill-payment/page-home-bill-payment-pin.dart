import 'dart:io';
import 'dart:ui' as ui;
import 'package:bushra_mobile/bill-payment/page-home-bill-payment-main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api-customer-accounts.dart';
import '../utils/api-customer-details.dart';
import '../utils/api-customer-favourites.dart';
import '../utils/api-customer-transfers.dart';
import '../utils/api-login.dart';
import '../utils/providers/provider-balances.dart';
import '../utils/providers/provider-mini-recent.dart';
import '../utils/providers/provider-mini-statement.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-get-imei.dart';
import '../utils/util-log-service.dart';
import '../widgets/dialog-error.dart';
import '../widgets/dialog-transaction-status-check.dart';
import '../widgets/progress-dialog.dart';
import '../models/dto/favourites-add-request.dart';
import '../models/dto/favourites-add-request.dart' as FavouritesAddRequest;
import '../utils/providers/provider-favourites.dart';

class PinInputCommitBillPaymentTransactionScreen extends StatefulWidget {
  final String transferType;
  final String debitAccountNumber;
  final String debitPhoneNumber;
  final double transactionAmount;
  final String transactionCurrency;
  final String transactionNarration;
  final String billerId;
  final String billerCollectionaccount;
  final String billerCategory;
  final String billerCommonField;
  final String billerReference;
  final bool favouriteFlag;

  const PinInputCommitBillPaymentTransactionScreen({
    super.key,
    required this.transferType,
    required this.debitAccountNumber,
    required this.debitPhoneNumber,
    required this.transactionAmount,
    required this.transactionCurrency,
    required this.transactionNarration,
    required this.billerId,
    required this.billerCollectionaccount,
    required this.billerCategory,
    required this.billerCommonField,
    required this.billerReference,
    required this.favouriteFlag,
  });

  @override
  State<PinInputCommitBillPaymentTransactionScreen> createState() => _PinInputCommitBillPaymentTransactionScreenState();
}

class _PinInputCommitBillPaymentTransactionScreenState extends State<PinInputCommitBillPaymentTransactionScreen> {

  final apiCustomerFundsTransfer = ApiCustomerFundsTransfers();

  bool isLoading = false;
  bool isLoadingShare = false;
  String? fcmToken;
  String loginId = 'FALSE';
  String loginPin = 'FALSE';
  String enteredPin = "";

  final apiLogin = ApiLogin();
  final apiCustomerDetails = ApiCustomerDetails();
  final apiCustomerAccounts = ApiCustomerAccounts();
  final apiCustomerFavourites = ApiCustomerFavourites();

  @override
  void initState() {
    super.initState();
    _loadSharedPreferencesValue();
  }

  void onKeyPressed(String key) {
    if (enteredPin.length >= 6) return; // prevent extra digits
    setState(() {
      enteredPin += key;
    });
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false).user;
    if (enteredPin.length == 6 && enteredPin == loginPin) {
      onOkPressed();
    }else if(enteredPin.length == 6 && enteredPin != loginPin){
      setState(() {
        enteredPin = "";
      });
      showSnackBar(context, 'Incorrect PIN entered', Colors.red);
    }
  }

  void onClearPressed() {
    setState(() {
      if (enteredPin.isNotEmpty) {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
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
    final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
    final balanceProvider = Provider.of<BalanceProvider>(context, listen: false);
    final miniStatementsProvider = Provider.of<MiniStatementProvider>(context, listen: false);
    final miniRecentStatementsProvider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
    balanceProvider.fetchBalances(authProvider!.phoneNumber).then((_) {
      miniRecentStatementsProvider.fetchStatementsForAllAccounts(balanceProvider.accounts, authProvider.phoneNumber);
      miniStatementsProvider.fetchStatementsForAllAccounts(balanceProvider.accounts);
    });
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
      loginPin = prefs.getString('USER_LOGIN_PIN') ?? "FALSE";
      fcmToken = prefs.getString('USER_FCM_TOKEN') ?? "FALSE";
    });
  }

  Future<void> onOkPressed() async {
    try {
      setState(() {
        isLoading = true;
      });
      //TODO - API
      showCrossingBallsProgressDialog(context, 'We are initiating your payment \n Please Wait...');
      if(widget.transferType =='BILLPAYMENTSWATER'){
        fundsTransferBillPayment();
      }else{
        fundsTransferBillPayment();
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! An error occurred', error.toString(), onRetry);
      });
    }
  }

  Future<void> fundsTransferBillPayment() async {
    try {
      addFavourite();
      var responseData = await apiCustomerFundsTransfer.fundsTransferBillPayments(
        widget.billerReference,
        widget.transferType,
        widget.billerCategory,
        widget.billerId,
        widget.debitAccountNumber,
        widget.billerCollectionaccount,
        widget.debitPhoneNumber,
        widget.transactionCurrency,
        widget.transactionNarration,
        widget.transactionAmount,
        widget.billerCommonField,
        fcmToken!,
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
              title: "Bill Payment Done",
              dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.now()),
              reference: widget.billerReference,
              source: widget.debitAccountNumber,
              destination: widget.billerCollectionaccount,
              sourceName: '',
              recipient: widget.billerId,
              amount: widget.transactionAmount.toString(),
              transactionCode: '',
              narration:  widget.transactionNarration,
            ),
            onConfirmed: onConfirmed,
            onShare: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _shareWidget(dialogKey); // will now find the boundary
              });
            },
            isLoading: false,
          ),
        );
      }else{
        setState(() {
          isLoading = false;
          showErrorDialog(context, 'Oops! Your bill payment failed', responseData["data"]["response"], onRetry);
        });
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! Your bill payment failed', error.toString(), onRetry);
      });
      throw Exception('FAILED TO POST BILL-PAYMENT : $error');
    }
  }

  Future<void> addFavourite() async {
    if (!widget.favouriteFlag) return;

    try {
      String deviceId = await DeviceIdentifier.getDeviceIdentifier();
      FavouritesAddRequest.ChannelDetails channelDetails = FavouritesAddRequest.ChannelDetails(
          host: "IP",
          geolocation: "1.2921, 36.8219",
          userAgent: Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          userAgentVersion: "1.0",
          channel: "MOBILE",
          clientId: "client123",
          deviceId: deviceId
      );

      final favorites = Provider.of<FavouritesProvider>(context, listen: false).favorites;

      if (favorites?.data.favourites.billpayment.isNotEmpty ?? false) {
        for (var beneficiary in favorites!.data.favourites.billpayment) {
          if (beneficiary.name == widget.billerId && beneficiary.amount == widget.transactionAmount) {
            showSnackBar(context, 'This beneficiary is already in your favourites', Colors.red);
            return;
          }
        }
      }

      /// Bill Favourites
      final int count = favorites?.data.favourites.billpayment.length ?? 0;
      int value = count + 1;
      Beneficiary beneficiary = Beneficiary(
          id: value.toString(),
          name: widget.billerId,
          bankcode: "000000",
          type: widget.transferType, // TV, GOVERNMENT,INTERNET,WATER, ELECTRICITY
          amount: widget.transactionAmount.toString(),
          recipient: widget.billerCollectionaccount
      );

      FavouritesAddRequest.TransactionDetails transactionDetails;
      Favourite favourite;
      List<Beneficiary> beneficiaryList = [];
      beneficiaryList.add(beneficiary);

      beneficiaryList.add(beneficiary);
      favourite = Favourite(billpayment: beneficiaryList,);
      transactionDetails = FavouritesAddRequest.TransactionDetails(phoneNumber: widget.debitPhoneNumber,
          favourites: [favourite]
      );
      TransactionRequest request = TransactionRequest(
          xref: "${widget.billerReference}FAV",
          txntimestamp: DateTime.now().toUtc().toIso8601String(),
          transactionDetails: transactionDetails,
          channelDetails: channelDetails
      );
      var response = await apiCustomerFavourites.postCustomerFavourites(request);
      if (response["data"]["response_code"] == "00") {
        if (kDebugMode) {
          print("FAVOURITE ADDED SUCCESSFULLY");
        }
      }else{
        if (kDebugMode) {
          print("FAVOURITE NOT ADDED");
        }
      }

    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      if (kDebugMode) {
        print("Error adding favourite: $error");
      }
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
  //
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
  //   var amount = '${widget.transactionCurrency} ${widget.transactionAmount}';
  //   var phoneNumber = widget.debitPhoneNumber;
  //   var date = DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.now());
  //   var paidTo = '${widget.transferType} : ${widget.billerId}';
  //   var transactionNo = widget.billerReference;
  //   const paymentType = 'Bill Payment';
  //   var paybill = widget.billerCollectionaccount;
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  const PayBillMainScreen()));
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
                      // TextButton(
                      //   onPressed: () {
                      //     Navigator.pushNamed(context, '/forgot-password');
                      //   },
                      //   child: const Text(
                      //     'Forgot PIN?',
                      //     style: TextStyle(
                      //       color: Colors.black,
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
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