// ignore_for_file: use_build_context_synchronousl
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/login_page.dart';

import 'package:one_payment/pages/verify_page.dart';
import 'dart:math';
import 'package:one_payment/utilities/text_input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var usdBalance = 0.00;
  var eurBalance = 0.00;
  var gbpBalance = 0.00;
  bool isBlocked = false;

  String accountNumber = AccountNumberGenerator.generateAccountNumber();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final accountNumberController = TextEditingController();
  final TextEditingController datOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController userCityController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordMatch() {
    String password = passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    return password == confirmPassword;
  }

  bool _isLoading = false;
  bool passwordVisible = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    passwordVisible = true;

    super.initState();
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
                      const EdgeInsets.symmetric(horizontal: 45, vertical: 40),
                  child: Form(
                    key: formKey,
                    // ignore: prefer_const_constructors
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
                              letterSpacing: 1.5),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 20,
                          child: Text(
                            'Join now to make fast payments',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                                letterSpacing: 1.2),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Image.asset('assets/images/applogo.jpg'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Email',
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.grey[700]),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.green,
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {});
                          },
                          validator: (val) {
                            return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(val!)
                                ? null
                                : "please enter a valid email";
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: nameController,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Full Name',
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.grey[700]),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.green,
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {});
                          },
                          validator: (val) {
                            if (val!.isNotEmpty) {
                              return null;
                            } else {
                              return "Full name cannot be empty";
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: passwordVisible,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.grey[700]),
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
                              return 'password must be at least 6 characters';
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {},
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: passwordVisible,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Confirm Password',
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 15, color: Colors.grey[700]),
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
                            if (_isPasswordMatch()) {
                              return null;
                            } else {
                              return 'password mismatch';
                            }
                          },
                          onChanged: (val) {},
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  // ignore: deprecated_member_use
                                  backgroundColor: Colors.green,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  )),
                              child: Text(
                                'Register',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500),
                              ),
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    UserCredential userCredential = await auth
                                        .createUserWithEmailAndPassword(
                                            email: emailController.text,
                                            password: passwordController.text);

                                    // ignore: await_only_futures

                                    user = userCredential.user;
                                    await user!
                                        .updateDisplayName(nameController.text);
                                    await user!.reload();
                                    user = auth.currentUser;

                                    await FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(userCredential.user?.email)
                                        .set({
                                      'blocked': isBlocked,
                                      'userType': 'user',
                                      'name': nameController.text,
                                      'dateOfBirth': datOfBirthController.text,
                                      'gender': genderController.text,
                                      'phoneNumber': phoneNumberController.text,
                                      'country': countryController.text,
                                      'state': stateController.text,
                                      'address': addressController.text,
                                      'email': emailController.text,
                                      'accountNumber': accountNumber,
                                      'bankName': 'Universal App',
                                      'accountBalance': {
                                        'usd': usdBalance,
                                        'eur': eurBalance,
                                        'gbp': gbpBalance,
                                      },
                                      'timestamp': DateTime.now()
                                    });

                                    if (context.mounted) {
                                      nextScreenReplace(
                                          context, const EmailVerifyLink());
                                    }

                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } catch (e) {
                                    if (e == 'error') {}

                                    (e);
                                    // ignore: use_build_context_synchronously
                                    snackBar(context, Colors.red, e);

                                    () async {
                                      if (formKey.currentState!.validate()) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        try {
                                          if (context.mounted) {
                                            nextScreenReplace(context,
                                                const EmailVerifyLink());
                                          }
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        } catch (e) {
                                          if (e == 'error') {
                                            (e);
                                            // ignore: use_build_context_synchronously
                                            snackBar(context, Colors.red, e);
                                          }

                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      }
                                    };
                                  }
                                }
                              }),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text.rich(
                          TextSpan(
                              text: "Alredy have an account? ",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'poppins',
                                  fontSize: 15),
                              children: <TextSpan>[
                                TextSpan(
                                    text: "Login here",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.black,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        nextScreenReplace(
                                            context, const LoginPage());
                                      }),
                              ]),
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

class AccountNumberGenerator {
  static final Random _random = Random();
  static const String _usedNumbersFilePath = 'used_account_numbers.txt';

  // A set to store generated account numbers for uniqueness check
  static final Set<String> _usedAccountNumbers = _loadUsedNumbers();

  // Function to generate a random 10-digit account number
  static String generateAccountNumber() {
    String accountNumber;
    do {
      // Generate a random 10-digit number as a string
      accountNumber = _generateRandomNumber(10);
    } while (
        _usedAccountNumbers.contains(accountNumber)); // Check for uniqueness

    // Add the generated account number to the set and save to file
    _usedAccountNumbers.add(accountNumber);
    _saveUsedNumbers();

    return accountNumber;
  }

  // Helper function to generate a random number of a specific length
  static String _generateRandomNumber(int length) {
    String number = '';
    for (int i = 0; i < length; i++) {
      number += _random.nextInt(10).toString();
    }
    return number;
  }

  // Load used account numbers from a file
  static Set<String> _loadUsedNumbers() {
    try {
      final file = File(_usedNumbersFilePath);
      if (file.existsSync()) {
        final lines = file.readAsLinesSync();
        return lines.toSet();
      }
    } catch (e) {
      ('Error loading used account numbers: $e');
    }
    return <String>{};
  }

  // Save used account numbers to a file
  static void _saveUsedNumbers() {
    try {
      final file = File(_usedNumbersFilePath);
      file.writeAsStringSync(_usedAccountNumbers.join('\n'));
    } catch (e) {
      ('Error saving used account numbers: $e');
    }
  }
}
