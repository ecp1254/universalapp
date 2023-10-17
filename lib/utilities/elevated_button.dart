import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ElevatedButtonPage extends StatefulWidget {
  final String text;
  final Function() onPressed;

  const ElevatedButtonPage(
      {Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  State<ElevatedButtonPage> createState() => _ElevatedButtonPageState();
}

class _ElevatedButtonPageState extends State<ElevatedButtonPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: widget.onPressed,
          child: Text(
            widget.text,
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
