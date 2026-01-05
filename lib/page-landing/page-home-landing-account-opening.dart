import 'package:flutter/material.dart';

import '../account-opening/open-account-1.dart';
import '../l10n/app_localizations.dart';

class LandingPageAccountOpening extends StatelessWidget {
  const LandingPageAccountOpening({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            //TODO
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.accountOpening,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 180,
              child: Image.asset(
                'assets/images/landing-account-opening.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(color: Colors.blueAccent, spreadRadius: 1),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        AppLocalizations.of(context)!.accountOpening,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean rhoncus placerat erat. Fusce malesuada, velit et efficitur consequat, nisi nisl pharetra neque, ut tristique ligula turpis in nisi. Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(thickness: 1),
            ExpansionTile(
              title: Text(AppLocalizations.of(context)!.businessAccount),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.youWillFindBusinessAccountProductsThatAreTailoredForBusinessThatFollowAccountLaws,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          //TODO
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OpenAccountScreen1()));
                        },
                        child: Text(AppLocalizations.of(context)!.getStarted, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(thickness: 1),
            ExpansionTile(
              title: Text(AppLocalizations.of(context)!.islamicAccounts),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.youWillFindIslamicProductsThatAreTailoredForMuslimsThatFollowShariaLaws,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          //TODO
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OpenAccountScreen1()));
                        },
                        child: Text(AppLocalizations.of(context)!.getStarted, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(thickness: 1),
            ExpansionTile(
              title: Text(AppLocalizations.of(context)!.investmentAccount),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.youWillFindBusinessAccountProductsThatAreTailoredForBusinessThatFollowAccountLaws,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          //TODO
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OpenAccountScreen1()));
                        },
                        child:  Text(AppLocalizations.of(context)!.getStarted, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(thickness: 1),
            ExpansionTile(
              title: Text(AppLocalizations.of(context)!.studentsAccounts),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.youWillFindBusinessAccountProductsThatAreTailoredForBusinessThatFollowAccountLaws,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          //TODO
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OpenAccountScreen1()));
                        },
                        // child: const Text("GET STARTED", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                        child:  Text(AppLocalizations.of(context)!.getStarted, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(thickness: 1),
          ],
        ),
      ),
    );
  }
}