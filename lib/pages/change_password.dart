import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/home_page_profile.dart';
import 'package:one_payment/pages/user_management_page.dart';
import 'package:one_payment/utilities/elevated_button.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({
    super.key,
  });

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final oldPassworldController = TextEditingController();
  final newPasswordController = TextEditingController();

  var auth = FirebaseAuth.instanceFor;
  var currentUser = FirebaseAuth.instance.currentUser;
  changePassword(email, oldPassword, newPassword) async {
    var credentials =
        EmailAuthProvider.credential(email: email, password: oldPassword);

    await currentUser!.reauthenticateWithCredential(credentials).then((value) {
      currentUser!.updatePassword(newPassword);
    }).catchError((error) {
      error.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: GestureDetector(
            child: const Icon(Icons.arrow_back_ios_new),
            onTap: () {
              nextScreenReplace(context, const UserManagementPage());
            },
          ),
          automaticallyImplyLeading: false,
          title: Text(
            'Change Password',
            style: GoogleFonts.poppins(
                fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MyFormField(
                    data: 'Old Password',
                    icon: Icons.password,
                    textFieldController: oldPassworldController,
                    onTap: () {}),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MyFormField(
                    data: 'New Password',
                    icon: Icons.password,
                    textFieldController: newPasswordController,
                    onTap: () {}),
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButtonPage(
                  text: 'Change Password',
                  onPressed: () async {
                    await changePassword(
                        currentUser!.email,
                        oldPassworldController.text,
                        newPasswordController.text);
                    // ignore: use_build_context_synchronously
                    nextScreenReplace(context, const UserManagementPage());
                  })
            ],
          ),
        )),
      ),
    );
  }
}
