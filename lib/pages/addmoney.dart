import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one_payment/pages/add_card.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddMoneyPageState createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  Currency? selectedCurrency;
  double amount = 0.0;

  void addMoney() {
    if (selectedCurrency != null) {
      // Update the account balance for the selected currency

      if (selectedCurrency!.code == 'USD') {
        updateAccountBalance('USD', amount);
      } else if (selectedCurrency!.code == 'EUR') {
        updateAccountBalance('EUR', amount);
      } else if (selectedCurrency!.code == 'GBP') {
        updateAccountBalance('GBP', amount);
      }
    }
  }

  void updateAccountBalance(String currencyCode, double amount) {
    // Replace this with your actual implementation to update the account balance
    // for the selected currency in your database or API
    // You can use Firestore, HTTP requests, or any other method to update the balance

    // Example implementation with Firestore:
    const email = User; // Replace with the actual user ID
    final firestore = FirebaseFirestore.instance;

    firestore
        .collection('user')
        .doc(email as String?)
        .collection('accountBalance')
        .doc(currencyCode)
        .update({'accountBalance': FieldValue.increment(amount)});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chose Currency'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Currency:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Currency>(
                value: selectedCurrency,
                items: [
                  DropdownMenuItem<Currency>(
                    value: Currency(code: 'USD', name: 'US Dollar'),
                    child: const Text('US Dollar'),
                  ),
                  DropdownMenuItem<Currency>(
                    value: Currency(code: 'EUR', name: 'Euro'),
                    child: const Text('Euro'),
                  ),
                  DropdownMenuItem<Currency>(
                    value: Currency(code: 'GBP', name: 'British Pound'),
                    child: const Text('British Pound'),
                  ),
                ],
                onChanged: (Currency? newValue) {
                  setState(() {
                    selectedCurrency = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  addMoney();
                  nextScreenReplace(context, const AddCardPage());
                },
                child: const Text('Add Money'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Currency {
  final String code;
  final String name;

  Currency({
    required this.code,
    required this.name,
  });

  get symbol => null;
}
