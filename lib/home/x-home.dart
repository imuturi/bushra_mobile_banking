import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models/account-card-model.dart';
import '../remote-config-services.dart';
import '../notifications/page-home-alert.dart';
import '../utils/util-log-service.dart';
import '../utils/api-customer-transfers.dart';
import '../utils/constants/app_constants.dart';
import '../utils/providers/provider-balances.dart';
import '../utils/providers/provider-mini-recent.dart';
import '../utils/providers/provider-notifications.dart';
import '../utils/reference-generator.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-check-internet.dart';
import '../utils/util-http-client.dart';
import '../widgets/account-card.dart';
import '../widgets/dialog-transaction-status-check.dart';
import 'page-home-recent-transactions.dart';
import 'x-settings.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});
  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final ScrollController _accountScrollController = ScrollController();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  int _activeAccountIndex = 0;
  bool _dialogShown = false;
  bool _isNoInternet = false;
  bool isLoadingShare = false;
  bool isLoading = true;
  late String _currentIndexAccountNumber;

  final List<String> adImages = [
    'assets/images/adverts/ads screens-01.png',
    'assets/images/adverts/ads screens-02.png',
    'assets/images/adverts/ads screens-03.png',
    'assets/images/adverts/ads screens-04.png',
    'assets/images/adverts/ads screens-05.png',
  ];

  final apiQueryTransactionStatus = ApiCustomerFundsTransfers();
  final referenceGenerator = ReferenceGenerator();
  ShareTransactionDetails shareTransactionDetails = ShareTransactionDetails();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<SessionProvider>(context, listen: false);
    setState(() {
      _currentIndexAccountNumber = authProvider.user!.accounts[0].accountNumber;
    });
  }

  @override
  void initState(){
    super.initState();
    _accountScrollController.addListener(_onScroll);
    _startListening();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _accountScrollController.removeListener(_onScroll);
    _accountScrollController.dispose();
    super.dispose();
  }

  //TODO - Transaction Status Confirm
  void onConfirmed(){
    Navigator.pop(context);
  }
  //TODO - Transaction Status Share
  // void onShare(GlobalKey repaintKey){
  //   // _shareWidget(repaintKey);
  //   _generateStyledPdf();
  // }

  void _startListening() {
    _connectivitySubscription = InternetCheckerService().connectivityStream.listen((results) async {
      bool noNetwork = results.contains(ConnectivityResult.none);
      if (noNetwork) {
        //_showNoInternetDialog();
        _showNoInternetNotification();
      } else {
        // Even if network is connected, check if internet is available
        bool hasInternet = await InternetCheckerService().hasInternetConnection();
        if (!hasInternet) {
          //_showNoInternetDialog();
          _showNoInternetNotification();
        } else {
          _dismissDialogIfAny();
        }
      }
    });
  }

  void _dismissDialogIfAny() {
    if (_dialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
      _dialogShown = false;
    }
  }

  void _showNoInternetNotification() {
    if (!_isNoInternet) {
      setState(() {
        _isNoInternet = true;
      });
      // Show a bottom sheet notification
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: Colors.yellow.shade500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.signal_wifi_off, // Broken WiFi icon
                  color: Colors.black,
                  size: 30,
                ),
                const SizedBox(width: 10),
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    _dismissNoInternetNotification();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _dismissNoInternetNotification() {
    if (_isNoInternet) {
      setState(() {
        _isNoInternet = false;
      });
      Navigator.of(context, rootNavigator: true).pop();
    }
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
          onPressed: () {}, // Dismiss action
        ),
      ),
    );
  }

  //TODO - Share PDF Code
  Future<void> _generateStyledPdf() async {
    setState(() => isLoadingShare = true);
    final pdf = pw.Document();
    //final logoData = await rootBundle.load('assets/images/logo/logo-icon.png'); //Door Logo
    //final logoData = await rootBundle.load('assets/images/logo/logo.png'); // Full Logo
    //final logo = pw.MemoryImage(logoData.buffer.asUint8List());
    final svgLogoData = await rootBundle.loadString('assets/images/logo/logo.svg'); // SVG Logo
    const green = PdfColor.fromInt(0xFF48BB78);
    const blue = PdfColors.blue;
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final qrCode = Barcode.qrCode();
          final qrSvg = qrCode.toSvg('https://www.bbbank.so/', width: 100, height: 100);

          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Existing content ...
                //pw.Center(child: pw.Image(logo, height: 50)), // PNG Logo
                pw.SvgImage(svg: svgLogoData, height: 50), // SVG Logo
                // ✅ Add header line here
                pw.Divider(thickness: 1, color: PdfColors.grey),
                pw.SizedBox(height: 16),

                pw.SizedBox(height: 10),
                pw.Text('https://www.bbbank.so',
                    style: const pw.TextStyle(
                        fontSize: 12,
                        color: blue,
                        decoration: pw.TextDecoration.underline)
                ),
                pw.SizedBox(height: 24),
                pw.Text('Hi , ${shareTransactionDetails.shareCustomerName}',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('Total Amount Paid:',
                    style: const pw.TextStyle(fontSize: 14)),
                pw.Text('${shareTransactionDetails.shareTransactionAmount}',
                    style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: green)),
                pw.SizedBox(height: 24),
                _info('Phone Number:', '${shareTransactionDetails.shareCustomerPhoneNumber}'),
                _info('Date:', '${shareTransactionDetails.shareTransactionDate}'),
                pw.SizedBox(height: 10),
                _info('Paid To:', '${shareTransactionDetails.shareBeneficiaryName}'),
                pw.SizedBox(height: 10),
                _info('Transaction No:', '${shareTransactionDetails.shareTransactionReference}'),
                _info('Payment Type:', '${shareTransactionDetails.shareTransactionType}'),
                _info('Beneficiary Account:', '${shareTransactionDetails.shareBeneficiaryAccountNumber}'),

                pw.Spacer(), // Push the QR code to the bottom

                // ✅ Add footer line here
                pw.Divider(thickness: 1, color: PdfColors.grey),
                pw.SizedBox(height: 10),
                // ⬇️ QR code addition starts here
                pw.Center(
                  child: pw.Container(
                    width: 100,
                    height: 100,
                    child: pw.SvgImage(svg: qrSvg),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text('Scan to visit our website',
                      style: const pw.TextStyle(fontSize: 10)),
                ),
                // ⬆️ QR code addition ends here
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    // final file = File('${output.path}/payment_receipt.pdf');
    // await file.writeAsBytes(await pdf.save());
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/payment_receipt.pdf');

    setState(() => isLoadingShare = false);
    await Share.shareXFiles([XFile(file.path)], text: 'Here is your Transaction receipt.');
  }
  pw.Widget _info(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
                text: '$title ',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 13)),
            pw.TextSpan(
                text: value,
                style: const pw.TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _shareWidget(GlobalKey repaintKey) async {
    try {
      final context = repaintKey.currentContext;
      if (context == null) {
        debugPrint("RepaintBoundary not ready");
        return;
      }

      final renderObject = context.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        debugPrint("RenderRepaintBoundary not found");
        return;
      }

      final boundary = renderObject;

      // Wait for widget to be painted (max ~300ms)
      int retries = 0;
      while (boundary.debugNeedsPaint && retries < 10) {
        await Future.delayed(const Duration(milliseconds: 30));
        retries++;
      }

      if (boundary.debugNeedsPaint) {
        debugPrint("Still not painted, aborting share");
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        showSnackBar(context, "Unable to capture receipt image", Colors.red);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/receipt.png';
      final file = File(filePath);

      await file.writeAsBytes(pngBytes, flush: true);

      if (!await file.exists()) {
        showSnackBar(context, "Image not saved, try again", Colors.red);
        return;
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: "Here is your receipt for the transaction.",
      );
    } catch (e, s) {
      debugPrint("Error sharing receipt: $e");
      debugPrintStack(stackTrace: s);
      showSnackBar(context, "Error sharing receipt: $e ", Colors.red);
    }
  }

  // Future<void> _shareWidget(GlobalKey repaintKey) async {
  //   try {
  //     if (repaintKey.currentContext == null) {
  //       debugPrint("Widget not ready yet");
  //       return;
  //     }
  //     RenderRepaintBoundary boundary =
  //     repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //     if (boundary.debugNeedsPaint) {
  //       await Future.delayed(const Duration(milliseconds: 20));
  //       return _shareWidget(repaintKey);
  //     }
  //     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  //     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //     Uint8List pngBytes = byteData!.buffer.asUint8List();
  //     final directory = await getTemporaryDirectory();
  //     final filePath = '${directory.path}/receipt.png';
  //     await File(filePath).writeAsBytes(pngBytes);
  //     //File imgFile = File(filePath)..writeAsBytesSync(pngBytes);
  //     await SharePlus.instance.share(
  //       ShareParams(
  //         text: "Here is your receipt for the transaction.",
  //         files: [XFile(filePath)],
  //       ),
  //     );
  //   } catch (e) {
  //     showSnackBar(context, "Error Sharing Receipt : $e", Colors.red);
  //     debugPrint("Error sharing receipt: $e");
  //   }
  // }

  Future<Uint8List?> _fetchImageBytes() async {
    try {
      print("-------------------------- Fetching profile image (Base64 string)...");
      final cached = await _loadImageFromCache();
      if (cached != null) {
        print('✅ Using cached profile image picture');
        return cached;
      }
      final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
      final token = authProvider?.token;
      final httpClient = await createPinnedHttpClient();
      final ioClient = IOClient(httpClient);
      final response = await ioClient.get(
        Uri.parse(RemoteConfigService.baseUrl + AppConstants.endpointFetchProfileImage + authProvider!.phoneNumber),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/octet-stream',
          'apikey': RemoteConfigService.apiKey,
        },
      );
      print('-------------------------- Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type']; // e.g. 'image/png'
        final base64Str = utf8.decode(response.bodyBytes);
        final bytes = base64Decode(base64Str);
        print("Decoded Base64 length: ${base64Str.length}");
        print("Response Content-Type: $contentType");
        // Save to cache with correct extension
        await _saveImageToCache(bytes, contentType);
        return bytes;
      } else {
        print('Error fetching image: ${response.statusCode}');
        return null;
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      print('Error decoding image: $error');
      return null;
    }
  }

  Future<File> _saveImageToCache(Uint8List bytes, String? contentType) async {
    final dir = await getApplicationDocumentsDirectory();
    // Decide extension based on content-type
    String extension = 'jpg'; // Default fallback
    if (contentType != null) {
      if (contentType.contains('png')) {
        extension = 'png';
      } else if (contentType.contains('jpeg') || contentType.contains('jpg')) {
        extension = 'jpg';
      }
    }
    final file = File('${dir.path}/cached_profile_image.$extension');
    return await file.writeAsBytes(bytes);
  }

  Future<Uint8List?> _loadImageFromCache() async {
    final dir = await getApplicationDocumentsDirectory();
    // Check for both .jpg and .png (or any other formats you've added)
    final jpgFile = File('${dir.path}/cached_profile_image.jpg');
    final jpegFile = File('${dir.path}/cached_profile_image.jpeg');
    final pngFile = File('${dir.path}/cached_profile_image.png');
    if (await jpgFile.exists()) {
      return await jpgFile.readAsBytes();
    } else if (await jpegFile.exists()) {
      return await jpegFile.readAsBytes();
    } else if (await pngFile.exists()) {
      return await pngFile.readAsBytes();
    }
    return null; // Return null if neither file exists
  }

  void _onScroll() {
    final media = MediaQuery.of(context).size;
    double cardWidth = media.width - 40;
    //double cardWidth = 300.0; // Approximate width of each card including padding
    double offset = _accountScrollController.offset;
    int currentIndex = (offset / cardWidth).round();
    if (_activeAccountIndex != currentIndex && currentIndex >= 0 && currentIndex < getAccountCards(context).length) {
      setState(() {
        _activeAccountIndex = currentIndex;
        _currentIndexAccountNumber = getAccountCards(context)[_activeAccountIndex].accountNumber;
        //_refreshPage();
      });
      if (kDebugMode) {
        print("Active Account Number: ${getAccountCards(context)[_activeAccountIndex].accountNumber}");
      }
    }
  }

  Future<void> _refreshPage() async {
    if (kDebugMode) {
      print('********************** SCREEN REFRESH ***********************');
    }
    final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
    final balanceProvider = Provider.of<BalanceProvider>(context, listen: false);
    final miniRecentStatementsProvider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
    balanceProvider.fetchBalances(authProvider!.phoneNumber).then((_) {
      miniRecentStatementsProvider.fetchStatementsForAllAccounts(balanceProvider.accounts, authProvider.phoneNumber);
    });
  }

  String capitalizeFirst(String input) {
    return toBeginningOfSentenceCase(input.toLowerCase()) ?? input;
  }

  Widget _buildShimmerEffect() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  Container(
                    width: double.infinity,
                    height: 20,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  Container(
                    width: double.infinity,
                    height: 90,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }

  String parseDateTimeStringToDate(String? input) {
    if (input == null || input.isEmpty) {
      return input ?? '0000-00-00';
    }
    try {
      final parsed = DateTime.parse(input);
      final String date = "${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      return date;
    } catch (e) {
      return input;
    }
  }

  String parseDateTimeStringToTime(String? input) {
    if (input == null || input.isEmpty) {
      return input ?? '00:00';
    }
    try {
      final parsed = DateTime.parse(input);
      // Format date and time
      final String date = "${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      final String time = "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
      return time;
    } catch (e) {
      return "00:00";
    }
  }

  List<AccountCardModel> getAccountCards(BuildContext context) {
    final accountsBalanceProvider = Provider.of<BalanceProvider>(context, listen: false);
    List<AccountCardModel> accountCards = [];
    for (final account in accountsBalanceProvider.accounts) {
      // Look up the balance using account number
      final balance = accountsBalanceProvider.accountBalances[account.accountNumber];
      // If no balance is available yet (still loading or failed), use 0.00
      final displayBalance = balance != null
          ? '${balance.currency} ${NumberFormat("#,##0.00").format(balance.availableBalance)}'
          : '${account.currency} 0.00';
      accountCards.add(AccountCardModel(
        '${capitalizeFirst(account.accountType)} AC Balance',
        account.accountNumber,
        displayBalance,
        account.accountName,
        account.accountStatus,
      ));
    }
    return accountCards;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isSmallScreen = media.size.width < 600; // Typical breakpoint for phones
    final isMediumScreen = media.size.width >= 600 && media.size.width < 900;
    final isLargeScreen = media.size.width >= 900;
    final media2 = MediaQuery.of(context).size;
    double cardWidth = media2.width - 40;

    final authProvider = Provider.of<SessionProvider>(context).user;
    final balProvider = Provider.of<BalanceProvider>(context).isLoading;
    final accountsBalanceProvider = Provider.of<BalanceProvider>(context, listen: false);
    final notifications = Provider.of<NotificationServiceProvider>(context).alerts;

    return Scaffold(
      body: !balProvider && authProvider != null
          ? RefreshIndicator(
        onRefresh: _refreshPage,
        color: Colors.red.shade900, // Customize spinner color
        backgroundColor: Colors.white,
        displacement: 40, // Distance before showing spinner
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          children: <Widget>[
            // TODO --- HEADER SECTION -----
            // Top Section with Cards
            Container(
              color: Colors.purple.shade900,
              //TODO - bassam (1)
              height: isSmallScreen ? media.size.height * 0.46 : isMediumScreen ? media.size.height * 0.4 : media.size.height * 0.35,
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: <Widget>[
                            Material(
                              elevation: 4,
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/bg2.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.3,
                              child: Container(
                                color: Colors.black87,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: Container(
                            width: media.size.width,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  // TODO - Account Cards List
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(left: isSmallScreen ? 16 : 24, bottom: isSmallScreen ? 4 : 8,),
                      //TODO - bassam (2)
                      height: isSmallScreen ? media.size.height * 0.25 : media.size.height * 0.23,
                      width: media.size.width,
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior().copyWith(
                          overscroll: false,
                          physics: const BouncingScrollPhysics(),
                        ),
                        child: ListView.builder(
                          controller: _accountScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: accountsBalanceProvider.accounts.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
                              child: SizedBox(
                                //width: 280, // Must match the one in _onScroll
                                width: cardWidth,
                                child: GestureDetector(
                                  onTap: () {
                                    print('+++++++ TAPPED +++++++');
                                  },
                                  child: AccountCard(
                                    key: ValueKey('account_card_$index'),
                                    card: getAccountCards(context)[index],
                                    isActiveCard: index == _activeAccountIndex,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // TODO - App Bar
                  // App Bar Section
                  Positioned(
                    top: media.padding.top + (isSmallScreen ? 16 : 24),
                    left: 16,
                    right: 16,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left: Logo
                            Image.asset(
                              'assets/images/logo-white.png',
                              height: 44,
                              width: 150,
                            ),
                            // Right: Notification + Profile capsule
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      //TODO - Tap on Notifications Icon
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AlertsScreen()),
                                      );
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        const Icon(Icons.notifications_none, size: 24, color: Colors.black87),
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 14,
                                              minHeight: 14,
                                            ),
                                            child: Center(
                                              child: Text(
                                                notifications.length.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Handle profile pic Tap
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen(showBackButton: true,)),);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      radius: 18,
                                      child: FutureBuilder<Uint8List?>(
                                        future: _fetchImageBytes(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Icon(Icons.person, size: 24, color: Colors.grey);
                                          } else if (snapshot.hasError) {
                                            return Icon(Icons.error, size: 24, color: Colors.red.shade900);
                                          } else if (snapshot.hasData && snapshot.data != null) {
                                            return CircleAvatar(
                                              radius: 18,
                                              backgroundImage: MemoryImage(snapshot.data!),
                                            );
                                          } else {
                                            return const Icon(Icons.person, size: 24, color: Colors.grey);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${AppLocalizations.of(context)!.welcomeBack}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${authProvider.customerDetails.firstName} ${authProvider.customerDetails.lastName}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Optional: Remove if already in capsule above
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // TODO --- BOTTOM CONTENT SECTION BODY -----
            // Bottom Content Section
            Container(
              color: Colors.grey.shade300,
              width: media.size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Send Money Section
                  Padding(
                    padding: EdgeInsets.only(
                      left: isSmallScreen ? 20.0 : 24.0,
                      right: isSmallScreen ? 12.0 : 16.0,
                      bottom: isSmallScreen ? 2.0 : 10.0,
                      top: isSmallScreen ? 1.0 : 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Spacer(),
                        Icon(
                          Icons.compare_arrows_sharp,
                          color: Colors.grey,
                          size: isSmallScreen ? 16 : 20,
                        ),
                      ],
                    ),
                  ),

                  //TODO - CarouselSlider SLIDER
                  CarouselSlider(
                    options: CarouselOptions(
                      height: isSmallScreen ? 130 : 180, // Adjust height as needed
                      viewportFraction: 1.0, // Full-width slides
                      autoPlay: true,       // Auto-rotate ads
                      autoPlayInterval: Duration(seconds: 3),
                      enlargeCenterPage: false,
                      scrollPhysics: BouncingScrollPhysics(),
                    ), // Same as above
                    items: adImages.map((imagePath) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Transaction Filter Section
                  Padding(
                    padding: EdgeInsets.only(
                      left: isSmallScreen ? 20.0 : 24.0,
                      bottom: isSmallScreen ? 4.0 : 8.0,
                      right: isSmallScreen ? 12.0 : 16.0,
                      top: isSmallScreen ? 10.0 : 14.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)!.transactions,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const RecentTransactionsScreen()),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.viewMore,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.double_arrow,
                                color: Colors.black,
                                size: isSmallScreen ? 14 : 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // TODO - Transactions List
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16.0 : 24.0,
                    ),
                    child: Container(
                      height: isSmallScreen ? 250 : 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Consumer<MiniRecentStatementProvider>(
                        builder: (context, statementProvider, child) {
                          if (statementProvider.isFetching) {
                            return Center(child: CircularProgressIndicator(
                              color: Colors.red.shade900,
                            ));
                          }
                          final transactions = statementProvider.getTransactions(_currentIndexAccountNumber);
                          if (transactions.isEmpty) {
                            return Center(
                              child: Text(
                                AppLocalizations.of(context)!.noTransactionsAvailable,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }

                          return ScrollConfiguration(
                            behavior: ScrollBehavior().copyWith(overscroll: false),
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: false,
                              padding: EdgeInsets.only(
                                top: 8,
                                bottom: isSmallScreen ? 16 : 24,
                              ),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return GestureDetector(
                                  onTap: () async {
                                    _checkTransactionStatus(
                                      context: context,
                                      transaction: transaction,
                                      currentIndexAccountNumber: _currentIndexAccountNumber,
                                      recipientName: authProvider.customerDetails.firstName,
                                      recipientPhone: authProvider.phoneNumber,
                                    );
                                  },
                                  child: _buildTransactionItem(
                                    transaction.drcrTag == 'DR'
                                        ? ((transaction.creditorName.trim().isEmpty)
                                        ? transaction.transactionDesc
                                        : transaction.creditorName)
                                        : transaction.debtorsName,
                                    double.parse(transaction.amount),
                                    parseDateTimeStringToDate(transaction.authTimestamp),
                                    parseDateTimeStringToTime(transaction.authTimestamp),
                                    transaction.drcrTag,
                                    transaction.transactionCode,
                                    false,
                                    compactView: true,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ) : _buildShimmerEffect(),
    );
  }

  Future<void> _checkTransactionStatus({
    required BuildContext context,
    required RecentTransaction transaction,
    required String currentIndexAccountNumber,
    required String recipientName,
    required String recipientPhone,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child: CircularProgressIndicator(
            color: Colors.red.shade900,
          ),
        ),
      ),
    );
    //TODO - API CALL Transaction Status
    try{
      var responseData = await apiQueryTransactionStatus.fundsTransferStatus(
          transaction.transactionRef, transaction.transactionCode
      );
      if (responseData["data"]["response_code"] == "00") {
        //Set Values To Be used in PDF
        String debitAccount = responseData["data"]["drAccountNumber"];
        String creditAccount = responseData["data"]["crAccountNumber"];
        String currency = responseData["data"]["currency"];
        String transactionDate = responseData["data"]["transactionDate"];
        String beneficiaryName = responseData["data"]["creditorsName"];
        shareTransactionDetails.shareCustomerName = recipientName;
        shareTransactionDetails.shareCustomerAccountNumber = debitAccount;
        shareTransactionDetails.shareCustomerPhoneNumber = recipientPhone;
        shareTransactionDetails.shareBeneficiaryName = transaction.drcrTag == 'DR' ? beneficiaryName : recipientName;
        shareTransactionDetails.shareBeneficiaryAccountNumber = creditAccount;
        shareTransactionDetails.shareTransactionType = transaction.drcrTag == 'DR' ? "DEBIT" : "CREDIT";
        shareTransactionDetails.shareTransactionCurrency = currency;
        shareTransactionDetails.shareTransactionAmount = transaction.amount.toString();
        shareTransactionDetails.shareTransactionReference = transaction.transactionRef;
        shareTransactionDetails.shareTransactionDate = transactionDate;
        Navigator.of(context).pop();
        final GlobalKey dialogKey = GlobalKey();
        showDialog(
          context: context,
          builder: (context) => TransactionStatusCheckDialog(
            repaintKey: dialogKey,
            data: TransactionStatusCheckData(
              title: AppLocalizations.of(context)!.transactionDetails,
              dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.parse(transaction.authTimestamp)),
              reference: (transaction.creditorName.trim().isEmpty) ? transaction.debitRef : transaction.transactionRef,
              source: debitAccount,
              destination: creditAccount,
              sourceName: transaction.debtorsName,
              recipient: shareTransactionDetails.shareBeneficiaryName!,
              amount: transaction.amount.toString(),
              transactionCode: transaction.transactionCode,
              narration: transaction.transactionDesc,
            ),
            onConfirmed: onConfirmed,
            onShare: () {

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _shareWidget(dialogKey);
              });
            },
            isLoading: false,
          ),
        );
      }else{
        Navigator.of(context).pop();
        final GlobalKey dialogKey = GlobalKey();
        showDialog(
          context: context,
          builder: (context) => TransactionStatusCheckDialog(
            repaintKey: dialogKey,
            data: TransactionStatusCheckData(
              title: AppLocalizations.of(context)!.transactionDetails,
              dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.parse(transaction.authTimestamp)),
              reference: (transaction.transactionRef.trim().isEmpty) ? transaction.debitRef : transaction.transactionRef,
              source: transaction.debtorsAccount,
              destination: (transaction.creditorsAccount.trim().isEmpty) ? transaction.transactionCode : transaction.creditorsAccount,
              sourceName: transaction.debtorsName,
              recipient: (transaction.creditorName.trim().isEmpty) ? transaction.transactionDesc : transaction.creditorName,
              amount: transaction.amount.toString(),
              transactionCode: transaction.transactionCode,
              narration: transaction.transactionDesc,
            ),
            onConfirmed: onConfirmed,
            onShare: () async {
              // await _generateStyledPdf();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _shareWidget(dialogKey);
              });
            },
            isLoading: false,
          ),
        );
      }
    } catch (error, stack) {
      LoggerService.reportUnexpectedError(error, stack);
      Navigator.of(context).pop();
      showSnackBar(context, error.toString(), Colors.red);
    }
  }
}


Widget _buildTransactionItem(
    String narration,
    double amount,
    String date,
    String time,
    String transactionType,
    String transactionCode,
    bool isDarkMode,
    {bool compactView = true}
    ) {
  final isCredit = transactionType == 'CR';
  //final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
  final icon = isCredit ? Icons.south_west : Icons.north_east;
  final iconColor = isCredit ? Colors.white : Colors.white;
  final bgColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
  return Padding(
    padding: EdgeInsets.symmetric(vertical: compactView ? 2.0 : 8.0),
    child: Container(
      padding: EdgeInsets.all(compactView ? 12.0 : 10.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(compactView ? 8.0 : 12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Leading Icon
          Container(
            width: compactView ? 35 : 40,
            height: compactView ? 35 : 40,
            decoration: BoxDecoration(
              color: isCredit ? Colors.green.shade700 : Colors.red.shade900,
              borderRadius: BorderRadius.circular(compactView ? 22.0 : 22.0),
            ),
            child: Icon(icon, color: iconColor, size: compactView ? 16 : 20),
          ),
          SizedBox(width: compactView ? 8.0 : 12.0),
          // Narration and Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  narration,
                  style: TextStyle(
                    fontSize: compactView ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                if (!compactView) const SizedBox(height: 4.0),
                Text(
                  "$transactionCode - $date",
                  style: TextStyle(
                    fontSize: compactView ? 10 : 12,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isCredit ? "+${NumberFormat("#,##0.00").format(amount)} USD" : "-${NumberFormat("#,##0.00").format(amount)} USD",
                style: TextStyle(
                  fontSize: compactView ? 12 : 13,
                  fontWeight: FontWeight.w800,
                  color: isCredit ? Colors.green : Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                time,
                style: TextStyle(
                  fontSize: compactView ? 11 : 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class ShareTransactionDetails {
  String? shareCustomerName;
  String? shareCustomerAccountNumber;
  String? shareCustomerPhoneNumber;
  String? shareBeneficiaryName;
  String? shareBeneficiaryAccountNumber;
  String? shareTransactionType;
  String? shareTransactionCurrency;
  String? shareTransactionAmount;
  String? shareTransactionReference;
  String? shareTransactionDate;
  ShareTransactionDetails();
}