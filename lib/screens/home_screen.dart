import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Custom/YButton.dart';
import 'package:shop_app/common/styles/KCard.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/screens/add_shop_screen.dart';
import 'package:shop_app/screens/shop_archievepage.dart';
import 'package:shop_app/screens/authenticate_screen.dart';
import 'package:shop_app/screens/product_analytics.dart';
import 'package:shop_app/screens/shop_profile_screen.dart';
import 'package:shop_app/screens/shopdetailsscreen.dart';
import 'package:shop_app/services/firestore_service.dart';

import '../common/screen_size.dart';
import '../common/widgets/appDrawer.dart';
import '../common/widgets/appbar.dart';
import '../data/repositories/authentication_repo/auth_repository.dart';
import '../features/shop/screens/Geminiai_Chat/AiChatscreen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ss = ScreenSize(context: context);
    double kheight = ss.h;
    double kwidth = ss.w;
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthRepository>(context);
    final userEmail = authService.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GshopAppbar(),
      drawer: Appdrawer(),
      body: Container(
        color: Colors.blue[50],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Ybutton(
                    Yonpress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddShopScreen()),
                      );
                    },
                    Ytitle: 'Add Shop',
                    Ycolor: Colors.white,
                    Ywidth: kwidth * 0.42,
                    YTextColor: Colors.black,
                  ),
                  Ybutton(
                    Ycolor: Colors.white,
                    Yonpress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShopArchievepage()),
                      );
                    },
                    Ytitle: 'Archived',
                    YTextColor: Colors.black,
                    Ywidth: kwidth * 0.42,
                  )
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Shop>>(
                stream: firestoreService.getShopsByOwnerEmail(userEmail),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final shops = snapshot.data ?? [];
                  if (shops.isEmpty) {
                    return Center(child: Text('No shops found for this user.'));
                  }

                  return ListView.builder(
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ShopDetailsScreen(shop: shop,)));
                        },
                        child: ShopCard(
                            KColor: Colors.white,
                            KImage: shop.shopImageUrl.toString(),
                            Kcategory: shop.shopid,
                            Ktitle: shop.shopename,
                            KText1: shop.shopaddress,
                            KText2: shop.isOnline ? 'Online' : 'Offline',
                            Konpress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShopProfileScreen(shop: shop),
                                ),
                              );
                            },
                            Konpress2: () async {
                              // Show a confirmation dialog before archiving
                              bool? confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'Are you sure you want to delete your shop ${shop.shopename}?'),
                                    content: Text(
                                        "Yes to Proceed Delete, cancel for discard"),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Yes, Proceed'),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                        
                              // If the user confirmed, archive the shop
                              if (confirmDelete == true) {
                                await firestoreService.archiveShop(shop.shopid);
                                // Schedule shop deletion after 30 days
                                firestoreService.deleteExpiredArchivedShops();
                        
                                // Show a confirmation message that shop is archived
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Shop Archived'),
                                      content: Text(
                                          '${shop.shopename} has been archived. You can recover it from the archive folder within 30 days.'),
                                      actions: [
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
