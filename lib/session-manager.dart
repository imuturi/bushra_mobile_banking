import 'package:bushra_mobile/utils/constants/app_constants.dart';
import 'package:bushra_mobile/utils/providers/provider-session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SessionManager extends StatefulWidget {
  final Widget child;
  const SessionManager({super.key, required this.child});

  @override
  _SessionManagerState createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager> with WidgetsBindingObserver {
  DateTime? _pausedTime;
  final Duration timeout = Duration(minutes: AppConstants.appIdleTimeMinutes);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null &&
          DateTime.now().difference(_pausedTime!) > timeout) {
        sessionProvider.logout(); // update this method if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
