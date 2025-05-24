// import 'package:flutter/material.dart';

// class TAppTheme {
//   TAppTheme._();

//   static const Color primaryColor = Colors.blue;
//   static const Color accentColor = Colors.red;
//   static const Color textColor = Colors.black;
//   static const Color secondaryTextColor = Colors.grey;
//   static const Color backgroundColor = Colors.white;
//   static const Color buttonColor = Colors.black;
//   static const Color offerColor = Colors.green;
//   static const Color starColor = Colors.yellow;

//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     fontFamily: 'Poppins',
//     brightness: Brightness.light,
//     primaryColor: primaryColor,
//     colorScheme: ColorScheme.light(
//       primary: primaryColor,
//       secondary: accentColor,
//       background: backgroundColor,
//     ),
//     scaffoldBackgroundColor: backgroundColor,
//     appBarTheme: AppBarTheme(
//       backgroundColor: backgroundColor,
//       titleTextStyle: TextStyle(color: textColor, fontSize: 20),
//       iconTheme: IconThemeData(color: textColor),
//     ),
//     textTheme: TextTheme(
//       headlineSmall: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold), // Updated headline6 to headlineSmall
//       bodyMedium: TextStyle(color: secondaryTextColor, fontSize: 16), // Updated bodyText2 to bodyMedium
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: buttonColor, // Updated primary to backgroundColor
//         foregroundColor: backgroundColor, // Updated onPrimary to foregroundColor
//       ),
//     ),
//     checkboxTheme: CheckboxThemeData(
//       fillColor: MaterialStateProperty.all(offerColor),
//     ),
//     chipTheme: ChipThemeData(
//       backgroundColor: backgroundColor,
//       labelStyle: TextStyle(color: textColor),
//     ),
//   );

//   static ThemeData darkTheme = ThemeData(
//     useMaterial3: true,
//     fontFamily: 'Poppins',
//     brightness: Brightness.dark,
//     primaryColor: primaryColor,
//     colorScheme: ColorScheme.dark(
//       primary: primaryColor,
//       secondary: accentColor,
//       background: Colors.black,
//     ),
//     scaffoldBackgroundColor: Colors.black,
//     appBarTheme: AppBarTheme(
//       backgroundColor: Colors.black,
//       titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
//       iconTheme: IconThemeData(color: Colors.white),
//     ),
//     textTheme: TextTheme(
//       headlineSmall: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), // Updated headline6 to headlineSmall
//       bodyMedium: TextStyle(color: Colors.grey[300], fontSize: 16), // Updated bodyText2 to bodyMedium
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.grey[800], // Updated primary to backgroundColor
//         foregroundColor: Colors.white, // Updated onPrimary to foregroundColor
//       ),
//     ),
//     checkboxTheme: CheckboxThemeData(
//       fillColor: WidgetStateProperty.all(Colors.redAccent),
//     ),
//     chipTheme: ChipThemeData(
//       backgroundColor: Colors.grey[800],
//       labelStyle: TextStyle(color: Colors.white),
//     ),
//   );
// }
