import 'package:bushra_mobile/page-landing/page-home-landing-account-opening.dart';
import 'package:bushra_mobile/page-landing/page-home-landing-login-dialog.dart';
import 'package:bushra_mobile/page-landing/page-home-landing-support.dart';
import 'package:bushra_mobile/register/landing-register-7-terms-conditions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/landing-login-3-login.dart';

//TODO - THIS IS THE MAIN 2 (LOGIN )LANDING AFTER SUCCESSFUL REGISTRATION + LOGIN
class LandingPageLogin extends StatefulWidget {
  const LandingPageLogin({super.key});
  @override
  State<LandingPageLogin> createState() => _LandingPageLoginState();
}

class _LandingPageLoginState extends State<LandingPageLogin> {
  String isSelfRegistered = 'FALSE'; //IS_SELF_REGISTERED_SUCCESS
  String isPasswordChanged = 'FALSE'; //IS_SELF_PASSWORD_CHANGED_SUCCESS
  String loginId = 'FALSE'; //LOGIN_ID

  @override
  void initState() {
    super.initState();
    _loadSharedPreferencesValue();
  }

  Future<void> _loadSharedPreferencesValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSelfRegistered = prefs.getString('IS_SELF_REGISTERED_SUCCESS') ?? "FALSE";
      isPasswordChanged = prefs.getString('IS_SELF_PASSWORD_CHANGED_SUCCESS') ?? "FALSE";
      loginId = prefs.getString('USER_LOGIN_ID') ?? "FALSE";
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/landing-get-started.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: size.height * 0.6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.6), // Transparent top
                    Colors.white.withOpacity(0.9),
                    Colors.white,                  // Solid white bottom
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8), // Subtle white edge for visibility
                  width: 2.0,
                ),
              ),
              child: SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Your Personal Bank',
                                  style: TextStyle(
                                    fontSize: size.width * 0.035,
                                    color: Colors.red.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Authorise & get access to ',
                                      style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontSize: size.width * 0.09,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'all Features',
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontSize: size.width * 0.08,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enjoy your personal bank account, your phone is your bank.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: size.width * 0.03,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                alignment: WrapAlignment.center,
                                children: [
                                  _actionButton(
                                    context: context,
                                    icon: Icons.account_balance,
                                    label: 'Open Account',
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const LandingPageAccountOpening(),
                                      ),
                                    ),
                                    width: isLandscape ? size.width * 0.3 : size.width * 0.4,
                                  ),
                                  _actionButton(
                                    context: context,
                                    icon: Icons.help_outline,
                                    label: 'Support',
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SupportScreen(),
                                      ),
                                    ),
                                    width: isLandscape ? size.width * 0.3 : size.width * 0.4,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 24),
                                  _loginButton(context),
                                  const SizedBox(height: 12),
                                  _registerButton(context),
                                  const SizedBox(height: 4),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required double width,
  }) {
    return SizedBox(
      width: width,
      height: 108,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          //TODO logic
          if (isSelfRegistered == 'TRUE' && loginId != 'FALSE') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PinInputLoginScreen()));
          } else if (isPasswordChanged == 'TRUE' && loginId != 'FALSE') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PinInputLoginScreen()));
          } else {
            showDialog(
                context: context,
                builder: (context) => const FirstTimeLoginDialog());
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
          'LOGIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _registerButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade900),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'REGISTER',
          style: TextStyle(
            color: Colors.red.shade900,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
