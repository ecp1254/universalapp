// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/pages/change_password.dart';
import 'package:one_payment/pages/change_pin.dart';
import 'package:one_payment/pages/chat.dart';
import 'package:one_payment/pages/login_page.dart';
import 'package:one_payment/pages/profile_after_register.dart';
import 'package:one_payment/pages/profile.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ignore: unused_field
  double? _accountBalance;

  Future<void> _getUser() async {
    User? user = auth.currentUser;
    setState(() {
      user = user;
    });
    if (user != null) {
      await _fetchAccountBalance(user!.uid);
    }
  }

  Future<void> _fetchAccountBalance(String userId) async {
    final DocumentSnapshot snapshot =
        await _firestore.collection('user').doc(userId).get();
    final userData = snapshot.data() as Map<String, dynamic>?;
    if (userData != null) {
      setState(() {
        _accountBalance = userData['accountBalance'] as double?;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      user = auth.currentUser;
      _getUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              nextScreen(context, const BottomNavBar());
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: const Color.fromARGB(255, 10, 124, 16),
          ),
          title: Center(
            child: Text(
              'Account Management',
              style: GoogleFonts.montserrat(
                  color: Colors.green, fontWeight: FontWeight.w600),
            ),
          ),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ProfileItem(
                    title: 'Change Transfer Pin',
                    icon: Icons.format_list_numbered,
                    onPress: () {
                      nextScreenReplace(context, const ChangePin());
                    },
                    textColor: const Color.fromARGB(255, 10, 124, 16),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  ProfileItem(
                    title: 'Change Password',
                    icon: Icons.password,
                    onPress: () {
                      nextScreenReplace(context, const ChangePassword());
                    },
                    textColor: const Color.fromARGB(255, 10, 124, 16),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  ProfileItem(
                    title: 'User Profile',
                    icon: Icons.person,
                    onPress: () {
                      nextScreen(context, const Profiles());
                    },
                    textColor: const Color.fromARGB(255, 10, 124, 16),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          backgroundColor: Colors.green),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          user = null;
                          _accountBalance = null;
                        });
                        nextScreenReplace(context, const LoginPage());
                      },
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.poppins(
                            fontSize: 28, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Customer Support',
                      style: GoogleFonts.montserrat(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('support')
                        .doc('contacts')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.data() == null) {
                        return const Center(
                            child: Text('No support information available.'));
                      }

                      var supportData =
                          snapshot.data!.data()! as Map<String, dynamic>;

                      return Column(
                        children: [
                          Text.rich(
                            TextSpan(
                              text: supportData['email'],
                              style: GoogleFonts.montserrat(
                                  fontSize: 17, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text.rich(
                            TextSpan(
                              text: supportData['phoneNumber1'],
                              style: GoogleFonts.montserrat(
                                  fontSize: 17, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text.rich(
                            TextSpan(
                              text: supportData['phoneNumber2'],
                              style: GoogleFonts.montserrat(
                                  fontSize: 17, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text.rich(
                    TextSpan(
                      text: "Chat a customer service personel",
                      style: GoogleFonts.montserrat(
                          color: const Color.fromARGB(255, 10, 124, 16),
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          nextScreenReplace(context, const Chat());
                        },
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
