import 'package:flutter/material.dart';

class ScreenSize {
  late BuildContext context;
  ScreenSize({
    required context,
  }) {
    this.context = context;
  }
  double get h {
    return MediaQuery.of(context).size.height;
  }

  double get w {
    return MediaQuery.of(context).size.width;
  }
}
