import 'package:bushra_mobile/standing-order/page-home-sto-create-1.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class StandingOrderListScreen extends StatefulWidget {
  const StandingOrderListScreen({super.key});

  @override
  State<StandingOrderListScreen> createState() => _StandingOrderListScreenState();
}

class _StandingOrderListScreenState extends State<StandingOrderListScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.standingOrder),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              AppLocalizations.of(context)!.hereAreYourCurrentStandingOrders,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red,
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                   Text(
                     AppLocalizations.of(context)!.recurringStandingOrder,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        StandingOrderDetailRow(label: 'Type:', value: 'Recurring standing order'),
                        StandingOrderDetailRow(label: 'Frequency:', value: 'Sweep in from account'),
                        StandingOrderDetailRow(label: 'Instruction Amount:', value: 'USD 1200'),
                        StandingOrderDetailRow(label: 'Threshold Amount:', value: 'USD 1300'),
                        StandingOrderDetailRow(label: 'Account number:', value: 'A/C #1234******6789'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //TODO
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StandingOrderCreate1Screen()));
        },
        backgroundColor: Colors.indigo.shade900,
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}

class StandingOrderDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const StandingOrderDetailRow({super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
