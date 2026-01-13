import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bushra_mobile/bill-payment/page-home-bill-payment-electricity.dart';
import 'package:bushra_mobile/bill-payment/page-home-bill-payment-government.dart';
import 'package:bushra_mobile/bill-payment/page-home-bill-payment-internet.dart';
import 'package:bushra_mobile/bill-payment/page-home-bill-payment-tv.dart';
import 'package:bushra_mobile/bill-payment/page-home-bill-payment-water.dart';
import 'package:bushra_mobile/utils/api-billers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/dto/favourites-get-request.dart';
import '../models/dto/favourites-get-response.dart';
import '../utils/api-customer-favourites.dart';
import '../utils/providers/provider-favourites.dart';
import '../utils/reference-generator.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-get-imei.dart';
import 'api/dto-get-biller-history.dart';

class PayBillMainScreen extends StatefulWidget {
  const PayBillMainScreen({super.key});

  @override
  State<PayBillMainScreen> createState() => _PayBillMainScreenState();
}

class _PayBillMainScreenState extends State<PayBillMainScreen> {
  int selectedIndex = 0; // Tracks the selected TAB
  bool compactView = true;


  //TODO PAYMENT HISTORY
  final Map<String, List<Map<String, String>>> transactionsByDate = {};

  //TODO FAVOURITES
  final referenceGenerator = ReferenceGenerator();
  late ApiCustomerFavourites apiCustomerFavourites;
  late ApiBillers apiBillers;
  bool isLoading = true;
  GetFavoritesResponse? getFavoritesResponse;

