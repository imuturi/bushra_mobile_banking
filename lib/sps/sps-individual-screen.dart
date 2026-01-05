import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';



class QRPaymentIndividualScreen extends StatefulWidget {
  const QRPaymentIndividualScreen({super.key});

  @override
  State<QRPaymentIndividualScreen> createState() => _QRPaymentIndividualScreenState();
}

class _QRPaymentIndividualScreenState extends State<QRPaymentIndividualScreen> {
  double amount = 1200;
  double minAmount = 5;
  double maxAmount = 5000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: Text(AppLocalizations.of(context)!.scanAQrCode),
      ),
      body:  Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountBalanceCard(),
            SizedBox(height: 16),
            MerchantDetails(),
            SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.howMuchWouldYouLikeToPay, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            AmountSelector(),
            SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.selectDebitAccount),
            AccountDropdown(),
            Spacer(),
            PayButton(),
          ],
        ),
      ),
    );
  }
}

class AccountBalanceCard extends StatelessWidget {
  const AccountBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Current Account - A/C #1234******6789", style: TextStyle(color: Colors.white)),
          Divider(color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Actual Balance\nUSD 8,000.00", style: TextStyle(color: Colors.white)),
              Text("Available Balance\nUSD 7,000.00", style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class MerchantDetails extends StatelessWidget {
  const MerchantDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return  Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.merchantDetails, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Merchant Name: Tasima Kumasi"),
            Text("Merchant ID: 2345678"),
          ],
        ),
      ),
    );
  }
}

class AmountSelector extends StatefulWidget {
  const AmountSelector({super.key});

  @override
  State<AmountSelector> createState() => _AmountSelectorState();
}

class _AmountSelectorState extends State<AmountSelector> {
  double amount = 1200;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: () {
                setState(() {
                  if (amount > 10) amount -= 100;
                });
              },
            ),
            Text("USD \$${amount.toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () {
                setState(() {
                  if (amount < 5000) amount += 100;
                });
              },
            ),
          ],
        ),
        Slider(
          min: 10,
          max: 5000,
          value: amount,
          onChanged: (value) {
            setState(() {
              amount = value;
            });
          },
        ),
      ],
    );
  }
}

class AccountDropdown extends StatelessWidget {
  const AccountDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: "A/C #1234******6789",
          items: const [
            DropdownMenuItem(
              value: "A/C #1234******6789",
              child: Text("A/C #1234******6789"),
            ),
          ],
          onChanged: (value) {},
        ),
      ),
    );
  }
}

class PayButton extends StatelessWidget {
  const PayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          //TODO
        },
        child:  Text(AppLocalizations.of(context)!.pay, style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
