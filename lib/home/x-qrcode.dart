import 'package:bushra_mobile/qrcode/page-home-qrcode-myqrcode.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../qrcode/page-home-qrcode-scanner.dart';

class QRCodeMainScreen extends StatelessWidget {
  const QRCodeMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.scanToPay),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
          const SizedBox(height: 30,),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: QROptionTile(
              title: AppLocalizations.of(context)!.myQrCode,
              icon: Icons.qr_code_scanner,
              onTap: () {
                //TODO
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) =>
                    const MyQRScreen())
                );
              },
            ),
          ),
          const SizedBox(height: 16,),
          Container(
            //padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: QROptionTile(
              title: AppLocalizations.of(context)!.scanToPay,
              icon: Icons.qr_code_scanner,
              onTap: () {
                //TODO
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) =>
                    const QRCodeScannerScreen()));
              },
            ),
          ),
          ],
        ),
      )
    );
  }
}

class QROptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const QROptionTile({super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red[50],
        radius: 24,
        child: Icon(icon, color: Colors.red.shade900),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}