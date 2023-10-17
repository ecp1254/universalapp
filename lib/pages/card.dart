import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:one_payment/main.dart';

Future<void> initializeNotifications() async {
  // Initialize the settings for Android
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  // Initialize the settings for iOS

  // Initialize the initialization settings
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize the plugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

Future<void> showNotification() async {
  // Create a notification details object
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    importance: Importance.max,
    priority: Priority.high,
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    styleInformation: BigTextStyleInformation(''),
  );

  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Show the notification
  await flutterLocalNotificationsPlugin.show(
    0,
    'Notification Title',
    'Notification Body',
    platformChannelSpecifics,
    payload: 'notification_payload',
  );
}

Future<void> onSelectNotification(String? payload) async {
  // Handle notification selection here
}
