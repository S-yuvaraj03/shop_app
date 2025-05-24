import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/models/product.dart'; // Import the Product model
import 'package:shop_app/services/firestore_service.dart';

class ShopArchievepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    // Clean up expired archived shops when loading the page
    firestoreService.deleteExpiredArchivedShops();

    return Scaffold(
      appBar: AppBar(title: Text('Archived Shops and Products')),
      body: StreamBuilder<List<Shop>>(
        stream: firestoreService.getArchivedShops(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final archivedShops = snapshot.data ?? [];

          if (archivedShops.isEmpty) {
            return Center(child: Text('No archived shops available.'));
          }

          return ListView.builder(
            itemCount: archivedShops.length,
            itemBuilder: (context, index) {
              final shop = archivedShops[index];
              final shopName = shop.shopename ?? 'Unnamed Shop';
              final products = shop.products ?? []; // List of archived products

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(shopName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...products.map((product) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('Product: ${product.product_name}'),
                        );
                      }).toList(),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      // Cancel archive (restore shop and products)
                      await firestoreService.cancelArchiveShop(shop.shopid);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$shopName restored.'),
                        ),
                      );
                    },
                    child: Text('Cancel Archive'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
