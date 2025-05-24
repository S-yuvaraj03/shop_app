import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  late String _name, _description, _category, _imageLink, _deliveryTime;
  late int _quantity,
      _deliveryDays,
      _availableCount,
      _totalAdded,
      _totalSold = 0;
  late double _price, _offerPrice, _rating;
  late bool _availability;
  int _previousAvailableCount = 0;
  List<String> _productImages = [];
  int _currentStep = 0;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize fields with product data if provided
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
      _availableCount = widget.product!.Available_count ?? 0;
      _totalAdded = widget.product!.totalAdded ?? 0;
      _totalSold = widget.product!.totalSold ?? 0;
      _previousAvailableCount = _availableCount;
      _productImages = widget.product!.productImages ?? [];
    } else {
      // Initialize empty fields for new product
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
      _availableCount = 0;
      _productImages = [];
    }
  }

  Future<void> _pickImage() async {
    if (_productImages.length < 5) {
      final pickedImage =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        String imageUrl = await _uploadImageToFirebase(File(pickedImage.path));
        setState(() {
          _productImages.add(imageUrl);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can upload up to 5 images only')));
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    UploadTask uploadTask =
        FirebaseStorage.instance.ref().child(fileName).putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String productId =
          widget.product?.product_id ?? generateUniqueProductId(_name);

      int addedCount = _availableCount - _previousAvailableCount;

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
        Available_count: _availableCount,
        totalAdded:
            widget.product == null ? addedCount : _totalAdded + addedCount,
        totalSold: _totalSold,
        lastlyUpdatedAvailableCount: _availableCount,
        productImages: _productImages,
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

  String generateUniqueProductId(String productName) {
    String namePart = productName.length >= 4
        ? productName.substring(0, 4).toLowerCase()
        : productName.padRight(4, 'x').toLowerCase();
    int randomDigits = Random().nextInt(9000) + 1000;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$namePart$randomDigits$timestamp';
  }

  List<Step> _getSteps() => [
        Step(
          title: Text('Basic Info'),
          content: Column(
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
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a category' : null,
                onSaved: (value) => _category = value!,
              ),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter a quantity' : null,
                onSaved: (value) => _quantity = int.parse(value!),
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
            ],
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: Text('Pricing & Stock'),
          content: Column(
            children: [
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
                initialValue: _availableCount.toString(),
                decoration: InputDecoration(labelText: 'Available Stock'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _availableCount = int.parse(value!),
              ),
            ],
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: Text('Images'),
          content: Column(
            children: [
              Text('Product Images (max 5)'),
              ..._productImages.map((url) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _imageLink = url;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected as main image')));
                    },
                    child: Stack(
                      children: [
                        Image.network(url, height: 100),
                        if (_imageLink == url)
                          Positioned(
                            top: 0,
                            right: 0,
                            child:
                                Icon(Icons.check_circle, color: Colors.green),
                          ),
                      ],
                    ),
                  )),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
            ],
          ),
          isActive: _currentStep >= 2,
        ),
        Step(
          title: Text('Delivery Info'),
          content: Column(
            children: [
              SizedBox(height: 16),
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
            ],
          ),
          isActive: _currentStep >= 3,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                steps: _getSteps(),
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < _getSteps().length - 1) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  if (_currentStep == _getSteps().length - 1) {
                    // On the last step, only show the "Save Product" button
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _saveProduct();
                          }
                        },
                        child: Text('Save Product'),
                      ),
                    );
                  } else if (_currentStep == _getSteps().length - 2) {
                    // On the third step, show only the "Continue" button
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text('Continue'),
                      ),
                    );
                  } else {
                    // On other steps, show both "Continue" and "Cancel" buttons
                    return Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text('Continue'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: details.onStepCancel,
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
