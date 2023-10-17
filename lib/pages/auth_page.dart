// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_local_variable, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/pages/numericpad.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final TextEditingController _codecontroller = TextEditingController();
  String phoneNumber = "", data = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String smscode = "";

  _signInWithMobileNumber() async {
    UserCredential _credential;
    User user;
    try {
      await _auth.verifyPhoneNumber(
          // ignore: prefer_interpolation_to_compose_strings
          phoneNumber: '+234' + data.trim(),
          verificationCompleted: (PhoneAuthCredential authCredential) async {
            await _auth.signInWithCredential(authCredential).then((value) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BottomNavBar()));
            });
          },
          verificationFailed: ((error) {
            print(error);
          }),
          codeSent: (String verificationId, [int? forceResendingToken]) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                      title: const Text("Enter OTP"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _codecontroller,
                          )
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              FirebaseAuth auth = FirebaseAuth.instance;
                              smscode = _codecontroller.text;
                              PhoneAuthCredential _credential =
                                  PhoneAuthProvider.credential(
                                      verificationId: verificationId,
                                      smsCode: smscode);
                              auth
                                  .signInWithCredential(_credential)
                                  .then((result) {
                                // ignore: unnecessary_null_comparison
                                if (result != null) {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const BottomNavBar()));
                                }
                              }).catchError((e) {
                                print(e);
                              });
                            },
                            child: const Text("Done"))
                      ],
                    ));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
          },
          timeout: const Duration(seconds: 45));
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Continue with phone",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF7F7F7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 130,
                      child: Image.asset('assets/images/applogo.jpg'),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 64),
                      child: Text(
                        "You'll receive a 6 digit code to verify next.",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF818181),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.13,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Enter your phone",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            phoneNumber,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          data = phoneNumber;
                          phoneNumber = "";

                          setState(() {});

                          _signInWithMobileNumber();
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFDC3D),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            NumericPad(
              onNumberSelected: (value) {
                setState(() {
                  if (value != -1) {
                    phoneNumber = phoneNumber + value.toString();
                  } else {
                    phoneNumber =
                        phoneNumber.substring(0, phoneNumber.length - 1);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
