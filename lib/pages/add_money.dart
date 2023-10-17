import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/add_money_via_bank_transfer.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/utilities/add_money_widgets.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class AddMoney extends StatefulWidget {
  const AddMoney({super.key});

  @override
  State<AddMoney> createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      nextScreenReplace(context, const BottomNavBar());
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(75, 20, 0, 20),
                    child: Text(
                      'Add Money',
                      style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.green),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              // ignore: prefer_const_constructors
              GestureDetector(
                child: const AddMoneyWidgets(
                  imageData: 'assets/images/bank-building.png',
                  text1: 'Bank Transfer',
                  text2: 'Add money via mobile banking',
                ),
                onTap: () {
                  nextScreen(context, const BankTransferAccountTopUp());
                },
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {},
                child: const AddMoneyWidgets(
                  imageData: 'assets/images/credit-card(1).png',
                  text1: 'Card Top Up',
                  text2: 'Add funds via your bank cards',
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const AddMoneyWidgets(
                  imageData: 'assets/images/top up.png',
                  text1: 'Bank Account Top Up',
                  text2: 'Add money via your bank account'),
            ],
          ),
        ),
      ),
    );
  }
}
