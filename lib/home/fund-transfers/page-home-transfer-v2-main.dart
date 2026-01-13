import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:bushra_mobile/home/fund-transfers/page-home-transfer-v2-under-momo.dart';
import 'package:bushra_mobile/home/fund-transfers/page-home-transfer-v2-under-others.dart';
import 'package:bushra_mobile/home/fund-transfers/page-home-transfer-v2-under-own.dart';
import 'package:bushra_mobile/home/fund-transfers/page-home-transfer-v2-under-remittance.dart';
import 'package:bushra_mobile/home/fund-transfers/page-home-transfer-v2-under-sps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../l10n/app_localizations.dart';
import '../../models/dto/favourites-get-request.dart';
import '../../models/dto/favourites-get-response.dart';
import '../../utils/api-customer-favourites.dart';
import '../../utils/dto/dto-favourites-click.dart';
import '../../utils/providers/provider-favourites.dart';
import '../../utils/providers/provider-mini-recent.dart';
import '../../utils/providers/provider-transfer-favourite-data.dart';
import '../../utils/reference-generator.dart';
import '../../utils/providers/provider-session.dart';
import '../../utils/util-get-imei.dart';
import '../../widgets/dialog-coming-soon.dart';
import '../../widgets/dialog-transaction-status-check.dart';

class FundsTransferMainScreen extends StatefulWidget {
  const FundsTransferMainScreen({super.key});
  @override
  State<FundsTransferMainScreen> createState() => _FundsTransferMainScreenState();
}

class _FundsTransferMainScreenState extends State<FundsTransferMainScreen> {
  int selectedIndexMainTab = 0; // Tracks the selected tab MAIN TABS
  int selectedIndexBeneficiaryTab = 0; // Tracks the selected tab BENEFICIARY TABS
  final String _selectedSortOption = 'Date';
  int? _selectedFrequentIndex;

  //TODO - FETCH FAVOURITES API ------------------------------------------------
  final referenceGenerator = ReferenceGenerator();
  late ApiCustomerFavourites apiCustomerFavourites;
  bool isLoading = true;
  GetFavoritesResponse? getFavoritesResponse;

  List<RecentTransaction> filteredTransactions = [];
  String selectedFilter = "ALL"; // ALL, CR, DR
  String searchQuery = "";
  bool hideBalance = false;
  late MiniRecentStatementProvider _miniRecentProvider;

