// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shop_app/screens/home_screen.dart';
// // import 'package:shop_app/services/auth_service.dart';

// // class RegisterScreen extends StatefulWidget {
// //   @override
// //   _RegisterScreenState createState() => _RegisterScreenState();
// // }

// // class _RegisterScreenState extends State<RegisterScreen> {
// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   final _formKey = GlobalKey<FormState>();

// //   void _register() async {
// //     if (_formKey.currentState!.validate()) {
// //       final authService = Provider.of<AuthService>(context, listen: false);
// //       User? user = await authService.register(_emailController.text, _passwordController.text);
// //       if (user != null) {
// //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed')));
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Register')),
// //       body: Form(
// //         key: _formKey,
// //         child: Padding(
// //           padding: EdgeInsets.all(16.0),
// //           child: Column(
// //             children: [
// //               TextFormField(
// //                 controller: _emailController,
// //                 decoration: InputDecoration(labelText: 'Email'),
// //                 validator: (value) => value!.isEmpty ? 'Enter an email' : null,
// //               ),
// //               TextFormField(
// //                 controller: _passwordController,
// //                 decoration: InputDecoration(labelText: 'Password'),
// //                 obscureText: true,
// //                 validator: (value) => value!.isEmpty ? 'Enter a password' : null,
// //               ),
// //               SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: _register,
// //                 child: Text('Register'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shop_app/Custom/YButton.dart';
// import 'package:shop_app/screens/authenticate_screen.dart';
// import 'package:shop_app/screens/home_screen.dart';
// import '../data/repositories/authentication_repo/auth_repository.dart';

// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   void _register() async {
//     if (_formKey.currentState!.validate()) {
//       final authService = Provider.of<AuthRepository>(context, listen: false);
//       User? user = await authService.register(
//           _emailController.text, _passwordController.text);
//       if (user != null) {
//         _navigateToHome(user);
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Registration failed')));
//       }
//     }
//   }

//   void _navigateToHome(User user) async {
//     final authService = Provider.of<AuthRepository>(context, listen: false);
//     String? role = await authService.getUserRole(user);

//     if (role == 'seller') {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => HomeScreen()));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Container(
//               height: 450,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: Colors.black,
//                   )),
//               child: Form(
//                 key: _formKey,
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Image.asset(
//                         "assets/images/playstore.png",
//                         height: 50,
//                       ),
//                       Text(
//                         "SignUp",
//                         style: TextStyle(
//                             fontSize: 32, fontWeight: FontWeight.bold),
//                       ),
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: InputDecoration(labelText: 'Email'),
//                         validator: (value) =>
//                             value!.isEmpty ? 'Enter an email' : null,
//                       ),
//                       TextFormField(
//                         controller: _passwordController,
//                         decoration: InputDecoration(labelText: 'Password'),
//                         obscureText: true,
//                         validator: (value) =>
//                             value!.isEmpty ? 'Enter a password' : null,
//                       ),
//                       SizedBox(height: 20),
//                       Ybutton(
//                         Yonpress: _register,
//                         Ytitle: "Sign Up",
//                         Ycolor: Colors.white,
//                         Ywidth: double.infinity,
//                         YTextColor: Colors.blue,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("if you have already have an account use"),
//                           TextButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             AuthenticateScreen()));
//                               },
//                               child: Text(
//                                 "signin",
//                                 style: TextStyle(color: Colors.blue),
//                               ))
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
