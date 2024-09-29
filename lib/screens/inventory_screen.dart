import 'package:flutter/material.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/screens/product_maintenance_screen.dart';

class InventoryScreen extends StatelessWidget {
  final Shop shop;

  InventoryScreen({required this.shop});

  @override
  Widget build(BuildContext context) {
    // Filter the products into added and sold categories
    List<Product> addedProducts =
        shop.products.where((product) => product.totalSold == 0).toList();
    List<Product> soldProducts =
        shop.products.where((product) => product.totalSold > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory of ${shop.shopename}'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductMaintenanceScreen(shopId: shop.shopid),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProductTable(addedProducts, context, shop.shopid),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTable(List<Product> products, BuildContext context, String shopId) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal, // Allows horizontal scrolling
    child: DataTable(
      columns: [
        DataColumn(label: Text('Product Name', overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: true,)),
        DataColumn(label: Text('Total Added')),
        DataColumn(label: Text('Total Sold')),
        DataColumn(label: Text('Quantity')),
        DataColumn(label: Text('Price')),
        DataColumn(label: Text('Profit')),
      ],
      rows: products.map((product) {
        // Calculate total sold
        int totalSold = product.lastlyUpdatedAvailableCount - (product.Available_count ?? 0);
        
        // Ensure product_costprice is defined and the calculation is correct
        double product_profit = totalSold * (product.product_offerprice);

        return DataRow(cells: [
          DataCell(Text(_formatProductName(product.product_name))),
          DataCell(Text('${product.totalAdded}')),
          DataCell(Text('${totalSold}')),
          DataCell(Text('${product.Available_count}')),
          DataCell(Text('\$${product.product_offerprice}')),
          DataCell(Text('\$${product_profit.toStringAsFixed(2)}')), // Formatting profit to 2 decimal places
        ]);
      }).toList(),
    ),
  );
}



  // Utility function to format product name to 3 lines with max 3 words per line
  String _formatProductName(String productName) {
    List<String> words = productName.split(' ');
    List<String> formattedLines = [];

    for (int i = 0; i < words.length; i += 3) {
      String line = words.skip(i).take(3).join(' ');
      formattedLines.add(line);
    }

    return formattedLines
        .take(3)
        .join('\n'); // Join up to 3 lines with new lines
  }
}
