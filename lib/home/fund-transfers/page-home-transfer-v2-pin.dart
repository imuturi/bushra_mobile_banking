import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/dto/favourites-add-request.dart';
import '../../utils/api-customer-accounts.dart';
import '../../utils/api-customer-details.dart';
import '../../utils/api-customer-favourites.dart';
import '../../utils/api-customer-transfers.dart';
import '../../utils/api-login.dart';
import '../../utils/providers/provider-balances.dart';
import '../../utils/providers/provider-favourites.dart';
import '../../utils/providers/provider-mini-recent.dart';
import '../../utils/providers/provider-mini-statement.dart';
import '../../utils/providers/provider-session.dart';
import '../../utils/util-get-imei.dart';
import '../../utils/util-get-location.dart';
import '../../utils/util-log-service.dart';
import '../../widgets/dialog-error.dart';
import '../../widgets/dialog-transaction-status-check.dart';
import '../../widgets/progress-dialog.dart';

class PinInputCommitTransactionScreen extends StatefulWidget {
  final String transferType;
  final String? spsTransferType;
  final String transactionReference;
  final String debitAccount;
  final String debitPhoneNumber;
  final String beneficiaryAccount;
  final String beneficiaryName;
  final String currency;
  final String transactionAmount;
  final String narration;
  final String? telco;
  final String? beneficiaryBankCode;
  final bool isFavorite;

  const PinInputCommitTransactionScreen({
    super.key,
    required this.transferType,
    this.spsTransferType,
    required this.transactionReference,
    required this.debitAccount,
    required this.debitPhoneNumber,
    required this.beneficiaryAccount,
    required this.beneficiaryName,
    required this.currency,
    required this.transactionAmount,
    required this.narration,
    this.telco,
    this.beneficiaryBankCode,
    required this.isFavorite,
  });

  @override
  State<PinInputCommitTransactionScreen> createState() => _PinInputCommitTransactionScreenState();
}

