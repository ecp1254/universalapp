import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/login_page.dart';

import 'package:one_payment/utilities/elevated_button.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isEmailSent = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                          onTap: () {
                            nextScreenReplace(context, const LoginPage());
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.green,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Forgot Password',
                        style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                            letterSpacing: 1.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Enter the email associated with your account and will we send you a link.',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        letterSpacing: 0.7),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Email',
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.green,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Colors.green,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.green, width: 3)),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email addres';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButtonPage(
                  text: 'Send Rest Link',
                  onPressed: resetPassword,
                ),
                if (isEmailSent)
                  Text(
                    'passsword reset link sent to ${emailController.text}',
                    style: GoogleFonts.montserrat(
                        color: const Color.fromARGB(255, 7, 125, 11),
                        fontSize: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetPassword() async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text);
        setState(() {
          isEmailSent = true;
        });
      } catch (e) {
        (e);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Wrong Email Address',
              style: GoogleFonts.montserrat(color: Colors.red, fontSize: 20),
            ),
          ),
        );
      }
    }
  }
}
