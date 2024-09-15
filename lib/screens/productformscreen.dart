import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/services/firestore_service.dart';

class ProductFormScreen extends StatefulWidget {
  final String shopId;
  final Product? product;

  ProductFormScreen({required this.shopId, this.product});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late int _quantity;
  late double _price;
  late double _offerPrice;
  late String _category;
  late bool _availability;
  late double _rating;
  late String _imageLink;
  late String _deliveryTime;
  late int _deliveryDays;
  late int _available_count;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name = widget.product!.product_name;
      _description = widget.product!.product_description;
      _quantity = widget.product!.product_quantity;
      _price = widget.product!.product_price;
      _offerPrice = widget.product!.product_offerprice;
      _category = widget.product!.product_cateogory;
      _availability = widget.product!.product_availability;
      _rating = widget.product!.product_rating;
      _imageLink = widget.product!.imageLink;
      _deliveryTime = widget.product!.deliveryTime ?? '';
      _deliveryDays = widget.product!.deliveryDays ?? 0;
      _available_count = widget.product!.Available_count ?? 0;
    } else {
      _name = '';
      _description = '';
      _quantity = 0;
      _price = 0.0;
      _offerPrice = 0.0;
      _category = '';
      _availability = true;
      _rating = 0.0;
      _imageLink = '';
      _deliveryTime = '';
      _deliveryDays = 0;
      _available_count = 0;
    }
  }

  String generateUniqueProductId(String productName) {
  // Get the first 4 letters of the product name (or pad it if it's shorter)
    String namePart = productName.length >= 4 
        ? productName.substring(0, 4).toLowerCase() 
        : productName.padRight(4, 'x').toLowerCase();

    // Generate a random 4-digit number
    int randomDigits = Random().nextInt(9000) + 1000;

    // Get the current timestamp in milliseconds
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Combine the parts to form a unique product ID
    return '$namePart$randomDigits$timestamp';
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String productId = widget.product?.product_id ?? generateUniqueProductId(_name);

      final product = Product(
        product_id: productId,
        product_name: _name,
        product_description: _description,
        product_quantity: _quantity,
        product_price: _price,
        product_offerprice: _offerPrice,
        product_cateogory: _category,
        product_availability: _availability,
        product_rating: _rating,
        imageLink: _imageLink,
        deliveryTime: _deliveryTime,
        deliveryDays: _deliveryDays,
        Available_count: _available_count,
      );

      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
      if (widget.product == null) {
        firestoreService.addProduct(widget.shopId, product);
      } else {
        firestoreService.updateProduct(widget.shopId, product);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a description' : null,
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter a quantity' : null,
                onSaved: (value) => _quantity = int.parse(value!),
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter a price' : null,
                onSaved: (value) => _price = double.parse(value!),
              ),
              TextFormField(
                initialValue: _offerPrice.toString(),
                decoration: InputDecoration(labelText: 'Offer Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter an offer price' : null,
                onSaved: (value) => _offerPrice = double.parse(value!),
              ),
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a category' : null,
                onSaved: (value) => _category = value!,
              ),
              SwitchListTile(
                title: Text('Availability'),
                value: _availability,
                onChanged: (value) => setState(() => _availability = value),
              ),
              TextFormField(
                initialValue: _rating.toString(),
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter a rating' : null,
                onSaved: (value) => _rating = double.parse(value!),
              ),
              TextFormField(
                initialValue: _imageLink,
                decoration: InputDecoration(labelText: 'Image Link'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter an image link' : null,
                onSaved: (value) => _imageLink = value!,
              ),
              TextFormField(
                initialValue: _deliveryTime,
                decoration: InputDecoration(labelText: 'Delivery Time'),
                onSaved: (value) => _deliveryTime = value!,
              ),
              TextFormField(
                initialValue: _deliveryDays.toString(),
                decoration: InputDecoration(labelText: 'Delivery Days'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _deliveryDays = int.parse(value!),
              ),
              TextFormField(
                initialValue: _available_count.toString(),
                decoration: InputDecoration(labelText: 'Available in Stock'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _available_count = int.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
