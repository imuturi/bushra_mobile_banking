import 'dart:async';
import 'package:bushra_mobile/utils/constants/app_constants.dart';
import 'package:bushra_mobile/utils/providers/provider-session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IdleWatcher extends StatefulWidget {
  final Widget child;
  const IdleWatcher({super.key, required this.child});

  @override
  _IdleWatcherState createState() => _IdleWatcherState();
}

class _IdleWatcherState extends State<IdleWatcher> {
  Timer? _idleTimer;
  final Duration timeout = Duration(minutes: AppConstants.appIdleTimeMinutes);

  void _resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(timeout, () {
      Provider.of<SessionProvider>(context, listen: false).logout();
    });
  }

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetTimer(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
