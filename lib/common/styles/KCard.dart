import 'package:flutter/material.dart';
import '../../utils/constant/sizes.dart';
import '../screen_size.dart';

// ignore: must_be_immutable
class ShopCard extends StatelessWidget {
  ShopCard(
      {super.key,
      required this.KImage,
      required this.Kcategory,
      required this.Ktitle,
      required this.KText1,
      required this.KText2,
      required this.Konpress,
      required this.Konpress2,
      this.KColor});

  final KImage;
  final String Kcategory;
  final String Ktitle;
  final String KText1;
  String KText2;
  final Function()? Konpress;
  final Function()? Konpress2;
  final KColor;

  @override
  Widget build(BuildContext context) {
    final ss = ScreenSize(context: context);
    double kheight = ss.h;
    double kwidth = ss.w;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: KColor,
        shadowColor: Colors.grey[300],
        clipBehavior: Clip.antiAlias,
        borderOnForeground: true,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          // side: BorderSide( // Adds a visible border around the card
          //   color: Colors.grey.shade400, // You can change this to any color
          //   width: 2.0, // Thickness of the border
          // ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: kheight * 0.2,
                      width: double.infinity,
                      child: Image.network(
                        KImage, // Replace with your image URL
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8.0,
                  left: 8.0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: KText2 == 'Online' ? Colors.blue : Colors.black,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      KText2 == 'Online'
                          ? "SALE IS ON LIVE"
                          : "GO ONLINE TO TAKE ORDER",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: TSizes.fontSm,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      Kcategory,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: TSizes.fontSm,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Ktitle.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: TSizes.fontLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: kwidth * 0.7,
                        child: Text(
                          KText1,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: TSizes.fontSm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: KText2 == 'Online' ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          KText2,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: TSizes.fontMd,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: Konpress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                        ),
                        child: Text(
                          "EDIT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: TSizes.fontSm,
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Spacer between the buttons
                      OutlinedButton(
                        onPressed: Konpress2,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue), // Border color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                        ),
                        child: Text(
                          "DELETE",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: TSizes.fontSm,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
