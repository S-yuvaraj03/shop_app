import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TDeviceUtils {
  late BuildContext context;
  TDeviceUtils({
    required this.context,
  }) {
    context = this.context;
  }
  void hidekeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static Future<void> setStatusBarColor(Color color) async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  static bool isLandScapeOrientation(BuildContext context) {
    final viewInsets = View.of(context).viewInsets;
    return viewInsets.bottom == 0;
  }

  static bool isPortraitOrientation(BuildContext context) {
    final viewInsets = View.of(context).viewInsets;
    return viewInsets.bottom != 0;
  }

  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
        enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
  }

//modified
  double get getScreenHeight {
    return MediaQuery.of(context).size.height;
  }

  double get getScreenWidth {
    return MediaQuery.of(context).size.width;
  }

  int _syed = 0;
  set setsyed(int val) {
    _syed = val;
  }

  get getsyed => _syed;
}
