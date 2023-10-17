import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Buttons extends StatelessWidget {
  final String iconImage;
  final String iconText;
  final String iconText2;

  const Buttons(
      {Key? key,
      required this.iconImage,
      required this.iconText,
      required this.iconText2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 50,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 20,
                    spreadRadius: -3),
              ],
            ),
            child: Image(
              image: AssetImage(iconImage),
              color: const Color.fromARGB(255, 10, 124, 16),
            ),
          ),
        ),
        Text(
          iconText,
          style: GoogleFonts.poppins(
              letterSpacing: 1,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green),
        ),
        Text(
          iconText2,
          style: GoogleFonts.poppins(
              letterSpacing: 1,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green),
        ),
      ],
    );
  }
}
