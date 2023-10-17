import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMoneyWidgets extends StatelessWidget {
  final String imageData;
  final String text1;
  final String text2;

  const AddMoneyWidgets(
      {Key? key,
      required this.imageData,
      required this.text1,
      required this.text2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 60,
            height: 60,
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
            child: Image(
              image: AssetImage(
                imageData,
              ),
              color: const Color.fromARGB(255, 14, 137, 18),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(
                text1,
                style:
                    GoogleFonts.poppins(fontSize: 20, color: Colors.grey[800]),
              ),
            ),
            const SizedBox(
              height: 5,
            ),

            Text(
              text2,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[800]),
            ),
            // ignore: prefer_const_constructors
          ],
        ),
      ],
    );
  }
}
