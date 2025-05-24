import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/screens/product_archivePage.dart';
import 'package:shop_app/screens/productformscreen.dart';
import 'package:shop_app/services/firestore_service.dart';
import 'package:shop_app/utils/constant/sizes.dart';
import 'package:qr_flutter/qr_flutter.dart'; // For generating QR codes
import 'package:flutter_pdfview/flutter_pdfview.dart'; // For PDF rendering
import 'dart:typed_data';
import 'dart:io';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

class ProductMaintenanceScreen extends StatefulWidget {
  final String shopId;
  final Product? product;

  ProductMaintenanceScreen({required this.shopId, this.product});

  @override
  _ProductMaintenanceScreenState createState() =>
      _ProductMaintenanceScreenState();
}

class _ProductMaintenanceScreenState extends State<ProductMaintenanceScreen>
    with WidgetsBindingObserver {
  String searchQuery = '';
  final GlobalKey _imageKey = GlobalKey(); // Key for rendering widget to image

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print("App is in background");
    } else if (state == AppLifecycleState.resumed) {
      print("App is in foreground");
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Buttons Row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductFormScreen(shopId: widget.shopId),
                      ),
                    );
                  },
                  icon:
                      Icon(Icons.add_circle_outlined, color: Colors.blueAccent),
                  iconSize: TSizes.iconLg,
                ),
                SizedBox(width: 8),
                IconButton(
                  color: Colors.blue,
                  onPressed: () {},
                  icon: Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                  iconSize: TSizes.iconLg,
                ),
                SizedBox(width: 8),
                IconButton(
                  color: Colors.blue,
                  onPressed: () {},
                  icon:
                      Icon(Icons.file_download_rounded, color: Colors.black87),
                  iconSize: TSizes.iconLg,
                ),
                IconButton(
                  color: Colors.black87,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductArchivePage(shopId: widget.shopId),
                      ),
                    );
                  },
                  icon: Icon(Icons.archive_rounded, color: Colors.black87),
                  iconSize: TSizes.iconLg,
                ),
              ],
            ),
          ),
          // Product Table
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shops')
                  .doc(widget.shopId)
                  .snapshots(),
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

                final filteredProducts = products
                    .where((product) => product.product_name
                        .toLowerCase()
                        .contains(searchQuery))
                    .toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          MaterialStateProperty.all(Colors.blue[50]),
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columns: _buildTableColumns(),
                      rows: filteredProducts.map((product) {
                        return _buildTableRow(product, firestoreService);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Action Button Widget
  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: Colors.blueAccent),
      label: Text(label, style: TextStyle(color: Colors.blueAccent)),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Colors.blueAccent),
      ),
      onPressed: onPressed,
    );
  }

  // Table Columns
  List<DataColumn> _buildTableColumns() {
    return [
      DataColumn(label: Text('Image')),
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Code')),
      DataColumn(label: Text('Category')),
      DataColumn(label: Text('Stock')),
      DataColumn(label: Text('Price')),
      DataColumn(label: Text('QR Code')),
      DataColumn(label: Text('Action')),
    ];
  }

  // Table Rows
  DataRow _buildTableRow(Product product, FirestoreService firestoreService) {
    return DataRow(cells: [
      DataCell(Image.network(product.imageLink, width: 50, height: 50)),
      DataCell(Text(_limitWords(product.product_name, 3),
          style: TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(product.product_id)),
      DataCell(Text(product.product_cateogory)),
      DataCell(Text('${product.Available_count}')),
      DataCell(Text('${product.product_offerprice}')),
      DataCell(
        MaterialButton(
          child: Text('QR Code'),
          onPressed: () {
            // Inside your onPressed function for the QR Code button
            showDialog(
              context: context,
              builder: (context) {
                final screenHeight = MediaQuery.of(context).size.height;

                return AlertDialog(
                  title: Text('View QR Code'),
                  content: SizedBox(
                    height: screenHeight *
                        0.150, // Dynamic height, 40% of screen height
                    child: RepaintBoundary(
                      key: _imageKey, // Wrap with RepaintBoundary
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // QR Code
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: QrImageView(
                                data: product.product_id,
                                version: QrVersions.auto,
                              ),
                            ),
                            SizedBox(width: 8), // Space between QR and Texts
                            // Text Details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ..._getLimitedTextByLength(product.product_name),
                                SizedBox(height: 3),
                                Text(
                                  "Product ID: ${product.product_id}",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "offer price: ${product.product_offerprice}",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                                
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Add printing logic here
                        _captureAndPrintQR(product.product_id);
                      },
                      child: Text('Print'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      DataCell(
        Row(
          children: [
            _buildActionButton(
              Icons.edit,
              "Edit",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(
                      shopId: widget.shopId,
                      product: product,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 8),
            _buildActionButton(
              Icons.delete,
              "Delete",
              () async {
                await firestoreService.archiveProduct(widget.shopId, product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${product.product_name} archived and will be deleted after 30 days.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ]);
  }

  // Function to print QR code as PDF
  Future<void> _captureAndPrintQR(String productId) async {
    try {
      // Generate the QR code image
      final qrPainter = QrPainter(
        data: productId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        gapless: false,
      );

      // Convert the QR painter to an image
      final picData = await qrPainter.toImage(200); // Adjust size as needed
      final byteData = await picData.toByteData(format: ui.ImageByteFormat.png);
      final qrBytes = byteData!.buffer.asUint8List();

      // Save QR code to a temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/qr_code.png');
      await file.writeAsBytes(qrBytes);

      // Optionally, print the QR code (as PDF in this case)
      await Printing.layoutPdf(onLayout: (format) async => qrBytes);

      // You could also share the file or display it after saving
      print('QR Code saved at: ${file.path}');
    } catch (e) {
      print("Error capturing or printing QR code: $e");
    }
  }

  // Helper: Limit product name to 3 words
  String _limitWords(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length > maxWords) {
      return words.take(maxWords).join(' ') + '...';
    }
    return text;
  }

  // Function to split the text into parts with a limited number of words per line

}
List<Widget> _getLimitedTextByLength(String text, {int maxLength = 25}) {
  List<Widget> result = [];
  for (int i = 0; i < text.length; i += maxLength) {
    String line = text.substring(i, i + maxLength > text.length ? text.length : i + maxLength);
    result.add(Text(line, style: TextStyle(fontSize: 11)));
    result.add(SizedBox(height: 2)); // Space between lines
  }
  return result;
}