class _PinInputCommitTransactionScreenState extends State<PinInputCommitTransactionScreen> {
  final apiCustomerFundsTransfer = ApiCustomerFundsTransfers();
  bool isLoading = false;
  bool isLoadingShare = false;
  String? fcmToken;
  String loginId = 'FALSE';
  String loginPin = 'FALSE';
  String _enteredPin = "";

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
        duration: const Duration(seconds: 8), // Set to any duration
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
      showCrossingBallsProgressDialog(context, 'We are initiating your transfer \n Please Wait...');
      if(widget.transferType =='INTERNALFUNDSTRANSFER-OTHERS'){
        fundsTransferOthers();
      }else if(widget.transferType == 'INTERNALFUNDSTRANSFER-SELF'){
        fundsTransferSelf();
      }else if(widget.transferType == 'ACOOUNTTOMNOTRANSFER'){
        fundsTransferMno();
      }else if(widget.transferType == 'SPSOUTGOINGTRANSFER'){
        fundsTransferSps();
      }else if(widget.transferType == 'REMMITANCE'){
        fundsTransferOthers();
      }else{
        fundsTransferOthers();
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! Your transfer was not successful', error.toString(), onRetry);
      });
    }
  }

  Future<void> fundsTransferSelf() async {
    try {
      addFavourite(widget.transferType);
      double amount = double.tryParse(widget.transactionAmount) ?? 0.0;
      var responseData = await apiCustomerFundsTransfer.fundsTransfer(
          widget.transactionReference,
          widget.debitAccount,
          widget.beneficiaryAccount,
          widget.debitPhoneNumber,
          widget.currency,
          widget.narration,
          amount,
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
              title: "Transfer Done",
              dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.now()),
              reference: widget.transactionReference,
              source: widget.debitAccount,
              destination: widget.beneficiaryAccount,
              sourceName: widget.beneficiaryName,
              recipient: widget.beneficiaryName,
              amount: amount.toString(),
              transactionCode: '',
              narration:  widget.narration,
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
          showErrorDialog(context, 'Oops! Your transfer was not successful', responseData["data"]["response"], onRetry);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! Your transfer was not successful', error.toString(), onRetry);
      });
      throw Exception('FAILED TO POST IFT : $error');
    }
  }

  Future<void> fundsTransferOthers() async {
    try {
      addFavourite(widget.transferType);
      double amount = double.tryParse(widget.transactionAmount) ?? 0.0;
      var responseData = await apiCustomerFundsTransfer.fundsTransfer(
          widget.transactionReference,
          widget.debitAccount,
          widget.beneficiaryAccount,
          widget.debitPhoneNumber,
          widget.currency,
          widget.narration,
          amount,
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
              title: "Transfer Done",
              dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.now()),
              reference: widget.transactionReference,
              source: widget.debitAccount,
              destination: widget.beneficiaryAccount,
              sourceName: widget.beneficiaryName,
              recipient: widget.beneficiaryName,
              amount: amount.toString(),
              transactionCode: '',
              narration:  widget.narration,
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
          showErrorDialog(context, 'Oops! Your transfer was not successful', responseData["data"]["response"], onRetry);
        });
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! Your transfer was not successful', error.toString(), onRetry);
      });
      throw Exception('FAILED TO POST IFT : $error');
    }
  }

  Future<void> fundsTransferMno() async {
    try {
      addFavourite(widget.transferType);
      double amount = double.tryParse(widget.transactionAmount) ?? 0.0;
      var responseData = await apiCustomerFundsTransfer.fundsTransferMno(
          widget.transactionReference,
          widget.debitAccount,
          widget.debitPhoneNumber,
          widget.currency,
          widget.narration,
          amount,
          widget.telco!,
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
              title: "Transfer Done",
              dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.now()),
              reference: widget.transactionReference,
              source: widget.debitAccount,
              destination: widget.beneficiaryAccount,
              sourceName: widget.beneficiaryName,
              recipient: widget.beneficiaryName,
              amount: amount.toString(),
              transactionCode: '',
              narration:  widget.narration,
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
          showErrorDialog(context, 'Oops! Your transfer was not successful', responseData["data"]["response"], onRetry);
        });
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! Your transfer was not successful', error.toString(), onRetry);
      });
      throw Exception('FAILED TO POST IFT : $error');
    }
  }

  Future<void> fundsTransferSps() async {
    try {
      final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
      addFavourite(widget.transferType);
      double amount = double.tryParse(widget.transactionAmount) ?? 0.0;
      var responseData = await apiCustomerFundsTransfer.fundsTransferSps(
          widget.transactionReference,
          widget.debitAccount,
          widget.beneficiaryAccount,
          widget.debitPhoneNumber,
          widget.currency,
          widget.narration,
          amount,
          widget.beneficiaryBankCode!,
          fcmToken!,
          widget.spsTransferType!,
          authProvider!.customerDetails.customerName,
          widget.beneficiaryName,
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
              title: "Transfer Done",
              dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.now()),
              reference: widget.transactionReference,
              source: widget.debitAccount,
              destination: widget.beneficiaryAccount,
              sourceName: widget.beneficiaryName,
              recipient: widget.beneficiaryName,
              amount: amount.toString(),
              transactionCode: '',
              narration:  widget.narration,
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
          showErrorDialog(context, 'Oops! Your transfer was not successful', responseData["data"]["response"], onRetry);
        });
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! Your transfer was not successful', error.toString(), onRetry);
      });
      throw Exception('FAILED TO POST IFT : $error');
    }
  }

  Future<void> addFavourite(String category) async {
    if (!widget.isFavorite) return;
    try {
      ChannelDetails channelDetails = ChannelDetails(
          host: DeviceLocation.getLocalIpAddress().toString(),
          geolocation: "1.2921, 36.8219",
          userAgent: Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
          userAgentVersion: "1.0",
          channel: "MOBILE",
          clientId: "client123",
          deviceId: await DeviceIdentifier.getDeviceIdentifier(),
      );

      final favorites = Provider.of<FavouritesProvider>(context, listen: false).favorites;
      if (favorites?.data.favourites.ift.isNotEmpty ?? false) {
        for (var beneficiary in favorites!.data.favourites.ift) {
          if (beneficiary.name == widget.beneficiaryName && beneficiary.amount == widget.transactionAmount) {
            showSnackBar(context, 'This beneficiary is already in your favourites', Colors.red);
            return;
          }
        }

      }
      if (favorites?.data.favourites.sps.isNotEmpty ?? false) {
        for (var beneficiary in favorites!.data.favourites.sps) {
          if (beneficiary.name == widget.beneficiaryName && beneficiary.amount == widget.transactionAmount) {
            showSnackBar(context, 'This beneficiary is already in your favourites', Colors.red);
            return;
          }
        }
      }

      if (favorites?.data.favourites.billpayment.isNotEmpty ?? false) {
        for (var beneficiary in favorites!.data.favourites.billpayment) {
          if (beneficiary.name == widget.beneficiaryName && beneficiary.amount == widget.transactionAmount) {
            showSnackBar(context, 'This beneficiary is already in your favourites', Colors.red);
            return;
          }
        }
      }

      if(category == 'INTERNALFUNDSTRANSFER-OTHERS' || category == 'REMITTANCE' || category == 'INTERNALFUNDSTRANSFER-SELF' || category == 'ACOOUNTTOMNOTRANSFER') {
        /// IFT Favourites
        final int count = favorites?.data.favourites.ift.length ?? 0;
        int value = count + 1;
        Beneficiary beneficiary = Beneficiary(
            id: value.toString(),
            name: widget.beneficiaryName,
            bankcode: widget.beneficiaryBankCode ?? "000000",
            type: category, //TODO - Change this to the correct type
            amount: widget.transactionAmount,
            recipient: widget.beneficiaryAccount
        );

        TransactionDetails transactionDetails;
        Favourite favourite;
        List<Beneficiary> beneficiaryList = [];
        beneficiaryList.add(beneficiary);

        favourite = Favourite(ift: beneficiaryList,);
        transactionDetails = TransactionDetails(phoneNumber: widget.debitPhoneNumber,
            favourites: [favourite]
        );
        TransactionRequest request = TransactionRequest(
            xref: "${widget.transactionReference}FAV",
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
      }else if(category == 'SPSOUTGOINGTRANSFER') {
        /// SPS Favourites
        final int count = favorites?.data.favourites.sps.length ?? 0;
        int value = count + 1;
        Beneficiary beneficiary = Beneficiary(
            id: value.toString(),
            name: widget.beneficiaryName,
            bankcode: widget.beneficiaryBankCode ?? "000000",
            type: category, //TODO - Change this to the correct type
            amount: widget.transactionAmount,
            recipient: widget.beneficiaryAccount
        );

        TransactionDetails transactionDetails;
        Favourite favourite;
        List<Beneficiary> beneficiaryList = [];
        beneficiaryList.add(beneficiary);

        beneficiaryList.add(beneficiary);
        favourite = Favourite(sps: beneficiaryList,);
        transactionDetails = TransactionDetails(phoneNumber: widget.debitPhoneNumber,
            favourites: [favourite]
        );
        TransactionRequest request = TransactionRequest(
            xref: "${widget.transactionReference}FAV",
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
      }else if(category == 'BILL') {
        /// Bill Favourites
        final int count = favorites?.data.favourites.billpayment.length ?? 0;
        int value = count + 1;
        Beneficiary beneficiary = Beneficiary(
            id: value.toString(),
            name: widget.beneficiaryName,
            bankcode: widget.beneficiaryBankCode ?? "000000",
            type: category, //TODO - Change this to the correct type
            amount: widget.transactionAmount,
            recipient: widget.beneficiaryAccount
        );

        TransactionDetails transactionDetails;
        Favourite favourite;
        List<Beneficiary> beneficiaryList = [];
        beneficiaryList.add(beneficiary);

        beneficiaryList.add(beneficiary);
        favourite = Favourite(billpayment: beneficiaryList,);
        transactionDetails = TransactionDetails(phoneNumber: widget.debitPhoneNumber,
            favourites: [favourite]
        );
        TransactionRequest request = TransactionRequest(
            xref: "${widget.transactionReference}FAV",
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
  //   var amount = '${widget.currency} ${widget.transactionAmount}';
  //   var phoneNumber = widget.debitPhoneNumber;
  //   var date = DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.now());
  //   var paidTo = '${widget.transferType} : ${widget.beneficiaryName}';
  //   var transactionNo = widget.transactionReference;
  //   const paymentType = 'Funds Transfer';
  //   var paybill = widget.beneficiaryAccount;
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

