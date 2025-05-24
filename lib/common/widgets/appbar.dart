import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../features/shop/screens/profilepage/profile.dart';
import '../../utils/constant/sizes.dart';

class GshopAppbar extends StatelessWidget implements PreferredSizeWidget {
  GshopAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    double kwidth = MediaQuery.of(context).size.width;
    double kheight = MediaQuery.of(context).size.height;
    final User? user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading:  IconButton(
                icon: Icon(Icons.menu, size: TSizes.iconLg, color: Colors.grey),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                }),
          
          leadingWidth: kwidth*0.15,
          title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    "assets/images/googlelogo.png",
                    fit: BoxFit.fitWidth,
                    height: kheight*0.025,
                    width: kwidth*0.16,
                  ),
                  Text(
                    ' Sales Hub',
                    style: TextStyle(color: Colors.grey, fontSize: TSizes.fontLg),
                  ),
                ],
              ),
          // centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: user?.photoURL != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user!.photoURL!),
                      minRadius: TSizes.iconMd,
                      maxRadius: TSizes.Lg,
                    )
                  : CircleAvatar(
                      child: Icon(Icons.person),
                      minRadius: 16,
                      maxRadius: 18,
                    ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileDisplayPage()));
                // Navigate to the profile screen
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextButton(
            onPressed: () {
              // Handle search icon
              Navigator.pushReplacementNamed(
                  context, '/Search'); // Add your button action here
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Text(
                    "Have a Great Day",
                    style:
                        TextStyle(color: Colors.grey, fontSize: TSizes.fontMd),
                  ),
                ),
                Icon(Icons.mic, color: Colors.grey),
              ],
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(50.0), // Adjust as desired
                    side: BorderSide(
                      color: Colors.grey,
                    )),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(120);
}
