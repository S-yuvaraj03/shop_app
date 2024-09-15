import 'package:flutter/material.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/screens/product_maintenance_screen.dart';

class InventoryScreen extends StatelessWidget {
  final Shop shop;

  InventoryScreen({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory of ${shop.shopename}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductMaintenanceScreen(shopId: shop.shopid),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: shop.products.length,
        itemBuilder: (context, index) {
          final product = shop.products[index];
          return ListTile(
            title: Text(product.product_name),
            subtitle: Text('Quantity: ${product.product_quantity}, Price: ${product.product_price}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductMaintenanceScreen(shopId: shop.shopid, product: product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
