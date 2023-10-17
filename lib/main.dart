// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_print

import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/pages/login_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:one_payment/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  Stripe.publishableKey =
      'pk_test_51ItDmYDHIShlREvdwFL1M4FCvq3aVVBGedU1QnYpnGfaJu7Az9YfNdHCS2Lp22gxWVswzKoDB30t4GWEmk5grbyA00mPfFYPqz';
  await Stripe.instance.applySettings();
  runApp(MyApp());
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String channelName = 'UniversalApp';
  // This widget is the root of your application.

  @override
  initState() {
    super.initState();
    getPrefInstance();
  }

  Future<void> getPrefInstance() async {
    _pref = await SharedPreferences.getInstance();
  }

  late SharedPreferences _pref;
  startPage() {
    final String? userEmail = _pref.getString('email');
    log('userEmail $userEmail');
    if (userEmail == null) {
      return RegisterPage();
    } else {
      return BottomNavBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}
