import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shatbha/core/logging/app_log.dart';
import 'package:shatbha/firebase_options.dart';

import '../../data/repositories/notification_repository.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationService {
  PushNotificationService(this._repo);

  final NotificationRepository _repo;
  final _local = FlutterLocalNotificationsPlugin();
  GoRouter? _router;
  String? _token;
  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await _local.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (res) {
          final route = res.payload;
          if (route != null && route.isNotEmpty) {
            _router?.go(route);
          }
        },
      );

      const channel = AndroidNotificationChannel(
        'shatbha_default',
        'شطبها',
        description: 'تنبيهات شطبها',
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      FirebaseMessaging.onMessage.listen(_showForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage);

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        scheduleMicrotask(() => _openFromMessage(initial));
      }

      messaging.onTokenRefresh.listen(_syncToken);
      _ready = true;
      AppLog.i('Firebase messaging ready', tag: 'fcm');
    } catch (e, st) {
      AppLog.e('Firebase init failed', tag: 'fcm', error: e, stack: st);
    }
  }

  void bindRouter(GoRouter router) => _router = router;

  Future<void> onAuthenticated() async {
    if (!_ready) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _syncToken(token);
    } catch (e) {
      AppLog.e('FCM token sync failed', tag: 'fcm', error: e);
    }
  }

  Future<void> onLogout() async {
    if (_token == null) return;
    try {
      await _repo.revokeToken(_token!);
    } catch (_) {}
    _token = null;
  }

  Future<void> _syncToken(String token) async {
    _token = token;
    final platform = Platform.isIOS ? 'ios' : 'android';
    try {
      await _repo.registerToken(token, platform);
      AppLog.d('FCM token registered', tag: 'fcm');
    } catch (e) {
      AppLog.e('FCM register failed', tag: 'fcm', error: e);
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final n = message.notification;
    final title = n?.title ?? message.data['title']?.toString() ?? 'شطبها';
    final body = n?.body ?? message.data['body']?.toString() ?? '';
    final route = message.data['route']?.toString();
    await _local.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'shatbha_default',
          'شطبها',
          channelDescription: 'تنبيهات شطبها',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: route,
    );
  }

  void _openFromMessage(RemoteMessage message) {
    final route = message.data['route']?.toString();
    if (route != null && route.isNotEmpty) {
      _router?.go(route);
    }
  }
}
