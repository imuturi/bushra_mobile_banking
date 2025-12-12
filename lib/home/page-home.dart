import 'dart:async';
import 'package:bushra_mobile/home/x-qrcode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/providers/provider-session.dart';
import '../widgets/bottom-navigation.dart';
import 'x-home.dart';
import 'x-settings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? _lastBackPressed;
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomePageScreen(),
    QRCodeMainScreen(),
    SettingsScreen(showBackButton: false),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _handlePopInvoked() async {
    // ✅ Check if there are screens to pop in the current navigation stack
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      // If there are screens on top (like ProfileScreen, SupportScreen, etc.),
      // let them pop normally without the exit app prompt
      return true;
    }

    // ✅ Only handle "exit app" logic if we're at the root of the bottom nav
    if (_lastBackPressed == null) {
      _lastBackPressed = DateTime.now();
      const snackBar = SnackBar(
        content: Text('Press back again to exit the app'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(_lastBackPressed!);
    if (difference >= const Duration(seconds: 2)) {
      _lastBackPressed = now;
      const snackBar = SnackBar(
        content: Text('Press back again to exit the app'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }

    Provider.of<SessionProvider>(context, listen: false).logout();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _handlePopInvoked();
        if (shouldPop) {
          if (mounted) {
            // exit logic or allow the pop
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: CustomBottomNav(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//   DateTime? _lastBackPressed;
//   int _selectedIndex = 0;
//
//   final List<Widget> _screens = const [
//     HomePageScreen(),
//     QRCodeMainScreen(),
//     SettingsScreen(showBackButton: false,),
//   ];
//
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   Future<bool> _handlePopInvoked() async {
//     if (_lastBackPressed == null) {
//       _lastBackPressed = DateTime.now();
//       const snackBar = SnackBar(
//         content: Text('Press back again to exit the app'),
//         duration: Duration(seconds: 2),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       return false;
//     }
//     final now = DateTime.now();
//     final difference = now.difference(_lastBackPressed!);
//     if (difference >= const Duration(seconds: 2)) {
//       _lastBackPressed = now;
//       const snackBar = SnackBar(
//         content: Text('Press back again to exit the app'),
//         duration: Duration(seconds: 2),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       return false;
//     }
//     Provider.of<SessionProvider>(context, listen: false).logout();
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, _) async {
//         if (didPop) return;
//         final shouldPop = await _handlePopInvoked();
//         if (shouldPop) {
//           if (mounted) {
//             // exit logic
//           }
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: IndexedStack( // ✅ Keeps screens alive for instant switching
//           index: _selectedIndex,
//           children: _screens,
//         ),
//         bottomNavigationBar: CustomBottomNav(
//           selectedIndex: _selectedIndex,
//           onItemTapped: _onItemTapped,
//         ),
//       ),
//     );
//   }
// }
