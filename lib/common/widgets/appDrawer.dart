import 'package:flutter/material.dart';

import '../../features/shop/screens/Geminiai_Chat/AiChatscreen.dart';
import '../../utils/constant/sizes.dart';


class Appdrawer extends StatelessWidget {
  const Appdrawer({super.key});

  @override
  Widget build(BuildContext context) {
    double kheight = MediaQuery.of(context).size.height;
    double kwidth = MediaQuery.of(context).size.width;
    return Drawer(
      width: kwidth*0.7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: ListView(
        // Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: kheight*0.15,
            child: DrawerHeader(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  "assets/images/googlelogo.png",
                  height: kheight*0.055,
                  width: kwidth*0.2,
                ),
                Text(
                  ' Sales Hub',
                  style: TextStyle(color: Colors.grey, fontSize: TSizes.fontLg),
                ),
              ],
            ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: const Text('Help'),
            onTap: () {
              // Update the state of the app.
              // ...
              
            },
          ),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: const Text('Support'),
            onTap: () {
              // Update the state of the app.
              // ...
              
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              // Update the state of the app.
              // ...
              
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: const Text('settings'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          // Divider(
          //   color: Colors.grey[500],
          // ),
          ListTile(
            leading: Image.asset(
              "assets/images/google-gemini-icon.png",
              fit: BoxFit.fitHeight,
              height: TSizes.iconLg,
            ),
            title: const Text('Gemini-AI'),
            subtitle: const Text('(Chat with Gemini)'),
            onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AichatScreen()));
          },
          ),
        ],
      ),
    );
  }
}