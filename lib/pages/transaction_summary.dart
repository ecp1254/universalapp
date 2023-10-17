import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class TransactionSummaryPage extends StatefulWidget {
  const TransactionSummaryPage({Key? key}) : super(key: key);

  @override
  State<TransactionSummaryPage> createState() => _TransactionSummaryPageState();
}

class _TransactionSummaryPageState extends State<TransactionSummaryPage> {
  bool showCurrencyExchangeDetails = true;
  bool showTransferMoneyDetails = true;
  bool showcardDebitDetails = true;
  bool showDepositDetails = true;

  final currentUser = FirebaseAuth.instance.currentUser!;

  DateTime? fromDate;
  DateTime? toDate;

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
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

  late List<Transaction> filteredTransactions;
  CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');
  String selectedFilter = 'All';
  bool isAscending = true;

  List<Transaction> applyFilterAndSort(List<Transaction> transactions) {
    // Apply sorting
    transactions.sort((a, b) {
      if (isAscending) {
        return a.transactionId.compareTo(b.transactionId);
      } else {
        return b.transactionId.compareTo(a.transactionId);
      }
    });

    // Apply date filter
    if (fromDate != null && toDate != null) {
      transactions = transactions.where((transaction) {
        DateTime transactionDate = transaction.dateTime!.toDate();
        return transactionDate.isAfter(fromDate!) &&
            transactionDate.isBefore(toDate!);
      }).toList();
    }

    // Apply type filter
    if (selectedFilter != 'All') {
      transactions = transactions.where((transaction) {
        return transaction.description == selectedFilter;
      }).toList();
    }

    return transactions;
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

  late List<Transaction> transactionList;

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
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[800],
          ),
        ),
        title: Text(
          'Account Summary',
          style: GoogleFonts.poppins(color: Colors.grey[800]),
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
          transactionList = applyFilterAndSort(transactionList);
          double totalAmountFrom = 0;
          double totalAmountTo = 0;

          for (Transaction transaction in transactionList) {
            totalAmountFrom += transaction.amountFrom ?? 0;
            totalAmountTo += transaction.amountTo ?? 0;
          }
          transactionList = applyFilterAndSort(transactionList);
          double totalMoneyTransfer = 0;

          for (Transaction transaction in transactionList) {
            totalMoneyTransfer += transaction.amount ?? 0;
          }
          transactionList = applyFilterAndSort(transactionList);
          double totalMoneyRecieved = 0;

          for (Transaction transaction in transactionList) {
            totalMoneyRecieved += transaction.amount ?? 0;
          }
          transactionList = applyFilterAndSort(transactionList);
          double totalCardDebit = 0;

          for (Transaction transaction in transactionList) {
            totalCardDebit += transaction.amount ?? 0;
          }

          transactionList.sort((a, b) =>
              b.dateTime!.millisecondsSinceEpoch -
              a.dateTime!.millisecondsSinceEpoch);

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<String>(
                    value: selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text(
                          'All',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Card Debit',
                        child: Text(
                          'Card Debit',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Currency Exchange',
                        child: Text(
                          'Currency Exchange',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Deposit',
                        child: Text(
                          'Deposit',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Money Transfer',
                        child: Text(
                          'Money Transfer',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(isAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward),
                    onPressed: () {
                      setState(() {
                        isAscending = !isAscending;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () => _selectDateRange(context),
                  ),
                ],
              ),
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Exchange From: $totalAmountFrom'),
                      const SizedBox(
                        height: 3,
                      ),
                      Text('Total Exchange To: $totalAmountTo'),
                      const SizedBox(
                        height: 3,
                      ),
                      Text('Total Money Transfer: $totalMoneyTransfer'),
                      const SizedBox(
                        height: 3,
                      ),
                      Text('Total Card Debit: $totalCardDebit'),
                      const SizedBox(
                        height: 3,
                      ),
                      Text('Total Deposite: $totalMoneyRecieved'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: transactionList.length,
                  itemBuilder: (context, index) {
                    Transaction transaction = transactionList[index];
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
      title: Padding(
        padding: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 5),
        child: Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, left: 13, bottom: 13, right: 10),
            child: Column(
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
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailsPage(
              transaction: transaction,
            ),
          ),
        );
      },
    );
  }

  Widget buildCurrencyExchangeDetails(Transaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount From: ${transaction.amountFrom ?? 'N/A'}'),
        Text('Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}'),
        Text('Description: ${transaction.description ?? 'N/A'}'),
      ],
    );
  }

  Widget buildMoneyTransferDetails(Transaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}'),
        Text('Amount: ${transaction.amount ?? 'N/A'}'),
        Text('Description: ${transaction.description ?? 'N/A'}'),
      ],
    );
  }

  Widget buildCardDebitDetails(Transaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount: ${transaction.amount ?? 'N/A'}'),
        Text('Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}'),
        Text('Description: ${transaction.description ?? 'N/A'}'),
      ],
    );
  }

  Widget buildDepositDetails(Transaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}'),
        Text('Amount: ${transaction.amount ?? 'N/A'}'),
        Text('Description: ${transaction.description ?? 'N/A'}'),
      ],
    );
  }
}

class TransactionDetailsPage extends StatelessWidget {
  final Transaction transaction;
  const TransactionDetailsPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Transaction Details',
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
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
      ),
    );
  }

  Widget buildCurrencyExchangeDetails(Transaction transaction) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 70,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Transaction ID: ${transaction.transactionId}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Amount From: ${transaction.amountFrom ?? 'N/A'}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Amount To: ${transaction.amountTo ?? 'N/A'}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 50,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Description: ${transaction.description ?? 'N/A'}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Statue: ${transaction.status}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Currency From: ${transaction.currencyFrom}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Currency To: ${transaction.currencyTo}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMoneyTransferDetails(Transaction transaction) {
    return SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Transaction ID: ${transaction.transactionId}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Bank Name: ${transaction.bankName}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Client Name: ${transaction.clientName}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 50,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Description: ${transaction.description ?? 'N/A'}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Amount: ${transaction.amount ?? 'N/A'}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Status: ${transaction.status}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Account Number: ${transaction.accountNumber ?? 'N/A'}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Narration: ${transaction.narration ?? 'N/A'}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget buildCardDebitDetails(Transaction transaction) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 70,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Transaction ID: ${transaction.transactionId}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Amount: ${transaction.amount ?? 'N/A'}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Card Holder: ${transaction.cardHolderName ?? 'N/A'}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 50,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Description: ${transaction.description ?? 'N/A'}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 45,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Statue: ${transaction.status}',
                  style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDepositDetails(Transaction transaction) {
    return SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Transaction ID: ${transaction.transactionId}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Sender: ${transaction.depositorName}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 50,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Date: ${transaction.dateTime?.toDate().toString() ?? 'N/A'}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Description: ${transaction.description ?? 'N/A'}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Amount: ${transaction.amount ?? 'N/A'}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 70,
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Narration: ${transaction.narration ?? 'N/A'}',
                style: GoogleFonts.poppins(letterSpacing: 0.6, fontSize: 15),
              ),
            ),
          ),
        ),
      ]),
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
