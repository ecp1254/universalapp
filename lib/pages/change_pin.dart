import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/home_page_profile.dart';
import 'package:one_payment/pages/user_management_page.dart';
import 'package:one_payment/utilities/elevated_button.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class ChangePin extends StatefulWidget {
  const ChangePin({super.key});

  @override
  State<ChangePin> createState() => _ChangePinState();
}

class _ChangePinState extends State<ChangePin> {
  final oldPinController = TextEditingController();
  final newPinController = TextEditingController();
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
            'Change Pin',
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
                    data: 'Old Pin',
                    icon: Icons.password,
                    textFieldController: oldPinController,
                    onTap: () {}),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MyFormField(
                    data: 'New Pin',
                    icon: Icons.password,
                    textFieldController: newPinController,
                    onTap: () {}),
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButtonPage(text: 'Change Pin', onPressed: () {})
            ],
          ),
        )),
      ),
    );
  }
}
