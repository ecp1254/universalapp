import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileElevatedButton extends StatelessWidget {
  const ProfileElevatedButton(
      {super.key, required this.text, required this.onPressed});
  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.green),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 17, color: Colors.grey[900], letterSpacing: 1),
        ),
      ),
    );
  }
}
