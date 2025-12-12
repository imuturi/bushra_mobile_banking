import 'dart:async';
import 'package:bushra_mobile/page-landing/page-home-introduction.dart';
import 'package:bushra_mobile/page-landing/page-home-landing-login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkIntroPageViewed(context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkIntroPageViewed(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isIntroductionPageViewed = prefs.getBool('isIntroductionPageViewed');
    if (isIntroductionPageViewed != null) {
      if(!isIntroductionPageViewed){
        //TODO - Go To Onboarding Sliders
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeOnBoarding()),);
        });
      }else{
        //TODO - Go To Landing Page - Getting Started
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LandingPageLogin()),);
        });
      }
    }else{
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeOnBoarding()),);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Image.asset(
            'assets/images/slider/slider-01.png',
          fit: BoxFit.cover,
        )
      ),
    );
  }

}