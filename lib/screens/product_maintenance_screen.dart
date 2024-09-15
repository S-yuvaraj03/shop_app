import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/screens/home_screen.dart';
import 'package:shop_app/screens/productformscreen.dart';
import 'package:shop_app/services/firestore_service.dart';


class ProductMaintenanceScreen extends StatelessWidget {
  final String shopId;
  final Product? product;

  ProductMaintenanceScreen({required this.shopId, this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Maintenance'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(
                    shopId: shopId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('shops').doc(shopId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final shopData = snapshot.data!.data() as Map<String, dynamic>;
          final products = (shopData['products'] as List)
              .map((item) => Product.fromMap(item))
              .toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.product_name),
                subtitle: Text('Price: ${product.product_price}, Quantity: ${product.product_quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductFormScreen(
                              shopId: shopId,
                              product: product,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                        firestoreService.deleteProduct(shopId, product);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: MaterialButton(
        child: Text("Home Screen"),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
        },
      ),
    );
  }
}



