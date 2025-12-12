import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../notifications/fcm-service.dart';

class NotificationServiceProvider with ChangeNotifier {

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  List<AlertData> _alerts = [];
  Database? _database;

  List<AlertData> get alerts => _alerts;

  NotificationServiceProvider(); // Don't call init() here

  Future<void> init() async {
    await _initDb();
    await _loadAlertsFromDb();
    await _initFCM();
  }

  Future<void> safeInit() async {
    await _initDb();
    await _loadAlertsFromDb();
    await _initFCM();
  }

  Future<void> _initDb() async {
    if (_database != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alerts.db');

    // 🚨 Force drop old DB (all users will lose old alerts)
    await deleteDatabase(path);

    _database = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE alerts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          dateTime TEXT,
          isRead INTEGER DEFAULT 0,
          iconId TEXT DEFAULT "notifications",
          iconColorValue INTEGER
        )
      ''');
      },
    );

    if (kDebugMode) {
      print('✅ Fresh Database created at $path');
    }
  }


  Future<void> _loadAlertsFromDb() async {
    if (_database == null || !_database!.isOpen) {
      await _initDb(); // Reinitialize or handle the null case
    }
    final List<Map<String, dynamic>> maps = await _database!.query('alerts');
    _alerts = maps.map((map) => AlertData.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> _initFCM() async {
    await _initDb();
    await _messaging.requestPermission();
    await FCMService.setupLocalNotifications();

    // Save FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('USER_FCM_TOKEN', token);
      if (kDebugMode) {
        print('🔑 FCM Token: $token');
      }
    }

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _handleIncomingMessage(message);
    });

    // Background click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _handleIncomingMessage(message);
      //navigatorKey.currentState?.pushNamed('/alerts');
    });

    // Terminated (app killed)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _handleIncomingMessage(initialMessage);
      //navigatorKey.currentState?.pushNamed('/alerts');
    }
  }

  Future<void> _handleIncomingMessage(RemoteMessage message) async {
    final alert = AlertData(
      title: message.notification?.title ?? 'No Title',
      description: message.notification?.body ?? 'No Description',
      dateTime: DateTime.now().toIso8601String(),
      iconId: 'notifications',
      iconColor: Colors.white, // give default color
    );
    await _addAlert(alert);

    // Show local notification popup
    FCMService.showLocalNotification(message);
  }

  Future<void> _addAlert(AlertData alert) async {
    if (_database == null || !_database!.isOpen) {
      await _initDb();
    }
    final id = await _database!.insert('alerts', alert.toMap());
    _alerts.insert(0, alert.copyWith(id: id));
    notifyListeners();
  }

  Future<void> removeAlert(int id) async {
    if (_database == null || !_database!.isOpen) {
      await _initDb();
    }
    await _database!.delete('alerts', where: 'id = ?', whereArgs: [id]);
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> markAlertAsRead(int id) async {
    if (_database == null || !_database!.isOpen) {
      await _initDb();
    }
    await _database!.update(
      'alerts',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isRead: true);
      notifyListeners();
    }
  }


}

class AlertData {
  final int? id;
  final String title;
  final String description;
  final String dateTime;
  final String iconId;
  final Color iconColor;
  final bool isRead;

  AlertData({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.iconId,
    required this.iconColor,
    this.isRead = false,
  });

  AlertData copyWith({
    int? id,
    String? title,
    String? description,
    String? dateTime,
    String? iconId,
    Color? iconColor,
    bool? isRead,
  }) {
    return AlertData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      iconId: iconId ?? this.iconId,
      iconColor: iconColor ?? this.iconColor,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'iconId': iconId,
      'iconColorValue': iconColor.value,
      'isRead': isRead ? 1 : 0,
    };
  }

  factory AlertData.fromMap(Map<String, dynamic> map) {
    return AlertData(
      id: map['id'],
      title: map['title'] ?? 'No Title',
      description: map['description'] ?? 'No Description',
      dateTime: map['dateTime'] ?? DateTime.now().toString(),
      iconId: map['iconId'] ?? 'notifications',
      iconColor: Color(map['iconColorValue'] ?? Colors.white.value),
      isRead: (map['isRead'] ?? 0) == 1,
    );
  }
}



class DbMigrations {
  static Future<void> migrateTo2(Database db) async {
    if (!await columnExists(db, 'alerts', 'isRead')) {
      await db.execute('ALTER TABLE alerts ADD COLUMN isRead INTEGER DEFAULT 0');
      await db.execute('UPDATE alerts SET isRead = 0'); // set default for old rows
    }
  }

  static Future<void> migrateTo3(Database db) async {
    if (!await columnExists(db, 'alerts', 'iconId')) {
      await db.execute('ALTER TABLE alerts ADD COLUMN iconId TEXT');
      await db.execute('ALTER TABLE alerts ADD COLUMN isRead INTEGER DEFAULT 0');
      await db.execute('UPDATE alerts SET iconId = "notifications"');
    }
  }

  static Future<bool> columnExists(Database db, String table, String column) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((row) => row['name'] == column);
  }
}

