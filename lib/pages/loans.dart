import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GestureDetector(
                        onTap: () {
                          nextScreen(context, const BottomNavBar());
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.green,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 20),
                    child: Text(
                      'Loans',
                      style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                          letterSpacing: 1.5),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue[300]),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              left: 16,
                              child: Text(
                                'Outstanding',
                                style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.3),
                              ),
                            ),
                            Positioned(
                              top: 50,
                              left: 16,
                              child: Text(
                                'Loan',
                                style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.3),
                              ),
                            ),
                            Positioned(
                              top: 90,
                              left: 16,
                              child: Text(
                                NumberFormat.simpleCurrency(
                                        locale: 'en-ng', decimalDigits: 2)
                                    .format(000),
                                style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.0),
                              ),
                            ),
                            Positioned(
                              top: 130,
                              left: 16,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'Pay Now',
                                  style: GoogleFonts.poppins(
                                      color: Colors.green,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.teal[300]),
                        width: 150,
                        height: 200,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 22,
                              left: 16,
                              child: Text(
                                'Eligibility',
                                style: GoogleFonts.poppins(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.3),
                              ),
                            ),
                            Positioned(
                              top: 80,
                              left: 16,
                              child: Text(
                                NumberFormat.simpleCurrency(
                                        locale: 'en-ng', decimalDigits: 0)
                                    .format(10000),
                                style: GoogleFonts.poppins(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.0),
                              ),
                            ),
                            Positioned(
                              top: 130,
                              left: 16,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'Borrow Now',
                                  style: GoogleFonts.poppins(
                                      color: Colors.green,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 15, 15),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade50),
                      child: IconButton(
                        color: Colors.green,
                        onPressed: () {},
                        icon: const Icon(Icons.upload),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Upgrade loan limit',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.green),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 15, 15),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade50),
                      child: IconButton(
                        color: Colors.green,
                        onPressed: () {},
                        icon: const Icon(Icons.help_rounded),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Help',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
