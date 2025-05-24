import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/product.dart'; // Import the Product model
import 'package:shop_app/services/firestore_service.dart';

class ProductArchivePage extends StatelessWidget {
  final String shopId; // Add a constructor parameter for shopId

  // Constructor to accept shopId
  ProductArchivePage({required this.shopId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    // Clean up expired archived products when loading the page
    firestoreService.deleteExpiredArchivedProducts();

    return Scaffold(
      appBar: AppBar(title: Text('Archived Products')),
      body: StreamBuilder<List<Product>>(
        // Pass the shopId to the getArchivedProducts method
        stream: firestoreService.getArchivedProducts(shopId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final archivedProducts = snapshot.data ?? [];

          if (archivedProducts.isEmpty) {
            return Center(child: Text('No archived products available.'));
          }

          return ListView.builder(
            itemCount: archivedProducts.length,
            itemBuilder: (context, index) {
              final product = archivedProducts[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(product.product_name),
                  subtitle: Text('Price: ${product.product_price}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      // Cancel archive (restore product)
                      await firestoreService.cancelArchiveProduct(product.product_id, shopId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.product_name} restored.'),
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