  @override
  void initState() {
    super.initState();
    apiCustomerFavourites = ApiCustomerFavourites();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      if (sessionProvider.userLoginId.isNotEmpty) {
        await fetchFavorites(sessionProvider.userLoginId);
        // get provider reference (no listening here)
        _miniRecentProvider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
        // listen for changes so we re-apply filters when provider updates
        _miniRecentProvider.addListener(_onMiniRecentChanged);
        // initial filter pass (in case provider already has data)
        _applyFilters();
      }
    });
  }

  @override
  void dispose() {
    _miniRecentProvider.removeListener(_onMiniRecentChanged);
    super.dispose();
  }

  void onConfirmed(){
    Navigator.pop(context);
  }
  void _onMiniRecentChanged() {
    if (!mounted) return;
    _applyFilters();
  }
  void _applyFilters() {
    final provider = Provider.of<MiniRecentStatementProvider>(context, listen: false);
    final allTransactions = provider.allTransactions ?? <RecentTransaction>[];
    final q = searchQuery.trim().toLowerCase();
    setState(() {
      filteredTransactions = allTransactions.where((txn) {
        final matchesFilter = selectedFilter == "ALL" || txn.drcrTag == selectedFilter;
        final matchesSearch = q.isEmpty
            ? true
            : ( (txn.debtorsName?.toLowerCase().contains(q) ?? false)
            || (txn.creditorName?.toLowerCase().contains(q) ?? false)
            || (txn.debtorsAccount?.contains(q) ?? false)
            || (txn.transactionDate?.toLowerCase().contains(q) ?? false)
        );
        return matchesFilter && matchesSearch;
      }).toList();
    });
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

  Future<void> deleteFavourite(String favType, String favId) async {
    String phone;
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    if (sessionProvider.userLoginId.isNotEmpty) {
      phone = sessionProvider.userLoginId;
    } else {
      return;
    }
    String imei = await DeviceIdentifier.getDeviceIdentifier();
    var responseData = await apiCustomerFavourites.deleteCustomerFavourites(imei, phone, favType, favId);
    if (mounted) {
      setState(() {
        if (responseData["data"]["response_code"] == "00") {
          if (kDebugMode) {
            print('SUCCESS : DELETED favourites');
            print('SUCCESS {$responseData}');
          }
        }else{
          if (kDebugMode) {
            print('ERROR : Could not DELETE favourites');
            print('RESPONSE {$responseData}');
          }
        }
        isLoading = false;
      });
    }

  }
  Future<void> fetchFavorites(String phone) async {
    String deviceId = await DeviceIdentifier.getDeviceIdentifier();
    final request = GetFavoritesRequest(
      txntimestamp: DateTime.now().toUtc().toIso8601String(),
      xref: referenceGenerator.generateUniqueReference(false),
      transactionDetails: TransactionDetails(
        direction: "0200",
        transactionType: "GETFAVORITES",
        transactionCode: "GETFAVORITES",
        hostCode: "MOBILE",
        debitAccount: phone,
        phoneNumber: phone,
      ),
      channelDetails: ChannelDetails(
        host: "IP",
        geolocation: "1.2921, 36.8219",
        userAgent: Platform.isAndroid ? "Android" : (Platform.isIOS ? "iOS" : "Unknown"),
        userAgentVersion: "1.0.0",
        channel: "MOBILE",
        clientId: "client123",
        deviceId: deviceId,
      ),
    );
    var responseData = await apiCustomerFavourites.getCustomerFavourites(request);
    if (mounted) {
      setState(() {
        if (responseData["data"]["response_code"] == "00") {
          getFavoritesResponse = GetFavoritesResponse.fromJson(responseData);
          Provider.of<FavouritesProvider>(context, listen: false).setFavorites(getFavoritesResponse!);
        }else{
          if (kDebugMode) {
            print('ERROR : Could not get favourites');
            print('RESPONSE {$responseData}');
          }
        }
        isLoading = false;
      });
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
  String getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return names[0][0] + names[1][0];
    } else if (names.isNotEmpty) {
      return names[0][0];
    }
    return '';
  }
  String formatAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return '${accountNumber.substring(0, 4)}******${accountNumber.substring(accountNumber.length - 2)}';
  }

  //TODO - NEW TRANSFER


  //TODO FAVOURITES
  final bool _isAvatarVisible = true;

  /// Shimmer Loading Effect
  Widget _buildShimmerEffect(BuildContext context) {
    return Scaffold( // <-- Important, add this
      backgroundColor: Colors.white,
      body: SafeArea(
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
                      color: Theme.of(context).colorScheme.surface,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Theme.of(context).colorScheme.surface,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    Container(
                      width: double.infinity,
                      height: 90,
                      color: Theme.of(context).colorScheme.surface,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> paymentOptions = [
      {
        "icon": Icons.loop,
        "title": AppLocalizations.of(context)!.ownTransfer,
      },
      {
        "icon": Icons.devices_other,
        "title": AppLocalizations.of(context)!.otherTransfer,
      },
      {
        "icon": Icons.phone_android_outlined,
        "title": AppLocalizations.of(context)!.mobileMoney,
      },
      {
        "icon": Icons.phone_android_outlined,
        "title": AppLocalizations.of(context)!.spsTransfer,
      },
      {
        "icon": Icons.send,
        "title": AppLocalizations.of(context)!.remittance,
      },
    ];

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    if (getFavoritesResponse == null || isLoading) {
      return Center(
        child: _buildShimmerEffect(context),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text(
          AppLocalizations.of(context)!.fundTransfer,
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Scrollable MAIN Tabs
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab(AppLocalizations.of(context)!.favourites, 0, Icons.star_outline_rounded),
                _buildTab(AppLocalizations.of(context)!.newTransfer, 1, Icons.compare_arrows_sharp),
                _buildTab(AppLocalizations.of(context)!.history, 2, Icons.history),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              selectedIndexMainTab == 0
                  ? AppLocalizations.of(context)!.whichPeopleWouldYouLikeToTransferFundsTo
                  : selectedIndexMainTab == 1
                  ? ''  // New Transfer
                  : '', //Recent Transactions
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: selectedIndexMainTab == 1
            //TODO - INDEX-1 -------NEW TRANSFER---------------------
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: paymentOptions.length,
                itemBuilder: (context, index) {
                  return _buildTransferOptionCard(
                    icon: paymentOptions[index]['icon'],
                    title: paymentOptions[index]['title'],
                    isDarkMode: isDarkMode,
                    index: index,
                    onTap: () {
                      if(index == 0){
                        //TODO - OWN
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const FundsTransferOwnScreen()));
                      }else if(index == 1){
                        //TODO - OTHER
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const FundsTransferOtherScreen()));
                      }else if(index == 2){
                        //TODO - MOMO
                        showDialog(
                          context: context,
                          builder: (context) => const ComingSoonDialog(),
                        );
                      }else if(index == 3){
                        //TODO - SPS
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const FundsTransferSpsScreen()));
                      }else if(index == 4){
                        //TODO - REMITTANCE
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const FundsTransferRemittanceScreen()));
                      }
                    }
                  );
                },
              ),
            )
            //TODO - INDEX-2 ------HISTORY----------------------
                : selectedIndexMainTab == 2
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _buildRecentMiniStatementsTab(isDarkMode), //TODO HISTORY
                  )
            //TODO - INDEX-0 -------FAVOURITE----------------------
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //TODO - favourite Sending to
                  const Padding(
                    padding: EdgeInsets.all(16.0),  // Padding of 16
                    child: Text('Sending to', style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
                  ),
              _isAvatarVisible
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: getFavoritesResponse!.data.favourites.ift.map((iftItem) {
                      String initials = getInitials(iftItem.name == "" ? "Unknown" : iftItem.name);
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            print('Tapped on Sending to ::: ${iftItem.name}');
                            Favorite fav = Favorite(
                              name: iftItem.name,
                              recipient: iftItem.recipient,
                              type: iftItem.type,
                              amount: iftItem.amount,
                              bankcode: iftItem.bankcode,
                            );
                            context.read<FavoriteTransferDataProvider>().setFavorite(fav);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FundsTransferOtherScreen()),);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.red.shade50,
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          getFavoritesResponse?.data.favourites.ift
                                              .removeWhere((item) => item.id == iftItem.id);
                                          deleteFavourite("ift", iftItem.id);
                                        });
                                      },
                                      child: CircleAvatar(
                                        radius: 8,
                                        backgroundColor: Colors.red.shade900,
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                iftItem.name == "" ? "Unknown" : iftItem.name,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )

                  : Container(),
                  //TODO - favourite Beneficiaries
                   Padding(
                    padding: EdgeInsets.all(16.0),  // Padding of 16
                    child: Text(
                        AppLocalizations.of(context)!.beneficiaries,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.normal
                        )
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: getFavoritesResponse!.data.favourites.ift.asMap().entries.map((entry) {
                        final index = entry.key;
                        final iftItem = entry.value;
                        final initials = getInitials(iftItem.name =="" ? "Unknown" : iftItem.name);
                        return _buildTabBeneficiary(iftItem.name =="" ? "Unknown" : iftItem.name, index, initials, isDarkMode,);
                      }).toList(),
                    ),
                  ),

                  //TODO - favourite Frequents
                   Padding(
                    padding: EdgeInsets.all(16.0),  // Padding of 16
                    child: Text(AppLocalizations.of(context)!.frequents,style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: getFavoritesResponse!.data.favourites.sps.isEmpty
                        ?  Center(
                          child: Text(
                            AppLocalizations.of(context)!.noBeneficiariesFound,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        )
                        : Column(
                      children: getFavoritesResponse!.data.favourites.sps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final spsItem = entry.value;
                        final initials = getInitials(spsItem.name);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Card(
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey[50],
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.red.shade50,
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    spsItem.name,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey.shade500 : Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'AC ${formatAccountNumber(spsItem.recipient)}',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey.shade500 : Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Radio(
                                activeColor: Colors.red.shade900,
                                value: index,
                                groupValue: _selectedFrequentIndex,
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedFrequentIndex = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  //TODO - - favourite Frequents BUTTON
                  Padding(
                    padding: const EdgeInsets.all(16.0), // Add padding for spacing
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          //TODO
                          print('CONTINUE BUTTON ==> Selected Frequent Index: $_selectedFrequentIndex');
                          if (_selectedFrequentIndex != null) {
                            // Get the selected item
                            final selectedItem = getFavoritesResponse!.data.favourites.sps[_selectedFrequentIndex!];
                            // Do something with the selected item
                            print('Selected Item: ${selectedItem.name}');
                            // Set the Favorite before navigation
                            Favorite fav = Favorite(
                              name: selectedItem.name,
                              recipient: selectedItem.recipient,
                              type: selectedItem.type,
                              amount: selectedItem.amount,
                              bankcode: selectedItem.bankcode,
                            );
                            context.read<FavoriteTransferDataProvider>().setFavorite(fav);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FundsTransferSpsScreen()),);
                          } else {
                            // Show a message if no item is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a beneficiary radio button'), duration: Duration(seconds: 2),),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'CONTINUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build tabs
  Widget _buildTab(String label, int index, IconData icon,) {
    bool isSelected = selectedIndexMainTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndexMainTab = index; // Change selected tab
          if (kDebugMode) {
            print('---> SELECTED MAIN TAB {$label}');
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          height: 100,
          width: 155,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo.shade800 : Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.indigo.shade300,
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10), // Adds spacing between avatar and text
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO - FAVOURITE
  Widget _buildTabBeneficiary(String name, int index, String namePrefix, bool isDarkMode) {
    bool isSelected = selectedIndexBeneficiaryTab == index;
    return GestureDetector(
      onTap: () {
        //TODO - Handles IFT TO OTHERS
        setState(() {
          selectedIndexBeneficiaryTab = index; // Change selected tab
          print('Selected Beneficiary TAB {$name}');
          // Set the Favorite before navigation
          Favorite fav = Favorite(
            name: getFavoritesResponse!.data.favourites.ift[index].name,
            recipient: getFavoritesResponse!.data.favourites.ift[index].recipient,
            type: getFavoritesResponse!.data.favourites.ift[index].type,
            amount: getFavoritesResponse!.data.favourites.ift[index].amount,
            bankcode: getFavoritesResponse!.data.favourites.ift[index].bankcode,
          );
          context.read<FavoriteTransferDataProvider>().setFavorite(fav);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FundsTransferOtherScreen()),);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          height: 110,
          width: 155,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            //color: isSelected ? Colors.indigo.shade800 : Colors.grey[200],
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey[50],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red.shade50,
                child: Text(namePrefix,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10), // Adds spacing between avatar and text
              Text(
                name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO - NEW-TRANSFER
  Widget _buildTransferOptionCard({required IconData icon, required String title, required int index, required bool isDarkMode, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey[100],
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.0),
                blurRadius: 8.0,
                spreadRadius: 2.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Icon(icon, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16.0,
                  color: Colors.black,
                ),
                onPressed: () {
                  if(index == 0){
                    //TODO - OWN
                    Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => const FundsTransferOwnScreen()));
                  }else if(index == 1){
                    //TODO - OTHER
                    Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => const FundsTransferOtherScreen()));
                  }else if(index == 2){
                    //TODO - MOMO
                    Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => const FundsTransferMomoScreen()));
                  }else if(index == 3){
                    //TODO - SPS
                    Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => const FundsTransferSpsScreen()));
                  }else if(index == 4){
                    //TODO - TRANSFER STATUS
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (
                    //         context) => const FundsTransferRemittanceScreen()));
                    showDialog(
                      context: context,
                      builder: (context) => const ComingSoonDialog(),
                    );
                  }else if(index == 5){
                    //TODO - REMITTANCE
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (
                    //         context) => const FundsTransferRemittanceScreen()));
                    showDialog(
                      context: context,
                      builder: (context) => const ComingSoonDialog(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO - TRANSACTIONS HISTORY
  Widget _buildRecentMiniStatementsTab(bool isDarkMode) {
    final miniRecentStatementsProvider = Provider.of<MiniRecentStatementProvider>(context);
    // choose which list to display: filtered (if any filter/search is active) otherwise provider list
    final bool isFilteringActive = searchQuery.trim().isNotEmpty || selectedFilter != 'ALL';
    final List<RecentTransaction> displayTransactions =
    (isFilteringActive || filteredTransactions.isNotEmpty)
        ? filteredTransactions
        : (miniRecentStatementsProvider.allTransactions ?? <RecentTransaction>[]);
    // grouping function (same as yours but using displayTransactions)
    Map<String, List<RecentTransaction>> groupByDate(List<RecentTransaction> transactions) {
      final Map<String, List<RecentTransaction>> grouped = {};
      for (var tx in transactions) {
        final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(tx.transactionDate));
        grouped.putIfAbsent(dateKey, () => []).add(tx);
      }
      final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
      return Map.fromEntries(sortedKeys.map((key) => MapEntry(key, grouped[key]!)));
    }
    final groupedByDate = groupByDate(displayTransactions);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.recentTransactions,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    hideBalance ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      hideBalance = !hideBalance;
                    });
                  },
                ),
              ],
            ),
          ),
          // 🔵 Search + Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                ToggleButtons(
                  selectedBorderColor: Colors.indigo.shade900,
                  selectedColor: Colors.white,
                  fillColor: Colors.indigo.shade900,
                  borderRadius: BorderRadius.circular(8),
                  isSelected: [
                    selectedFilter == "ALL",
                    selectedFilter == "CR",
                    selectedFilter == "DR"
                  ],
                  onPressed: (index) {
                    setState(() {
                      selectedFilter = ["ALL", "CR", "DR"][index];
                      _applyFilters();
                    });
                  },
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("All")),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("In")),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Out")),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search by Account, Name, Date",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      searchQuery = val;
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          Divider(
            color: Colors.grey,     // line color
            thickness: 1,           // line thickness
            indent: 4,             // empty space to the leading edge
            endIndent: 4,          // empty space to the trailing edge
          ),
          // Transactions List
          Expanded(
            child: Stack(
              children: [
                miniRecentStatementsProvider.isFetching
                    ? const Center(child: CircularProgressIndicator())
                    : displayTransactions.isEmpty
                    ? Center(
                  child: Text(
                    "No transactions available",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: groupedByDate.keys.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedByDate.keys.elementAt(index);
                    final txs = groupedByDate[dateKey]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(DateTime.parse(dateKey)),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                          ),
                        ),
                        ...txs.map(
                              (tx) => _buildTransactionItem(
                            tx.drcrTag == 'DR'
                                ? ((tx.creditorName.trim().isEmpty) ? tx.transactionDesc : tx.creditorName)
                                : ((tx.debtorsName.trim().isEmpty) ? tx.transactionDesc : tx.debtorsName),
                            double.parse(tx.amount),
                            tx.authTimestamp,
                            tx.drcrTag,
                            tx.transactionCode,
                            isDarkMode,
                              onTap: () {
                                final GlobalKey dialogKey = GlobalKey();
                                showDialog(
                                  context: context,
                                  builder: (context) => TransactionStatusCheckDialog(
                                    repaintKey: dialogKey,
                                    data: TransactionStatusCheckData(
                                      title: "Transaction Details",
                                      dateTime: DateFormat("MMM d, yyyy | h:mm:ss a").format(DateTime.parse(tx.authTimestamp)),
                                      reference: (tx.transactionRef.trim().isEmpty) ? tx.debitRef : tx.transactionRef,
                                      source: tx.debtorsAccount,
                                      destination: (tx.creditorsAccount.trim().isEmpty) ? tx.transactionCode : tx.creditorsAccount,
                                      sourceName: tx.debtorsName,
                                      recipient: (tx.creditorName.trim().isEmpty) ? tx.transactionDesc : tx.creditorName,
                                      amount: tx.amount.toString(),
                                      transactionCode: tx.transactionCode,
                                      narration: tx.transactionDesc,
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
                              },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  },
                ),
                if (hideBalance)
                  Positioned.fill(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(color: Colors.black.withOpacity(0)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      String narration,
      double amount,
      String time,
      String transactionType,
      String transactionCode,
      bool isDarkMode,
      {bool compactView = true, required Null Function() onTap}
      ) {
    final isCredit = transactionType == 'CR';
    final icon = isCredit ? Icons.south_west : Icons.north_east;
    final iconColor = isCredit ? Colors.white : Colors.white;
    // ✅ CHANGED: Yellow background for transaction items
    // XX BASSAM HERE
    final bgColor = Colors.grey.shade200; // Changed from isDarkMode ? Colors.grey.shade800 : Colors.white
    final textColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade600;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compactView ? 4.0 : 8.0),
        child: Container(
          padding: EdgeInsets.all(compactView ? 8.0 : 12.0),
          decoration: BoxDecoration(
            color: bgColor, // This will now be yellow
            borderRadius: BorderRadius.circular(compactView ? 8.0 : 12.0),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.2),
            //     blurRadius: 6.0,
            //     spreadRadius: 1.0,
            //     offset: const Offset(0, 3),
            //   ),
            // ],
          ),
          child: Row(
            children: [
              Container(
                width: compactView ? 30 : 40,
                height: compactView ? 30 : 40,
                decoration: BoxDecoration(
                  color: isCredit ? Colors.green.shade700 : Colors.red.shade900,
                  borderRadius: BorderRadius.circular(compactView ? 15.0 : 20.0),
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
                        fontSize: compactView ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (!compactView) const SizedBox(height: 4.0),
                    Text(
                      "$transactionCode - ${parseDateTimeStringToDate(time)}",
                      style: TextStyle(
                        fontSize: compactView ? 10 : 12,
                        color: isDarkMode ? Colors.grey.shade500 : Colors.black54,
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
                      fontSize: compactView ? 13 : 14,
                      fontWeight: FontWeight.w800,
                      color: isCredit ? Colors.green : Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    parseDateTimeStringToTime(time),
                    style: TextStyle(
                      fontSize: compactView ? 10 : 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}