import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/screens/authenticate_screen.dart';

import '../../../../utils/constant/sizes.dart';
import 'profileeditpage.dart';

class ProfileDisplayPage extends StatelessWidget {
  const ProfileDisplayPage({super.key});

  Future<Map<String, dynamic>> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('shopkeepers_user_profile')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        debugPrint('Document does not exist for user ID: ${user.uid}');
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    double kwidth = MediaQuery.of(context).size.width;
    double kheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading data"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Navigate to EditProfilePage when no data is found
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  });
                  return const Center(child: CircularProgressIndicator());
                } else {
                  Map<String, dynamic> userData = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: kwidth * 0.155,
                              backgroundColor: Colors.black,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(FirebaseAuth
                                        .instance.currentUser?.photoURL ??
                                    'https://via.placeholder.com/150'),
                                radius: kwidth * 0.15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildGlassmorphismContainer(
                            child: Column(
                              children: [
                                _buildInfoTile('Name   : ', userData['name']),
                                _buildInfoTile('Email  : ', userData['email']),
                                _buildInfoTile('Phone  : ', userData['phone']),
                                _buildInfoTile('Address: ', userData['address']),
                                _buildInfoTile('Gender : ', userData['gender']),
                                _buildInfoTile(
                                    'Age    : ', userData['age'].toString()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage(),
                                ),
                              );
                            },
                            child: const Text("Edit Profile",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  Size(double.infinity, kheight * 0.054),
                              backgroundColor: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Successfully Signed out.')),
                              );
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AuthenticateScreen()));
                            },
                            child: const Text(
                              "Log Out",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  Size(double.infinity, kheight * 0.054),
                              backgroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: BorderSide.strokeAlignOutside),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: TSizes.fontLg,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          Text(
            value,
            style:
                const TextStyle(fontSize: TSizes.fontLg, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
