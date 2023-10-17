// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:one_payment/pages/add_money.dart';
import 'package:one_payment/pages/exchange_money.dart';
import 'package:one_payment/pages/home_page_profile.dart';
import 'package:one_payment/pages/notification.dart';
import 'package:one_payment/pages/transaction_history.dart';
import 'package:one_payment/pages/transaction_summary.dart';
import 'package:one_payment/pages/transfer_money.dart';
import 'package:one_payment/utilities/buttons.dart';
import 'package:one_payment/utilities/currency_options.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';
import 'package:one_payment/utilities/transaction_icon.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double? accountBalance;
  User? user;
  String? _imageUrl;

  // ignore: unused_field
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final PushNotificationService _pushNotificationService =
      PushNotificationService();

  Future<void> _fetchUserProfile() async {
    final email = auth.currentUser!.email;
    final userDoc = await _firestore.collection('user').doc(email).get();
    final userData = userDoc.data();
    final imageUrl = userData?['image_url'];
    setState(() {
      _imageUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    _pushNotificationService.initialize();

    if (user != null) {
      _fetchUserProfile();
      controller = PageController();
    }
  }

  Currency? selectedCurrency;
  double amount = 0.0;
  String formatCurrency(double amount) {
    return '${selectedCurrency?.symbol}$amount';
  }

  List<String> imagePaths = [];
  double currentPage = 0;
  var controller = PageController();
  final CollectionReference backgroundImagesCollection =
      FirebaseFirestore.instance.collection('backGroundImage');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user')
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData =
                  (snapshot.data?.data() as Map<String, dynamic>?) ?? {};

              // ignore: unused_local_variable
              List<String> imagePaths = ((snapshot.data?.data()
                              as Map<String, dynamic>?)?['backgroundImages']
                          as List<dynamic>?)
                      ?.map<String>((dynamic image) => image as String)
                      .toList() ??
                  [];

              return SafeArea(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      nextScreen(
                                          context, const HomePageProfile());
                                    },
                                    child: Stack(
                                      children: [
                                        if (_imageUrl != null)
                                          CircleAvatar(
                                            radius: 20.0,
                                            backgroundImage:
                                                NetworkImage(_imageUrl!),
                                          )
                                        else
                                          const CircleAvatar(
                                            radius: 15.0,
                                            backgroundImage: NetworkImage(
                                                'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  'Hi',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: ClipRect(
                                  child: Text(
                                    userData['name'],
                                    style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  nextScreenReplace(
                                      context, const NotificationsPage());
                                },
                                child: const Icon(
                                  Icons.notifications,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Account Balance',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<Currency>(
                                  value: selectedCurrency,
                                  items: currencies.map((Currency currency) {
                                    return DropdownMenuItem<Currency>(
                                      value: currency,
                                      child: Row(
                                        children: [
                                          Text(
                                            getBalanceText(
                                                userData['accountBalance'],
                                                currency),
                                            style: GoogleFonts.poppins(
                                                fontSize: 22),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Currency? newValue) {
                                    setState(() {
                                      selectedCurrency = newValue!;
                                    });
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: SizedBox(
                        height: 255,
                        child: BackgroundImageSlider(
                          collectionReference: backgroundImagesCollection,
                          controller: controller,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: backgroundImagesCollection.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          List<String> imagePaths = snapshot.data!.docs
                              .map((doc) => doc['image'] as String)
                              .toList();
                          return SmoothPageIndicator(
                            axisDirection: Axis.horizontal,
                            controller: controller,
                            count: imagePaths.length,
                            effect: const ScrollingDotsEffect(
                              activeDotScale: 1.4,
                              activeDotColor: Colors.green,
                              dotColor: Colors.blueGrey,
                              dotHeight: 10,
                              dotWidth: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            nextScreenReplace(context, const AddMoney());
                          },
                          child: const Buttons(
                            iconImage: 'assets/images/add money.png',
                            iconText: 'Add',
                            iconText2: 'Money',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            nextScreenReplace(
                                context, const TransferMoneyPage());
                          },
                          child: const Buttons(
                            iconImage: 'assets/images/send payment.png',
                            iconText: 'Transfer',
                            iconText2: 'Money',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            nextScreenReplace(
                                context, const ExchangeMoneyPage());
                          },
                          child: const Buttons(
                            iconImage: 'assets/images/exchange.png',
                            iconText: 'Exchange',
                            iconText2: 'Money',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        nextScreenReplace(
                            context, const TransactionSummaryPage());
                      },
                      child: const TransactionIcons(
                        imageData: 'assets/images/statistics.png',
                        text1: 'Account Summary',
                        text2: 'Breakdown Of All Transactions',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        nextScreenReplace(
                            context, const TransactionHistoryPage());
                      },
                      child: const TransactionIcons(
                        imageData: 'assets/images/transactions.png',
                        text1: 'Transaction',
                        text2: 'History',
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class BackgroundImageSlider extends StatelessWidget {
  final CollectionReference collectionReference;
  final PageController controller;

  const BackgroundImageSlider({
    required this.collectionReference,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: collectionReference.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        List<String> imagePaths =
            snapshot.data!.docs.map((doc) => doc['image'] as String).toList();
        return PageView.builder(
          controller: controller,
          scrollDirection: Axis.horizontal,
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            return Background(imageData: imagePaths[index]);
          },
        );
      },
    );
  }
}

String getBalanceText(Map<String, dynamic>? accountBalance, Currency currency) {
  if (accountBalance != null) {
    switch (currency.code) {
      case 'USD':
        return '\$ ${accountBalance['usd'].toStringAsFixed(2)}';
      case 'EUR':
        return '€ ${accountBalance['eur'].toStringAsFixed(2)}';
      case 'GBP':
        return '£ ${accountBalance['gbp'].toStringAsFixed(2)}';
      default:
        return '';
    }
  }
  return '';
}

class Background extends StatelessWidget {
  final String imageData;

  const Background({required this.imageData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageData),
        ),
      ),
    );
  }
}
