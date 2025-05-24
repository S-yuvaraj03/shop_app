import 'package:flutter/material.dart';
import 'package:shop_app/utils/constant/sizes.dart';

class Ybutton extends StatelessWidget {
  Ybutton(
      {super.key,
      required this.Yonpress,
      required this.Ytitle,
      this.Ywidth = double.infinity,
      this.YTextColor,
      required this.Ycolor});

  final Yonpress;
  final Ytitle;
  final double Ywidth;
  final Ycolor;
  final YTextColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: Yonpress,
        child: Text(
          Ytitle,
          style: TextStyle(color: YTextColor, fontSize: TSizes.fontMd),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(Ywidth, 50),
          backgroundColor: Ycolor
        ),
      ),
    );
  }
}
