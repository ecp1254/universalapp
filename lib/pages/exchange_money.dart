// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/utilities/elevated_button.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';
import 'package:uuid/uuid.dart';

class ExchangeMoneyPage extends StatefulWidget {
  const ExchangeMoneyPage({super.key});

  @override
  State<ExchangeMoneyPage> createState() => _ExchangeMoneyPageState();
}

class _ExchangeMoneyPageState extends State<ExchangeMoneyPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  String? _selectedFromCurrency;
  String? _selectedToCurrency;
  double? _exchangeRate;
  double? _amountToChange;
  double? _changedValue;

  late double usdBalance;
  late double eurBalance;
  late double gbpBalance;

  final List<String> _currencies = ['USD', 'EUR', 'GBP'];

  Future<double> _getExchangeRate(
      String fromCurrency, String toCurrency) async {
    final url =
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rate = data['rates'][toCurrency];
      return rate.toDouble();
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }

  void _updateExchangeRate() {
    if (_selectedFromCurrency != null && _selectedToCurrency != null) {
      _getExchangeRate(_selectedFromCurrency!, _selectedToCurrency!)
          .then((value) {
        setState(() {
          _exchangeRate = value;
          _updateChangedValue();
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load exchange rate',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        );
      });
    }
  }

  Future<void> _fetchAccountBalance() async {
    try {
      final userData = await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.email)
          .get();

      final accountBalance = userData['accountBalance'];
      usdBalance = (accountBalance['usd'] as num?)?.toDouble() ?? 0.0;
      eurBalance = (accountBalance['eur'] as num?)?.toDouble() ?? 0.0;
      gbpBalance = (accountBalance['gbp'] as num?)?.toDouble() ?? 0.0;
    } catch (error) {
      ('Error fetching account balance: $error');
    }
  }

  void _updateChangedValue() {
    if (_amountToChange != null && _exchangeRate != null) {
      if (_selectedFromCurrency != null) {
        double amountToDeduct = _amountToChange!;
        double amountToAdd = _amountToChange! * _exchangeRate!;
        switch (_selectedFromCurrency) {
          case 'USD':
            usdBalance -= amountToDeduct;
            break;
          case 'EUR':
            eurBalance -= amountToDeduct;
            break;
          case 'GBP':
            gbpBalance -= amountToDeduct;
            break;
        }
        switch (_selectedToCurrency) {
          case 'USD':
            usdBalance += amountToAdd;
            break;
          case 'EUR':
            eurBalance += amountToAdd;
            break;
          case 'GBP':
            gbpBalance += amountToAdd;
            break;
        }
        setState(() {
          _changedValue = _amountToChange! * _exchangeRate!;
        });
      }
    }
  }

  Future<void> _saveChangedValue() async {
    if (_changedValue != null) {
      try {
        double accountBalance;
        // ignore: unused_local_variable
        String currency;
        switch (_selectedFromCurrency) {
          case 'USD':
            accountBalance = usdBalance;
            currency = 'usd';
            break;
          case 'EUR':
            accountBalance = eurBalance;
            currency = 'eur';
            break;
          case 'GBP':
            accountBalance = gbpBalance;
            currency = 'gbp';
            break;
          default:
            accountBalance = 0.0;
            currency = '';
        }
        double requestedAmount = _changedValue!;
        if (requestedAmount > accountBalance) {
          // Exchange failed due to insufficient account balance
          throw ('Insufficient account balance');
        }

        // Deduct from the source account
        switch (_selectedFromCurrency) {
          case 'USD':
            usdBalance -= requestedAmount;
            break;
          case 'EUR':
            eurBalance -= requestedAmount;
            break;
          case 'GBP':
            gbpBalance -= requestedAmount;
            break;
        }

        // Add to the destination account
        switch (_selectedToCurrency) {
          case 'USD':
            usdBalance += requestedAmount;
            break;
          case 'EUR':
            eurBalance += requestedAmount;
            break;
          case 'GBP':
            gbpBalance += requestedAmount;
            break;
        }

        // Save the updated balances to Firestore
        await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.email)
            .update({
          'accountBalance.usd': usdBalance,
          'accountBalance.eur': eurBalance,
          'accountBalance.gbp': gbpBalance,
        });

        // Function to generate a unique transaction ID
        String generateTransactionId() {
          var uuid = const Uuid();
          return uuid.v4();
        }

        String transactionId = generateTransactionId();
        // Set the status based on a successful exchange
        String status = 'success';

        // Create a transaction object
        Transaction transaction = Transaction(
          description: 'Currency Exchange',
          transactionId: transactionId,
          dateTime: DateTime.now(),
          currencyFrom: _selectedFromCurrency!,
          currencyTo: _selectedToCurrency!,
          status: status,
          amountFrom: _amountToChange!,
          amountTo: _changedValue!,
        );

        // Add the transaction to the 'transactions' collection
        CollectionReference transactionsCollection =
            FirebaseFirestore.instance.collection('transactions');

        transactionsCollection.add({
          'description': 'Currency Exchange',
          'transactionId': transactionId,
          'dateTime': transaction.dateTime,
          'currencyFrom': transaction.currencyFrom,
          'currencyTo': transaction.currencyTo,
          'status': transaction.status,
          'amountFrom': transaction.amountFrom,
          'amountTo': transaction.amountTo,
          'userEmail': currentUser.email,
        });

        // Save the changed value
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Saved'),
              content: Text('$_changedValue Changed value saved'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        // Set the status based on a failed exchange
        // ignore: unused_local_variable
        String status = 'failed';

        // Display an error message to the user
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Error saving changed value: $error'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle the case when _changedValue is null
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No changed value to save'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                nextScreenReplace(context, const BottomNavBar());
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            backgroundColor: Colors.green,
            title: const Text('Exchange Money'),
          ),
          body: FutureBuilder(
            future: _fetchAccountBalance(),
            builder: (context, snapshot) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (Theme.of(context).platform ==
                              TargetPlatform.android)
                            DropdownButton<String>(
                              value: _selectedFromCurrency,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedFromCurrency = newValue;
                                  _updateExchangeRate();
                                });
                              },
                              items: _currencies.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                            ),
                          if (Theme.of(context).platform == TargetPlatform.iOS)
                            CupertinoPicker(
                              itemExtent: 32.0,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedFromCurrency = _currencies[index];
                                  _updateExchangeRate();
                                });
                              },
                              children: _currencies.map((String currency) {
                                return Text(currency);
                              }).toList(),
                            ),
                          const SizedBox(height: 20),
                          if (Theme.of(context).platform ==
                              TargetPlatform.android)
                            DropdownButton<String>(
                              value: _selectedToCurrency,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedToCurrency = newValue;
                                  _updateExchangeRate();
                                });
                              },
                              items: _currencies.map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                            ),
                          if (Theme.of(context).platform == TargetPlatform.iOS)
                            CupertinoPicker(
                              itemExtent: 32.0,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedToCurrency = _currencies[index];
                                  _updateExchangeRate();
                                });
                              },
                              children: _currencies.map((String currency) {
                                return Text(currency);
                              }).toList(),
                            ),
                          const SizedBox(height: 20),
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _amountToChange = double.tryParse(value);
                                _updateChangedValue();
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Amount To Change',
                              labelStyle: GoogleFonts.poppins(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Click To Show Rate',
                              suffixText: _exchangeRate != null
                                  ? (_amountToChange != null
                                      ? (_amountToChange! * _exchangeRate!)
                                          .toStringAsFixed(2)
                                      : '')
                                  : '',
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButtonPage(
                            text: 'Save Changed Value',
                            onPressed: _saveChangedValue,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class Transaction {
  final String transactionId;
  final DateTime dateTime;
  final String currencyFrom;
  final String currencyTo;
  final String status;
  final double amountFrom;
  final double amountTo;
  final String description;

  Transaction({
    required this.transactionId,
    required this.dateTime,
    required this.currencyFrom,
    required this.currencyTo,
    required this.status,
    required this.amountFrom,
    required this.amountTo,
    required this.description,
  });
}
