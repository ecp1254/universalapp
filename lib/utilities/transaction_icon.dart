// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionIcons extends StatelessWidget {
  final String imageData;
  final String text1;
  final String text2;

  const TransactionIcons({
    Key? key,
    required this.imageData,
    required this.text1,
    required this.text2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 20,
                              spreadRadius: -3)
                        ]),
                    height: 60,
                    child: Image(
                      image: AssetImage(imageData),
                      color: Color.fromARGB(255, 10, 124, 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text1,
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.green),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          text2,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.green,
              )
            ],
          )
        ],
      ),
    );
  }
}
