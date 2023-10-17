import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:one_payment/pages/homepage.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            nextScreenReplace(context, const HomePage());
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications available.',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            );
          }

          // If you reach here, there are notifications
          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              var notificationData =
                  notification.data() as Map<String, dynamic>;

              // Format the timestamp to display in a readable format
              String formattedDate =
                  _formatTimestamp(notificationData['timestamp'] as Timestamp);

              return ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    notificationData['title'] as String? ?? '',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificationData['body'] as String? ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 15, color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text('Received on $formattedDate'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Convert the Firestore Timestamp to a DateTime
    DateTime dateTime = timestamp.toDate();

    // Format the DateTime as a string
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    return formattedDate;
  }
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final _messageStreamController = StreamController<String>();

  // Expose the stream for listening
  Stream<String> get messageStream => _messageStreamController.stream;

  Future initialize() async {
    // Request permission for receiving notifications
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get the device token
    String? token = await _fcm.getToken();
    ('FCM Token: $token');

    // Save the device token to Firestore
    await saveTokenToFirestore(token);

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ('onMessage: ${message.notification?.body}');
      _messageStreamController.add(message.notification?.body ?? '');

      // Save the notification to Firestore
      saveNotificationToFirestore(message.notification?.body);
    });

    // Handle notification when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      ('onMessageOpenedApp: ${message.notification?.body}');
      _messageStreamController.add(message.notification?.body ?? '');

      // Save the notification to Firestore
      saveNotificationToFirestore(message.notification?.body);
    });

    // Handle notification when the app is completely closed
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      ('Initial message: ${initialMessage.notification?.body}');
      _messageStreamController.add(initialMessage.notification?.body ?? '');

      // Save the notification to Firestore
      saveNotificationToFirestore(initialMessage.notification?.body);
    }
  }

  Future<String?> getDeviceToken() async {
    return await _fcm.getToken();
  }

  Future<void> saveTokenToFirestore(String? token) async {
    if (token != null) {
      String email = FirebaseAuth.instance.currentUser!.email!;
      ('Saving FCM Token to Firestore for $email: $token');

      var userDocumentRef =
          FirebaseFirestore.instance.collection('deviceTokens').doc(email);

      await userDocumentRef.set({'token': token});
      ('FCM Token saved to Firestore successfully.');
    }
  }

  Future<void> saveNotificationToFirestore(String? notification) async {
    if (notification != null) {
      String email = FirebaseAuth.instance.currentUser!.email!;
      ('Saving Notification to Firestore for $email: $notification');

      var notificationsCollectionRef =
          FirebaseFirestore.instance.collection('notifications');

      // Add a new document with the notification
      await notificationsCollectionRef.add({
        'email': email,
        'notification': notification,
        'timestamp': DateTime.now(),
      });
      ('Notification saved to Firestore successfully.');
    }
  }

  void dispose() {
    _messageStreamController.close();
  }
}
