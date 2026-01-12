import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/api-customer-accounts.dart';
import '../../utils/api-customer-details.dart';
import '../../utils/api-customer-favourites.dart';
import '../../utils/api-customer-transfers.dart';
import '../../utils/api-login.dart';
import '../../utils/providers/provider-balances.dart';
import '../../utils/providers/provider-mini-recent.dart';
import '../../utils/providers/provider-mini-statement.dart';
import '../../utils/providers/provider-session.dart';
import '../../utils/util-log-service.dart';
import '../../widgets/dialog-error.dart';
import '../../widgets/dialog-transaction-status-check.dart';
import '../../widgets/progress-dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PinInputCommitTransactionRemittanceScreen extends StatefulWidget {
  final String transferType;
  final String transactionReference;
  final String debitAccount;
  final String debitPhoneNumber;
  final String debitCurrency;
  final String debitCustomerName;
  final double debitAmount;
  final double convertedAmount;
  final String fromCurrency;
  final String toCurrency;
  final String destinationChannelCode;
  final String destinationChannelName;
  final String receiverPhoneNumber;
  final String receiverAccount;
  final String receiverAccountName;
  final String senderName;
  final String senderDOB;
  final String senderCountryISO;
  final String senderNationality;
  final String senderIDType;
  final String senderIDNumber;
  final String narration;
  final bool isFavorite;


  const PinInputCommitTransactionRemittanceScreen({
    super.key,
    required this.transferType,
    required this.transactionReference,
    required this.debitAccount,
    required this.debitPhoneNumber,
    required this.debitCurrency,
    required this.debitCustomerName,
    required this.debitAmount,
    required this.convertedAmount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.destinationChannelCode,
    required this.destinationChannelName,
    required this.receiverPhoneNumber,
    required this.receiverAccountName,
    required this.receiverAccount,
    required this.senderName,
    required this.senderDOB,
    required this.senderCountryISO,
    required this.senderNationality,
    required this.senderIDType,
    required this.senderIDNumber,
    required this.narration,
    required this.isFavorite,
  });

  @override
  State<PinInputCommitTransactionRemittanceScreen> createState() => _PinInputCommitTransactionRemittanceScreenState();
}

class _PinInputCommitTransactionRemittanceScreenState extends State<PinInputCommitTransactionRemittanceScreen> {
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
      await fundsTransferRemittance();
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! Your transfer was not successful', error.toString(), onRetry);
      });
    }
  }

  Future<void> fundsTransferRemittance() async {
    try {
      final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
      //addFavourite(widget.transferType);
      var responseData = await apiCustomerFundsTransfer.fundsTransferRemittance(
        widget.transactionReference,
        widget.debitAccount,
        widget.debitCurrency,
        widget.receiverAccount,
        //widget.receiverPhoneNumber.replaceFirst("+", ""),
        widget.debitPhoneNumber,
        widget.fromCurrency,
        widget.toCurrency,
        widget.debitAmount,
        widget.convertedAmount,
        fcmToken!,
        destinationChannelCode: widget.destinationChannelCode,
        destinationChannelName: widget.destinationChannelName,
        receiverPhoneNumber: widget.receiverPhoneNumber,
        //receiverPhoneNumber: widget.receiverPhoneNumber.replaceFirst("+", ""),
        receiverAccountName: widget.receiverAccountName,
        senderName: authProvider!.customerDetails.customerName,
        senderDOB: authProvider.customerDetails.dateOfBirth ?? '1990-01-01',
        senderCountryISO: 'SO',
        senderNationality: 'KENYAN',
        senderIDType: authProvider.customerDetails.idType,
        senderIDNumber: authProvider.customerDetails.idNumber,
        narration: widget.narration,
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
              destination: widget.receiverPhoneNumber,
              sourceName: widget.debitCustomerName,
              recipient: widget.receiverAccountName,
              amount: widget.debitAmount.toString(),
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
                        AppLocalizations.of(context)!.enterPin,
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
                          AppLocalizations.of(context)!.pleaseEnterYourPinToContinue,
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

