import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  UserCredential? userCredential;
  DateTime? fromDate;
  DateTime? toDate;

  TextEditingController searchController = TextEditingController();

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: toDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    var querySnapshot =
        await transactions.orderBy('dateTime', descending: true).get();
    transactionList = querySnapshot.docs
        .map((document) => Transaction.fromSnapshot(document))
        .toList();

    transactionList
        .sort((a, b) => b.dateTime!.toDate().compareTo(a.dateTime!.toDate()));

    // Initially, display all transactions
    filteredTransactions = List.from(transactionList);
    setState(() {});
  }

  final currentUser = FirebaseAuth.instance.currentUser!;
  CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');

  late List<Transaction> transactionList;
  late List<Transaction> filteredTransactions;

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Search Transactions',
            style: GoogleFonts.poppins(),
          ),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
                hintText: 'Enter transaction description...',
                hintStyle: GoogleFonts.poppins()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                _applySearch();
                Navigator.pop(context);
              },
              child: Text(
                'Search',
                style: GoogleFonts.poppins(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void _applySearch() {
    String searchTerm = searchController.text.toLowerCase().trim();

    filteredTransactions = transactionList
        .where((transaction) =>
            transaction.description!.toLowerCase().contains(searchTerm))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            nextScreenReplace(context, const BottomNavBar());
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
        title: Text(
          'Transaction History',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: transactions
            .where('userEmail', isEqualTo: currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No transactions found.'),
            );
          }
          List<Transaction> transactionList = snapshot.data!.docs
              .map((DocumentSnapshot document) =>
                  Transaction.fromSnapshot(document))
              .toList();

          List<Transaction> filteredTransactionList = transactionList
              .where((transaction) => transaction.description!
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))
              .toList();
          filteredTransactionList.sort((a, b) =>
              b.dateTime!.millisecondsSinceEpoch -
              a.dateTime!.millisecondsSinceEpoch);

          return Column(
            children: [
              Expanded(
                child: filteredTransactionList.isEmpty
                    ? Center(
                        child: Text(
                          'No transaction found.',
                          style: GoogleFonts.poppins(fontSize: 20),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTransactionList.length,
                        itemBuilder: (context, index) {
                          Transaction transaction =
                              filteredTransactionList[index];
                          return buildTransactionListTile(transaction);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTransactionListTile(Transaction transaction) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (transaction.description == 'Currency Exchange')
            buildCurrencyExchangeDetails(transaction),
          if (transaction.description == 'Money Transfer')
            buildMoneyTransferDetails(transaction),
          if (transaction.description == 'Card Debit')
            buildCardDebitDetails(transaction),
          if (transaction.description == 'Deposit')
            buildDepositDetails(transaction),
        ],
      ),
    );
  }

  Widget buildCurrencyExchangeDetails(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 5),
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 13, bottom: 13, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction ID: ${transaction.transactionId}',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(
                height: 5,
              ),
              Text('Amount From: ${transaction.amountFrom ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Amount To: ${transaction.amountTo ?? 'N/A'}',
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                  'Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text('Description: ${transaction.description ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Status: ${transaction.status}',
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Currency From: ${transaction.currencyFrom}',
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Currency To: ${transaction.currencyTo}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMoneyTransferDetails(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 5),
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 13, bottom: 13, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction ID: ${transaction.transactionId}',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Bank Name: ${transaction.bankName}',
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Client Name: ${transaction.clientName}',
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                  'Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text('Amount: ${transaction.amount ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text('Description: ${transaction.description ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Status: ${transaction.status}',
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Account Number: ${transaction.accountNumber ?? 'N/A'}',
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Narration: ${transaction.narration ?? 'N/A'}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCardDebitDetails(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 5),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 13, bottom: 13, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction ID: ${transaction.transactionId}',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(
                height: 5,
              ),
              Text('Amount: ${transaction.amount ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Card Holder: ${transaction.cardHolderName ?? 'N/A'}',
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                  'Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text('Description: ${transaction.description ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Status: ${transaction.status}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDepositDetails(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 5),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 13, bottom: 13, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction ID: ${transaction.transactionId}',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Sender: ${transaction.depositorName}',
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                  'Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text('Amount: ${transaction.amount ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text('Description: ${transaction.description ?? 'N/A'}'),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Narration: ${transaction.narration ?? 'N/A'}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Transaction {
  final String transactionId;
  final double? amountFrom;
  final double? amountTo;
  final String status;
  final Timestamp? dateTime;
  String? description;
  final String currencyFrom;
  final String currencyTo;
  final double? amount;
  final String bankName;
  final double? accountNumber;
  final String clientName;
  String? narration;
  String? depositorName;
  String? cardHolderName;

  Transaction({
    required this.transactionId,
    required this.amountFrom,
    required this.amountTo,
    required this.status,
    this.dateTime,
    this.description,
    required this.currencyFrom,
    required this.currencyTo,
    required this.accountNumber,
    required this.amount,
    required this.bankName,
    required this.clientName,
    required this.narration,
    required this.depositorName,
    required this.cardHolderName,
  });

  factory Transaction.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    return Transaction(
      transactionId: data?['transactionId'] ?? '',
      amountFrom: data?['amountFrom']?.toDouble(),
      amountTo: data?['amountTo']?.toDouble(),
      status: data?['status'] ?? '',
      dateTime: data?['dateTime'] as Timestamp?,
      description: data?['description'] ?? '',
      currencyFrom: data?['currencyFrom'] ?? '',
      currencyTo: data?['currencyTo'] ?? '',
      accountNumber: data?['accountNumber']?.toDouble(),
      amount: data?['amount']?.toDouble(),
      clientName: data?['clientName'] ?? '',
      bankName: data?['bankName'] ?? '',
      narration: data?['narration'] ?? '',
      depositorName: data?['depositorName'] ?? '',
      cardHolderName: data?['cardHolderName'] ?? '',
    );
  }
}
