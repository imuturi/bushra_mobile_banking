import 'package:bushra_mobile/session-manager.dart';
import 'package:flutter/material.dart';

import 'idle-watcher.dart';
import 'main.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return IdleWatcher(
      child: SessionManager(
        child: const MyApp(),
      ),
    );
  }
}
