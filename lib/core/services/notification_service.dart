import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_navigation.dart';
import '../core.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    final NotificationSettings settings = await _firebaseMessaging.requestPermission();

    debugPrint('Permissions accordées: ${settings.authorizationStatus}');

    final String? token = await _firebaseMessaging.getToken();
    debugPrint('Token FCM: $token');

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('Nouveau token FCM: $newToken');
      _sendTokenToServer(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message reçu en premier plan!');
      debugPrint('Données du message: ${message.data}');

      if (message.notification != null) {
        debugPrint('Titre: ${message.notification!.title}');
        debugPrint('Corps: ${message.notification!.body}');

        _showNotificationPopup(
          message.notification?.title,
          message.notification?.body,
          message.data.toString(),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message cliqué!');
      _handleNotificationClick(message);
    });

    await _initializeLocalNotifications();
    await _createNotificationChannel();
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification locale cliquée: ${response.payload}');
        _handleLocalNotificationClick(response.payload);
      },
    );
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notifications importantes',
      description: 'Ce canal est utilisé pour les notifications importantes.',
      importance: Importance.max,
    );

    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

/*
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'Notifications importantes',
      channelDescription: 'Ce canal est utilisé pour les notifications importantes.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final String payload = _createPayloadForPopup(
      message.notification?.title,
      message.notification?.body,
      message.data.toString(),
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Pas de titre',
      message.notification?.body ?? 'Pas de contenu',
      platformChannelSpecifics,
      payload: payload,
    );
  }
*/

  static void _handleNotificationClick(RemoteMessage message) {
    debugPrint('Notification Firebase cliquée: ${message.data}');
    _showNotificationPopup(
      message.notification?.title,
      message.notification?.body,
      message.data.toString(),
    );
  }

  static void _handleLocalNotificationClick(String? payload) {
    debugPrint('Notification locale cliquée avec payload: $payload');
    if (payload != null) {
      final Map<String, String> data = _parsePayload(payload);
      _showNotificationPopup(
        data['title'],
        data['body'],
        data['data'],
      );
    }
  }

  static void _showNotificationPopup(String? title, String? body, String? payload) {
    showDialog(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) => Consumer(
        builder: (context, ref, child) {
          final isDarkMode = ref.watch(themeProvider).isDarkMode;
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            title: title != null ? Text(title, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: isDarkMode ? onPrimaryLight : onPrimaryDark)) : null,
            content: body != null ? Text(body, style: Theme.of(context).textTheme.titleSmall!.copyWith(color: isDarkMode ? onPrimaryLight : onPrimaryDark)) : null,
            actions: [
              TextButton(
                child: Text('OK', style: Theme.of(rootNavigatorKey.currentContext!).textTheme.titleSmall!.copyWith(color: isDarkMode ? onPrimaryLight : onPrimaryDark)),
                onPressed: () {

                  print('Action de notification déclenchée avec title: $title');
                  print('Action de notification déclenchée avec body: $body');
                  print('Action de notification déclenchée avec payload: $payload');

                  Navigator.of(context).pop();

                  // if (payload != null && payload.isNotEmpty) {
                  //   debugPrint('Action avec payload: $payload');
                  // }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  static String _createPayloadForPopup(String? title, String? body, String? data) => 'title:${title ?? ''}|body:${body ?? ''}|data:${data ?? ''}';

  static Map<String, String> _parsePayload(String payload) {
    final Map<String, String> result = {};
    final List<String> parts = payload.split('|');

    for (String part in parts) {
      final List<String> keyValue = part.split(':');
      if (keyValue.length == 2) {
        result[keyValue[0]] = keyValue[1];
      }
    }

    return result;
  }

  static Future<void> _sendTokenToServer(String token) async {
    debugPrint('Envoi du token au serveur: $token');
  }

  static Future<String?> getFCMToken() async => await _firebaseMessaging.getToken();

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Abonné au topic: $topic');
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Désabonné du topic: $topic');
  }

  static Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'custom_channel',
      'Notifications personnalisées',
      channelDescription: 'Canal pour les notifications personnalisées',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final String structuredPayload = _createPayloadForPopup(title, body, payload);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: structuredPayload,
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    debugPrint('Notification programmée pour: $scheduledDate');
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
