import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const TextBox(
      {super.key,
      required this.text,
      required this.sectionName,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionName,
                style:
                    GoogleFonts.montaga(color: Colors.grey[800], fontSize: 16),
              ),
              IconButton(onPressed: onPressed, icon: const Icon(Icons.edit))
            ],
          ),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 20),
          )
        ],
      ),
    );
  }
}
