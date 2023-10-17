import 'package:flutter/material.dart';
import 'package:one_payment/pages/cards.dart';
import 'package:one_payment/pages/homepage.dart';
import 'package:one_payment/pages/loans.dart';
import 'package:one_payment/pages/user_management_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.money,
              ),
              label: 'Loans'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.credit_card,
              ),
              label: 'Cards'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_box,
            ),
            label: 'Account',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[800],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  final pages = [
    const HomePage(),
    const LoansPage(),
    const MyCards(),
    const UserManagementPage(),
  ];
}
