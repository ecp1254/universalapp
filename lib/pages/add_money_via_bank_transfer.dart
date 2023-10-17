import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/add_money.dart';
import 'package:one_payment/utilities/elevated_button.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class BankTransferAccountTopUp extends StatefulWidget {
  const BankTransferAccountTopUp({super.key});

  @override
  State<BankTransferAccountTopUp> createState() =>
      _BankTransferAccountTopUpState();
}

class _BankTransferAccountTopUpState extends State<BankTransferAccountTopUp> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection('user');

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      user = auth.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user')
                .doc(currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;

                return ListView(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: GestureDetector(
                              onTap: () {
                                nextScreen(context, const AddMoney());
                              },
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.green,
                              )),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 20),
                            child: Text(
                              'Account Details',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                  letterSpacing: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    AddMoneyByBankTransfer(
                        icon: Icons.business,
                        text1: 'Bank Name',
                        text2: userData['bankName']),
                    const SizedBox(
                      height: 10,
                    ),
                    AddMoneyByBankTransfer(
                        icon: Icons.numbers,
                        text1: 'Account Number',
                        text2: userData['accountNumber']),
                    const SizedBox(
                      height: 10,
                    ),
                    AddMoneyByBankTransfer(
                        icon: Icons.person,
                        text1: 'Account Name',
                        text2: userData['name']),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButtonPage(text: 'Share', onPressed: () {})
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('error${snapshot.error}'),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}

class AddMoneyByBankTransfer extends StatelessWidget {
  final IconData icon;
  final String text1;
  final String text2;
  const AddMoneyByBankTransfer({
    Key? key,
    required this.icon,
    required this.text1,
    required this.text2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 20,
                    spreadRadius: -3)
              ],
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 13, 141, 17),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
              child: Text(
                text1,
                style: GoogleFonts.poppins(
                    fontSize: 15, letterSpacing: 1.3, color: Colors.grey[800]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
              child: Text(
                text2,
                style: GoogleFonts.poppins(
                    fontSize: 20, color: Colors.grey[900], letterSpacing: 1.3),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
