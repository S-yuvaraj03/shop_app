import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shop_app/models/product.dart';

class BillingPage extends StatefulWidget {
  final List<Product> allProducts;

  BillingPage({required this.allProducts});

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  List<Product> displayedProducts = [];
  List<Map<String, dynamic>> selectedProducts = []; // Product + Quantity
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    displayedProducts = widget.allProducts;

    // Add a listener to the TextEditingController to handle search updates
    searchController.addListener(() {
      updateSearchQuery(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose(); // Dispose the controller to free resources
    super.dispose();
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      displayedProducts = widget.allProducts
          .where((product) =>
              product.product_name
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              product.product_id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> scanQRCode() async {
    String scannedCode = '';
    try {
      scannedCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );
      if (scannedCode != '-1') {
        searchController.text =
            scannedCode; // Update the search field with scanned code
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning QR code: $e')),
      );
    }
  }

  void addToCart(Product product) {
    setState(() {
      final index = selectedProducts.indexWhere(
        (item) => item['product'].product_id == product.product_id,
      );

      if (index == -1) {
        selectedProducts.add({'product': product, 'quantity': 1});
      }
    });
  }

  void updateQuantity(Product product, int change) {
    setState(() {
      final index = selectedProducts.indexWhere(
        (item) => item['product'].product_id == product.product_id,
      );

      if (index != -1) {
        selectedProducts[index]['quantity'] += change;

        if (selectedProducts[index]['quantity'] <= 0) {
          selectedProducts.removeAt(index);
        }
      }
    });
  }

  double calculateSubtotal() {
    return selectedProducts.fold(
      0,
      (total, item) =>
          total + (item['product'].product_price * item['quantity']),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = calculateSubtotal();
    final double tax = subtotal * 0.05; // Assuming 5% tax
    final double discount = 0; // Implement discounts if applicable
    final double total = subtotal + tax - discount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search Products",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: scanQRCode,
                  ),
                ],
              ),
            ),

            // Expanded area for scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Product List
                    if (displayedProducts.isNotEmpty)
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Available Products",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedProducts.length,
                            itemBuilder: (context, index) {
                              final product = displayedProducts[index];
                              return ListTile(
                                leading: Image.network(
                                  product.imageLink,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(product.product_name),
                                subtitle: Text(
                                    "\$${product.product_price.toStringAsFixed(2)}"),
                                trailing: ElevatedButton(
                                  onPressed: () => addToCart(product),
                                  child: const Text("Add"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                    // Divider
                    const Divider(),

                    // Selected Products
                    if (selectedProducts.isNotEmpty)
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Selected Products",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: selectedProducts.length,
                            itemBuilder: (context, index) {
                              final item = selectedProducts[index];
                              final product = item['product'];
                              final quantity = item['quantity'];

                              return ListTile(
                                leading: Image.network(
                                  product.imageLink,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(product.product_name),
                                subtitle: Text("Quantity: $quantity"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () =>
                                          updateQuantity(product, -1),
                                    ),
                                    Text("$quantity"),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () =>
                                          updateQuantity(product, 1),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                    // Divider
                    const Divider(),

                    // Summary and Payment
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSummaryRow("Subtotal", subtotal),
                          _buildSummaryRow("Tax (5%)", tax),
                          _buildSummaryRow("Discount", discount),
                          const Divider(),
                          _buildSummaryRow("Total", total, isBold: true),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _confirmPayment(total),
                            child: const Text("Confirm Payment"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  isBold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text("\$${value.toStringAsFixed(2)}",
              style:
                  isBold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }

  void _confirmPayment(double total) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment of \$${total.toStringAsFixed(2)} confirmed!"),
      ),
    );

    // Clear selected products after payment
    setState(() {
      selectedProducts.clear();
    });
  }
}
