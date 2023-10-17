import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';

import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/cards.dart';
import 'package:one_payment/utilities/elevated_button.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: GestureDetector(
            onTap: () {
              nextScreenReplace(context, const MyCards());
            },
            child: const Icon(Icons.arrow_back_ios_new)),
        automaticallyImplyLeading: false,
        title: Text(
          'Add Card',
          style: GoogleFonts.poppins(
              fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SafeArea(
          child: Column(
        children: [
          CreditCardWidget(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            obscureCardCvv: true,
            obscureCardNumber: true,
            onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
            customCardTypeIcons: <CustomCardTypeIcon>[
              CustomCardTypeIcon(
                cardType: CardType.visa,
                cardImage: Image.asset(
                  'assets/images/visa.png',
                  height: 48,
                  width: 48,
                ),
              ),
              CustomCardTypeIcon(
                cardType: CardType.mastercard,
                cardImage: Image.asset(
                  'assets/images/mastercard.png.png',
                  height: 48,
                  width: 48,
                ),
              ),
            ],
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                CreditCardForm(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  onCreditCardModelChange: onCreditCardModelChange,
                  themeColor: Colors.blue,
                  formKey: formKey,
                  cardNumberDecoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Number',
                      hintText: '**** **** **** ****'),
                  expiryDateDecoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Expiry Date',
                      hintText: '**/**'),
                  cvvCodeDecoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'CVV',
                      hintText: '***'),
                  cardHolderDecoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Card Holder',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButtonPage(
                  text: 'Validate',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                    } else {}
                  },
                ),
              ],
            ),
          ))
        ],
      )),
    );
  }

  showValidDialog(
    BuildContext context,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Valid",
          ),
          content: const Text("Your card successfully valid !!!"),
          actions: [
            TextButton(
                child: const Text(
                  "Ok",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
