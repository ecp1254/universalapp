import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Notification> notifications;

  const NotificationsScreen({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(notification.title),
            subtitle: Text(notification.body),
          );
        },
      ),
    );
  }
}

class Notification {
  final String title;
  final String body;

  Notification({
    required this.title,
    required this.body,
  });
}
