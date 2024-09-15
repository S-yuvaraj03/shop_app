import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/screens/add_shop_screen.dart';
import 'package:shop_app/screens/authenticate_screen.dart';
import 'package:shop_app/screens/inventory_screen.dart';
// import 'package:shop_app/screens/inventory_screen.dart';
import 'package:shop_app/screens/shop_profile_screen.dart';
import 'package:shop_app/services/auth_service.dart';
import 'package:shop_app/services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final userEmail = authService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('My Shops'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddShopScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthenticateScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Shop>>(
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
              return ListTile(
                title: Text(shop.shopename),
                subtitle: Text(shop.shopaddress),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddShopScreen(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await firestoreService.deleteShop(shop.shopid);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InventoryScreen(shop: shop),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
