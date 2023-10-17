// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final String imageData;

  // ignore: prefer_typing_uninitialized_variables

  const Background({
    Key? key,
    required this.imageData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Image(
              image: AssetImage(imageData),
            ),
          ],
        ),
      ),
    );
  }
}
