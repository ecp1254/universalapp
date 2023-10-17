import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/profile_after_register.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class EmailVerifyLink extends StatefulWidget {
  const EmailVerifyLink({Key? key}) : super(key: key);

  @override
  State<EmailVerifyLink> createState() => _EmailVerifyLinkState();
}

class _EmailVerifyLinkState extends State<EmailVerifyLink> {
  final auth = FirebaseAuth.instance;
  late User user;

  @override
  void initState() {
    user = auth.currentUser!;
    user.sendEmailVerification();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to Universal App',
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.grey[800]),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 200,
            width: 200,
            child: Image.asset('assets/images/applogo.jpg'),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'An email has been sent to ${user.email} please verify your email to continue.',
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[800]),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(),
                  ),
                  onPressed: () async {
                    await auth.currentUser!.reload();
                    if (auth.currentUser!.emailVerified) {
                      // ignore: use_build_context_synchronously
                      nextScreenReplace(
                          context, const ProfilesAfterRegistration());
                    } else {
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Email Not Verified',
                              style: GoogleFonts.poppins(),
                            ),
                            content: Text(
                                'Please verify your email to continue.',
                                style: GoogleFonts.poppins()),
                            actions: [
                              ElevatedButton(
                                child: Text('OK', style: GoogleFonts.poppins()),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 15.0),
              TextButton(
                onPressed: () async {
                  // Resend the verification link to the user's email
                  try {
                    await auth.currentUser?.sendEmailVerification();
                    // ignore: use_build_context_synchronously
                    snackBar(
                        context, Colors.green, 'Verification email resent');
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    snackBar(context, Colors.red,
                        'Error resending verification email: $e');
                  }
                },
                child: const Text('Resend Verification Email'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
