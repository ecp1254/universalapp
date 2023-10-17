// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/pages/forget_password.dart';
import 'package:one_payment/pages/register_page.dart';
import 'package:one_payment/pages/verify_page.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PushNotificationService _pushNotificationService =
      PushNotificationService();

  // ignore: unused_field
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  UserCredential? userCredential;
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  @override
  void initState() {
    getPrefInstance();
    passwordVisible = true;
    super.initState();
    getEmail().then((savedEmail) {
      if (savedEmail != null) {
        emailController.text = savedEmail;
      }
      _pushNotificationService;
    });
  }

  @override
  void dispose() {
    super.dispose();
    saveEmail(emailController.text);
  }

  bool passwordVisible = false;
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String wrongEmail = 'Wrong email';
  String wrongPassword = 'Wrong Password';
  late SharedPreferences _pref;

  getPrefInstance() async {
    _pref = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 45, vertical: 70),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Universal App',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Login to make faster payments',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.greenAccent,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 180,
                          width: 180,
                          child: Image.asset('assets/images/applogo.jpg'),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Email',
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.grey[700],
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.green,
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              emailController.text;
                            });
                          },
                          validator: (val) {
                            return RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(val!)
                                ? null
                                : 'Please enter a valid email';
                          },
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: passwordController,
                          obscureText: passwordVisible,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.grey[700],
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.green,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                            suffixIconColor: Colors.green,
                            alignLabelWithHint: false,
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          validator: (val) {
                            if (val!.length < 6) {
                              return 'Password must be at least 6 characters';
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {},
                        ),
                        const SizedBox(height: 15),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  userCredential =
                                      await auth.signInWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  // Check if the user's email is verified
                                  if (userCredential!.user?.emailVerified ==
                                      true) {
                                    // Email is verified, proceed with login
                                    QuerySnapshot userDoc = await _firestore
                                        .collection('user')
                                        .where('email',
                                            isEqualTo:
                                                userCredential!.user?.email)
                                        .get();
                                    if (userDoc.docs.first['blocked']) {
                                      await auth.signOut();
                                      snackBar(context, Colors.red,
                                          'User is blocked. Cannot log in.');
                                      if (userCredential!.user != null) {
                                        _pref.setString(
                                          'email',
                                          emailController.text,
                                        );
                                      }
                                    } else {
                                      // Check if userCredential and user are not null
                                      if (userCredential != null &&
                                          userCredential!.user?.email != null) {
                                        // Fetch user data from Firestore
                                        DocumentSnapshot userDoc =
                                            await _firestore
                                                .collection('user')
                                                .doc(
                                                  userCredential!.user!.email!,
                                                )
                                                .get();
                                        // Check if the document exists
                                        if (userDoc.exists) {
                                          // Check if 'userType' field exists
                                          if (userDoc.data() != null &&
                                              (userDoc.data()
                                                      as Map<String, dynamic>)
                                                  .containsKey('userType')) {
                                            String userType = (userDoc.data()
                                                    as Map<String, dynamic>)[
                                                'userType'];
                                            // Check if userType is 'user'
                                            if (userType == 'user') {
                                              // User is allowed to log in
                                              nextScreen(context,
                                                  const BottomNavBar());
                                            } else {
                                              snackBar(context, Colors.red,
                                                  'Invalid user type');
                                            }
                                          } else {
                                            snackBar(context, Colors.red,
                                                'Invalid user data');
                                          }
                                        } else {
                                          // Document does not exist, handle accordingly
                                          snackBar(context, Colors.red,
                                              'User not found');
                                        }
                                      } else {
                                        // Handle the case where userCredential or user is null
                                        snackBar(context, Colors.red,
                                            'Authentication failed');
                                      }
                                    }
                                  } else {
                                    // Email is not verified, redirect to email verification screen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EmailVerifyLink(),
                                      ),
                                    );
                                  }

                                  setState(() {
                                    _isLoading = false;
                                  });
                                  // ignore: unused_local_variable
                                  String? token = await _pushNotificationService
                                      .getDeviceToken();
                                } catch (e) {
                                  ('Login failed: $e');

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  // Handle authentication errors
                                  if (e
                                      .toString()
                                      .contains('User is blocked')) {
                                    snackBar(context, Colors.red,
                                        'User is blocked. Cannot log in.');
                                  } else if (e == wrongEmail) {
                                    snackBar(context, Colors.red,
                                        'No user found for that email.');
                                  } else if (e == wrongPassword) {
                                    snackBar(
                                        context, Colors.red, 'Wrong password.');
                                  } else {
                                    snackBar(context, Colors.red, '$e');
                                  }
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'poppins',
                              fontSize: 15,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Register here',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreenReplace(
                                      context,
                                      const RegisterPage(),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            nextScreenReplace(
                              context,
                              const ForgetPassword(),
                            );
                          },
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
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

    // Save the device token to Firestore
    await saveTokenToFirestore(token);

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _messageStreamController.add(message.notification?.body ?? '');

      // Save the notification to Firestore
      saveNotificationToFirestore(message.notification?.body);
    });

    // Handle notification when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
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

      var userDocumentRef =
          FirebaseFirestore.instance.collection('deviceTokens').doc(email);

      await userDocumentRef.set({'token': token});
    }
  }

  Future<void> saveNotificationToFirestore(String? notification) async {
    if (notification != null) {
      String email = FirebaseAuth.instance.currentUser!.email!;

      var notificationsCollectionRef =
          FirebaseFirestore.instance.collection('notifications');

      // Add a new document with the notification
      await notificationsCollectionRef.add({
        'email': email,
        'notification': notification,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void dispose() {
    _messageStreamController.close();
  }
}
