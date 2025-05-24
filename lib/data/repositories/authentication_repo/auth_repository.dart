// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart' show immutable;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// @immutable
// class AuthRepository {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // Getter to retrieve the current user
//   User? get currentUser {
//     return _firebaseAuth.currentUser;
//   }

//   Future<User?> signIn(String email, String password) async {
//     try {
//       UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
//       return result.user;
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future<User?> register(String email, String password) async {
//     try {
//       UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
//       User? user = result.user;

//       // Automatically set the role as 'seller' for shopkeeper registration
//       if (user != null) {
//         await _db.collection('users').doc(user.uid).set({
//           'uid': user.uid,
//           'email': email,
//           'role': 'seller', // Default role set to 'seller'
//         });
//       }
//       return user;
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future<String?> getUserRole(User user) async {
//     try {
//       DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
//       return doc['role'];
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // Trigger the Google sign in flow
//       final googleUser = await _googleSignIn.signIn();

//       // Check if user cancelled sign in
//       if (googleUser == null) return null;

//       // Get Google authentication credentials
//       final googleAuth = await googleUser.authentication;

//       // Convert Google credentials to Firebase credentials
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Sign in to Firebase with Google credentials
//       return await _firebaseAuth.signInWithCredential(credential);
//     } catch (e) {
//       print('error signing in with google:$e');
//       return null;
//     }
//   }

//   Future<void> singout() async {
//     try{
//     await _googleSignIn.signOut();
//     await _firebaseAuth.signOut();
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Stream<User?> get user {
//     return _firebaseAuth.authStateChanges();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

@immutable
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Getter to retrieve the current user
  User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  // Google Sign-in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google sign-in flow
      final googleUser = await _googleSignIn.signIn();

      // Check if user canceled the sign-in
      if (googleUser == null) return null;

      // Get Google authentication credentials
      final googleAuth = await googleUser.authentication;

      // Convert Google credentials to Firebase credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;

      // Automatically set the role as 'seller' for new users
      if (user != null) {
        final userDoc = await _db.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _db.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'role': 'seller',  // Default role set to 'seller'
          });
        }
      }
      return userCredential;
    } catch (e) {
      print('error signing in with google: $e');
      return null;
    }
  }

  // Fetch the user role
  Future<String?> getUserRole(User user) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
      return doc['role'];
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Google Sign-out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  // Stream for Firebase authentication state
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }
}
