import 'package:bushra_mobile/term-deposits/page-home-term-deposit-create.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/api-customer-term-deposits.dart';
import '../utils/reference-generator.dart';
import '../utils/providers/provider-session.dart';
import '../utils/util-get-imei.dart';
import 'dto/term-deposits-response.dart';

class TermDepositScreen extends StatefulWidget {
  const TermDepositScreen({super.key});
  @override
  State<TermDepositScreen> createState() => _TermDepositScreenState();
}

class _TermDepositScreenState extends State<TermDepositScreen> {
  bool _isLoading = true;
  final referenceGenerator = ReferenceGenerator();
  final apiCustomerTermDeposits = ApiCustomerTermDeposits();
  List<TermDeposits> tdAccountsList = [];
  String _deviceId = "Fetching...";

  @override
  void initState(){
    super.initState();
    _fetchDeviceId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchTermDeposits();
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
          onPressed: () {}, // Dismiss action
        ),
      ),
    );
  }
  Future<void> _fetchDeviceId() async {
    String deviceId = await DeviceIdentifier.getDeviceIdentifier();
    setState(() {
      _deviceId = deviceId;
    });
  }
  Future<void> _fetchTermDeposits() async {
    try {
      final authProvider = Provider.of<SessionProvider>(context, listen: false).user;
      final accounts = authProvider?.accounts;
      final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
      String cif = '';
      if (accounts!.isNotEmpty) {
        String account = accounts.first.accountNumber.toString();
        cif = account.substring(3, account.length - 3);
      }

      final response = await apiCustomerTermDeposits.getTermDeposits(
        _deviceId,
        referenceGenerator.generateUniqueReference(false),
        cif,
      );

      if (response['data']['response_code'] == '00') {
        final dynamic tdData = response['data']['term_deposits'];
        List<dynamic> loans = [];
        if (tdData is Map && tdData.containsKey('tdaccount')) {
          loans = tdData['tdaccount'] as List<dynamic>;
        } else if (tdData is List) {
          loans = tdData;
        }
        setState(() {
          tdAccountsList = loans.map((td) => TermDeposits.fromJson(td)).toList();
        });

        // final tds = response['data']['term_deposits']['tdaccount'] as List<dynamic>;
        // setState(() {
        //   tdAccountsList = tds.map((td) => TermDeposits.fromJson(td)).toList();
        // });
      }
    } catch (error) {
      print(error);
      showSnackBar(context, 'Error Loading Term Deposits: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  String extractDateOnly(String dateTimeString) {
    try {
      // Split the string at 'T' to separate date from time
      final datePart = dateTimeString.split('T')[0];
      return datePart;
    } catch (e) {
      print("Error parsing date: $e");
      return dateTimeString; // Fallback (or throw an exception)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Term Deposit'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading ?
        Center(
          child: CircularProgressIndicator(
            color: Colors.red.shade900,
          )
      )
          :
      tdAccountsList.isNotEmpty ?
        _mainTermDepositLists()
          :
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
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
            const SizedBox(height: 24),
            const Text(
              "Oops! Sorry currently you don't have any records",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'For term deposit please create one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0), // Adjust this value as needed
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TermDepositCreateScreen()),
            );
          },
          backgroundColor: Colors.indigo.shade900,
          shape: CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  //TODO - (1 )TD STATUS WIDGET
  Widget _mainTermDepositLists() {
    final authProvider = Provider.of<SessionProvider>(context).user;
    final accounts = authProvider?.accounts;
    final phoneNumber = Provider.of<SessionProvider>(context, listen: false).userLoginId;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(color: Colors.transparent),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.5),
          },
          children: [
            _buildTableHeader(),
            ...tdAccountsList.asMap().entries.map((entry) {
              final index = entry.key;
              final td = entry.value;
              return _buildTableRow(
                td.statementCycle,
                '${td.currency} ${td.tdAmount}',
                extractDateOnly(td.maturityDate),
                td.accountClass,
                index % 2 == 0, // Highlight every even ROW
                onViewTap: () {
                  print('Tapped View for TD ${td.tdaccount}');
                },
              );
            }),
          ],
        ),
      ),
    );
  }
  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4),
      ),
      children: [
        _buildHeaderCell('Type'),
        _buildHeaderCell('Amount'),
        _buildHeaderCell('Maturity'),
        _buildHeaderCell('Status'),
      ],
    );
  }
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 10,
        ),
      ),
    );
  }
  TableRow _buildTableRow(
      String tdType,
      String tdAmount,
      String tdMaturity,
      String tdStatus,
      bool highlight, {
        VoidCallback? onViewTap,
      }) {
    final backgroundColor = highlight ? Colors.white : const Color(0xFFF5F5F5); // Light grey
    return TableRow(
      decoration: BoxDecoration(color: backgroundColor),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(tdType,
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(tdAmount,
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(tdMaturity,
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: onViewTap,
            child: Text(
              tdStatus,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
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