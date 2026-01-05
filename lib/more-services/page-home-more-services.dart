import 'package:bushra_mobile/more-services/page-home-more-services-myaccounts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../sps/sps-merchant-screen.dart';
import '../standing-order/page-home-sto.dart';
import '../term-deposits/page-home-term-deposit.dart';
import '../utils/api-callback.dart';
import '../utils/providers/provider-session.dart';
import '../virtual-cards/page-home-virtual-cards.dart';
import '../widgets/dialog-coming-soon.dart';
import '../widgets/dialog-error.dart';
import '../widgets/dialog-success.dart';
import '../widgets/progress-dialog.dart';

class MoreServicesScreen extends StatefulWidget {
  const MoreServicesScreen({super.key});

  @override
  State<MoreServicesScreen> createState() => _MoreServicesScreenState();
}

class _MoreServicesScreenState extends State<MoreServicesScreen> {

  final List<Map<String, dynamic>> servicesOptions = [
    {
      "icon": Icons.account_balance_wallet,
      "title": "Accounts",
    },
    {
      "icon": Icons.call,
      "title": "Request for callback",
    },
    {
      "icon": Icons.arrow_forward_sharp,
      "title": "Term Deposit",
    },
    {
      "icon": Icons.schedule_send,
      "title": "Standing order",
    },
    {
      "icon": Icons.credit_card_sharp,
      "title": "Manage cards",
    },
    // {
    //   "icon": Icons.account_balance,
    //   "title": "SPS",
    // },
  ];
  bool isLoading = false;
  final apiCallback = ApiCallback();
  final TextEditingController _dateStartController = TextEditingController();

  @override
  void dispose() {
    _dateStartController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red.shade900, // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Dialog background color
              onSurface: Colors.black, // Text color
            ),
            dialogBackgroundColor: Colors.white, // Alternative way to set background color
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _dateStartController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
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

  void showSuccessDialog(BuildContext context, String messageParent, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessAlertDialog(message: message, onOkay: onOkay, messageParent: messageParent,),
    );
  }

  void onRetry(){
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void onOkay(){
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> postCallbackRequest(String phone, String email, String date) async {
    try {
      showCrossingBallsProgressDialog(context, 'Your callback request is being submitted \n Please Wait...');
      var responseData = await apiCallback.postCallBack(phone, email, date,);
      if (responseData["data"]["response_code"] == "00") {
        setState(() {
          isLoading = false;
          showSuccessDialog(context, 'Callback request', 'Your callback request was successful', onOkay);
        });
      }else{
        setState(() {
          isLoading = false;
          showErrorDialog(context, 'Oops! Your callback request was not successful', responseData["data"]["response"], onRetry);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        showErrorDialog(context, 'Oops! Your callback request was not successful', error.toString(), onRetry);
      });
      throw Exception('FAILED TO POST CALLBACK : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(AppLocalizations.of(context)!.moreServices),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: servicesOptions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _handleTap(context, index),
                        child: _buildMoreServicesCard(
                          icon: servicesOptions[index]['icon'],
                          title: servicesOptions[index]['title'],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //TODO - MORE SERVICES CARD
  Widget _buildMoreServicesCard({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
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
            const Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  //TODO - TAPS
  void _handleTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAccountsScreen()));
        break;
      case 1:
        _showCallbackBottomSheet(context);
        break;
      case 2:
        // showDialog(
        //   context: context,
        //   builder: (context) => const ComingSoonDialog(),
        // );
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TermDepositScreen()));
        break;
      case 3:
        // showDialog(
        //   context: context,
        //   builder: (context) => const ComingSoonDialog(),
        // );
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StandingOrderScreen()));
        break;
      case 4:
        showDialog(
          context: context,
          builder: (context) => const ComingSoonDialog(),
        );
        //Navigator.push(context, MaterialPageRoute(builder: (_) => const VirtualCardScreen()));
        //break;
      default:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const QRPaymentMerchantScreen()));
    }
  }
  //TODO - CALLBACK
  void _showCallbackBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final authProvider = Provider.of<SessionProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: isLandscape ? 0.8 : 0.6, // taller in landscape
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 24.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    AppLocalizations.of(context)!.callbackRequest,
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                   Text(
                    AppLocalizations.of(context)!.confirmTheDateForCallback,
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _dateStartController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Eg 01-01-2025',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:  Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Confirm logic
                            final callbackDateTime = _dateStartController.text;
                            final user = authProvider.user;
                            final phoneNumber = user?.phoneNumber;
                            final email = user?.customerDetails.emailAddress;
                            if (phoneNumber == null || email == null || callbackDateTime.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text(AppLocalizations.of(context)!.userInformationIsNotAvailable)),
                              );
                              return;
                            }
                            // Parse the input date format
                            String inputDate = _dateStartController.text;
                            String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.parse(inputDate).add(const Duration(hours: 12, minutes: 00)));
                            postCallbackRequest(phoneNumber, email, formattedDate);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:  Text(
                            AppLocalizations.of(context)!.confirm,
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}