import 'package:flutter/material.dart';

import '../account-opening/open-account-1.dart';

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
        title: const Text(
          "Account Opening",
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
                      const Text(
                        "ACCOUNT OPENING",
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
              title: const Text("Business Account"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You will find Business Account products that are tailored for Business that follow account laws",
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
                        child: const Text("GET STARTED", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(thickness: 1),
            ExpansionTile(
              title: const Text("Islamic Accounts"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You will find Islamic products that are tailored for Muslims that follow Sharia laws",
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
                        child: const Text("GET STARTED", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(thickness: 1),
            ExpansionTile(
              title: const Text("Investment Account"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You will find Investment Account products that are tailored for Business that follow account laws",
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
                        child: const Text("GET STARTED", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(thickness: 1),
            ExpansionTile(
              title: const Text("Students Accounts"),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You will find Students Accounts products that are tailored for Business that follow account laws",
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
                        child: const Text("GET STARTED", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),),
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