  @override
  void initState() {
    super.initState();
    apiCustomerFavourites = ApiCustomerFavourites();
    apiBillers = ApiBillers();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      if (sessionProvider.userLoginId.isNotEmpty) {
        fetchFavorites(sessionProvider.userLoginId);
        fetchHistory(sessionProvider.userLoginId);
      } else {
        if (kDebugMode) {
          print("userLoginId is empty. Delaying API call...");
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
          // ⭐️ NEW LINE: Persist into provider
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

  Future<void> fetchHistory(String userId) async{
    BillPaymentTransactionResponse ? billPaymentTransactionResponse = await fetchTransactions(userId);
    if (mounted) {
      setState(() {
        if (billPaymentTransactionResponse != null) {
          transactionsByDate.clear();
          for (var transaction in billPaymentTransactionResponse.transactions!) {
            String date = transaction.createdAt.split("T")[0];
            if (!transactionsByDate.containsKey(date)) {
              transactionsByDate[date] = [];
            }
            transactionsByDate[date]!.add({
              "title": transaction.transactionType,
              "description": '${transaction.billNumber} - A/C ${transaction.creditAccount}',
              "amount": "- ${transaction.amount} ${transaction.currency}",
              "time": transaction.createdAt.split("T")[1].split(".")[0],
            });
          }
        }
      });
    }
  }

  Future<BillPaymentTransactionResponse?> fetchTransactions(String userId) async {
    try {
      String deviceId = await DeviceIdentifier.getDeviceIdentifier();
      var response = await apiBillers.fetchBillHistory(userId, userId, deviceId, 10);
      if (response == null) {
        return null;
      }
      if (response["data"]["response_code"] == "00") {
        return BillPaymentTransactionResponse.fromJson(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    final favouritesProvider = Provider.of<FavouritesProvider>(context, listen: false);
    final billPayments = favouritesProvider.favorites?.data.favourites.billpayment ?? [];

    final List<Map<String, dynamic>> paymentOptions = [
      {
        "icon": Icons.bolt,
        "title": AppLocalizations.of(context)!.payElectricity,
      },
      {
        "icon": Icons.tv,
        "title": AppLocalizations.of(context)!.payTv,
      },
      {
        "icon": Icons.water_drop,
        "title": AppLocalizations.of(context)!.payWater,
      },
      {
        "icon": Icons.account_balance,
        "title": AppLocalizations.of(context)!.governmentPayment,
      },
      {
        "icon": Icons.wifi,
        "title": AppLocalizations.of(context)!.payInternet,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.paybill,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Scrollable Tabs
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab(AppLocalizations.of(context)!.favourites, 0, Icons.star_outline_rounded),
                _buildTab('New biller', 1, Icons.receipt),
                _buildTab(AppLocalizations.of(context)!.history, 2, Icons.history),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              selectedIndex == 0
                  ? AppLocalizations.of(context)!.favourites
                  : selectedIndex == 1
                  ? 'Add New Biller'
                  : AppLocalizations.of(context)!.history,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          //const SizedBox(height: 4),
          Expanded(
            child: selectedIndex == 1
            //TODO - INDEX-1 --------------NEW---------------
              ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: paymentOptions.length,
                itemBuilder: (context, index) {
                  return _buildPaymentOptionCard(
                    icon: paymentOptions[index]['icon'],
                    title: paymentOptions[index]['title'],
                    index: index,
                    onTap: () {
                      if(index == 0){
                        //TODO - Electricity
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const PayBillElectricityScreen()));
                      }else if(index == 1){
                        //TODO - TV
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const PayBillTvBillScreen()));
                      }
                      else if(index == 2){
                        //TODO - Water
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const PayBillWaterBillScreen()));
                      }
                      else if(index == 3){
                        //TODO - Government
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const PayBillGovtBillScreen()));
                      }else if(index == 4){
                        //TODO - Internet
                        Navigator.push(context,
                            MaterialPageRoute(builder: (
                                context) => const PayBillInternetBillScreen()));
                      }
                    },
                  );
                },
              ),
            )
            //TODO - INDEX-2 --------------HIS---------------
            : selectedIndex == 2
              ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              //padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.today,
                        style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 4.0),
                          DropdownButton<String>(
                            dropdownColor: Colors.white,
                            value: "Date",
                            underline: const SizedBox(),
                            items: ["Date", "Amount", "Name"]
                                .map((e) => DropdownMenuItem(value: e, child: Text(e,style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),)))
                                .toList(),
                            onChanged: (value) {
                              //TODO sort logic
                            },
                            icon: const Icon(Icons.arrow_drop_down),
                          ),
                          IconButton(
                            icon: Icon(compactView ? Icons.view_agenda : Icons.view_compact),
                            onPressed: () {
                              setState(() {
                                compactView = !compactView;
                              });
                            },
                          )
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),
                  // Transaction List
                  Expanded(
                    child: ListView(
                      children: transactionsByDate.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.key != "Today") // Group header for non-Today sections
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ...entry.value.map((transaction) {
                              return _buildTransactionCard(
                                title: transaction['title']!,
                                description: transaction['description']!,
                                amount: transaction['amount']!,
                                time: transaction['time']!,
                                compactView: compactView,
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            )
            //TODO - INDEX-0 --------------FAV---------------
            :
            SingleChildScrollView(
              child: billPayments.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Text(
                    AppLocalizations.of(context)!.noFavouritesFound,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
                  : Column(
                children: billPayments.map((item) {
                  IconData billIcon = Icons.receipt;
                  if(item.type =='TV'){
                    billIcon = Icons.tv;
                  }else if(item.type == 'ELECTRICITY') {
                    billIcon = Icons.bolt;
                  } else if(item.type == 'WATER') {
                    billIcon = Icons.water_drop;
                  }else if(item.type == 'GOVERNMENT') {
                    billIcon = Icons.account_balance;
                  }else if(item.type == 'INTERNET') {
                    billIcon =Icons.wifi;
                  }

                  return _buildBillCard(
                    favouriteId: item.id,
                    logo: billIcon,
                    billerName: item.name,
                    accountDetails: item.recipient,
                    amount: 'USD ${item.amount}',
                    dueDate: item.type, // <-- depends if you have dueDate in item, otherwise ''
                    status: 'Active', // just an example, or map from item
                    statusColor: Colors.green,
                    buttonLabel: 'PAY',
                    buttonColor: Colors.red.shade900,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // TODO - FAVOURITE
  Widget _buildBillCard({
    required IconData logo,
    required String favouriteId,
    required String billerName,
    required String accountDetails,
    required String amount,
    required String dueDate,
    required String status,
    required Color statusColor,
    required String buttonLabel,
    required Color buttonColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(logo, size: 24, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    billerName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    accountDetails,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dueDate,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: TextStyle(fontSize: 10, color: statusColor),
                ),
                IconButton(
                    onPressed: () async {
                      //TODO - DELETE FAVOURITE
                      await deleteFavourite('billpayment', favouriteId);
                      fetchFavorites(Provider.of<SessionProvider>(context, listen: false).userLoginId);
                    },
                    icon: Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red.shade900,
                    )
                ),
                ElevatedButton(
                  onPressed: () {
                    //TODO
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // TODO - NEW-BILL
  Widget _buildPaymentOptionCard({required IconData icon, required String title, required int index, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8.0,
                spreadRadius: 2.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Icon(icon, color: Colors.red, size: 16,),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16.0,
                  color: Colors.grey,
                ),
                onPressed: () {
                  if(index == 0){
                    //TODO - Electricity
                    Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => const PayBillElectricityScreen()));
                  }else if(index == 1){
                    //TODO - TV
                    Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => const PayBillElectricityScreen()));
                  }
                  else if(index == 2){
                    //TODO - Water
                    Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => const PayBillElectricityScreen()));
                  }
                  else if(index == 3){
                    //TODO - Government
                    Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => const PayBillElectricityScreen()));
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

  Widget _buildTransactionCard({
    required String title,
    required String description,
    required String amount,
    required String time,
    bool compactView = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compactView ? 4.0 : 8.0),
      child: Container(
        padding: EdgeInsets.all(compactView ? 8.0 : 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
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
              width: compactView ? 30 : 40,
              height: compactView ? 30 : 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(compactView ? 15.0 : 20.0),
              ),
              child: Icon(
                Icons.arrow_downward,
                color: Colors.red,
                size: compactView ? 16.0 : 20.0,
              ),
            ),
            SizedBox(width: compactView ? 8.0 : 12.0),
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: compactView ? 12 : 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (!compactView) const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: compactView ? 12 : 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Amount and Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: compactView ? 14 : 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  time,
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
    );
  }

  // Function to build tabs
  Widget _buildTab(String label, int index, IconData icon,) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index; // Change selected tab
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

}