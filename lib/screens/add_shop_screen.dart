import 'dart:io'; // Add for file handling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Add this for image picking
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add Firebase storage
import 'package:shop_app/services/firestore_service.dart';
import 'package:shop_app/models/shop.dart';

class AddShopScreen extends StatefulWidget {
  @override
  _AddShopScreenState createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  late String _shopName;
  late String _shopAddress;
  late String _shopContactNo;
  late String _openingTime;
  late String _closingTime;
  late String _googleMapLink;
  late List<String> _shopImages;
  late bool _isOnline;
  late bool _isDeliveryAvailable;
  late String _shopOwnerName;
  late String _shopOwnerMailId;
  late String _shopOwnerMobileNo;
  String? _mainImageUrl; // Track main image URL
  int? _selectedMainImageIndex;
  
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _shopImages = ['', '', '']; // Three empty slots for images
    _isOnline = false;
    _isDeliveryAvailable = false;
    _mainImageUrl = null;
  }

  Future<String> uploadImage(File image, String path) async {
    final storageRef = _storage.ref().child(path);
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  void _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      String path = 'shops/${DateTime.now().millisecondsSinceEpoch}.jpg';
      String imageUrl = await uploadImage(image, path);

      setState(() {
        for (int i = 0; i < _shopImages.length; i++) {
          if (_shopImages[i].isEmpty) {
            _shopImages[i] = imageUrl;
            break;
          }
        }
      });
    }
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Use the selected main image, or fallback to the first uploaded image
      String shopImageUrl = _mainImageUrl ?? _shopImages.firstWhere((image) => image.isNotEmpty, orElse: () => '');

      final shop = Shop(
        shopid: DateTime.now().millisecondsSinceEpoch.toString(),
        shopename: _shopName,
        shopaddress: _shopAddress,
        shopcontactno: _shopContactNo,
        shopeimages: _shopImages,
        openingtime: _openingTime,
        closingtime: _closingTime,
        googleMapLink: _googleMapLink,
        isOnline: _isOnline,
        deliveryAvailable: _isOnline ? _isDeliveryAvailable : false,
        shopowner_name: _shopOwnerName,
        shopowner_mailid: _shopOwnerMailId,
        shopowner_mobileno: _shopOwnerMobileNo,
        shopImageUrl: _mainImageUrl, // Correctly assigned shop image URL
        products: [],
      );

      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      firestoreService.addShop(shop);

      Navigator.pop(context);
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: Text('Shop Profile'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Shop Name'),
                validator: (value) => value!.isEmpty ? 'Enter a shop name' : null,
                onSaved: (value) => _shopName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Shop Owner Name'),
                validator: (value) => value!.isEmpty ? 'Enter the shop owner name' : null,
                onSaved: (value) => _shopOwnerName = value!,
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: Text('Shop Contact'),
        content: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Shop Address'),
              validator: (value) => value!.isEmpty ? 'Enter a shop address' : null,
              onSaved: (value) => _shopAddress = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Shop Contact No'),
              validator: (value) => value!.isEmpty ? 'Enter a shop contact no' : null,
              onSaved: (value) => _shopContactNo = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Shop Owner Mail ID'),
              validator: (value) => value!.isEmpty ? 'Enter the shop owner mail ID' : null,
              onSaved: (value) => _shopOwnerMailId = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Shop Owner Mobile No'),
              validator: (value) => value!.isEmpty ? 'Enter the shop owner mobile no' : null,
              onSaved: (value) => _shopOwnerMobileNo = value!,
            ),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: Text('Shop Details'),
        content: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Opening Time'),
              validator: (value) => value!.isEmpty ? 'Enter opening time' : null,
              onSaved: (value) => _openingTime = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Closing Time'),
              validator: (value) => value!.isEmpty ? 'Enter closing time' : null,
              onSaved: (value) => _closingTime = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Google Maps Location Link'),
              validator: (value) => value!.isEmpty ? 'Enter Google Maps location link' : null,
              onSaved: (value) => _googleMapLink = value!,
            ),
            ListTile(
              title: Text('Is the shop online?'),
              trailing: Switch(
                value: _isOnline,
                onChanged: (value) {
                  setState(() {
                    _isOnline = value;
                  });
                },
              ),
            ),
            if (_isOnline)
              ListTile(
                title: Text('Is delivery available?'),
                trailing: Switch(
                  value: _isDeliveryAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isDeliveryAvailable = value;
                    });
                  },
                ),
              ),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: Text('Shop Images'),
        content: Column(
          children: [
            // Upload Image Button
            ElevatedButton(
              onPressed: _shopImages.contains('') ? _pickAndUploadImage : null,  // Disable if all slots are filled
              child: Text(_shopImages.contains('') ? 'Upload Image' : 'All Images Uploaded'),
            ),
            SizedBox(height: 20),

            // Row of Images with Selection Option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: () {
                    if (_shopImages[index].isNotEmpty) {
                      setState(() {
                        _mainImageUrl = _shopImages[index];  // Set the clicked image as the main image
                        _selectedMainImageIndex = index;     // Track the selected image
                      });
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedMainImageIndex == index
                                ? Colors.blue  // Highlight selected image number
                                : Colors.grey,  // Unselected image number
                            width: 2,
                          ),
                        ),
                        child: _shopImages[index].isNotEmpty
                            ? Image.network(_shopImages[index], width: 100, height: 100)
                            : Container(width: 100, height: 100, color: Colors.grey),  // Placeholder for empty slots
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: _selectedMainImageIndex == index
                              ? Colors.blue
                              : Colors.grey,
                          child: Icon(Icons.check, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Banner Image URL (Optional)'),
              onChanged: (value) {
                setState(() {
                  _mainImageUrl = value.isNotEmpty ? value : _mainImageUrl;
                });
              },
            ),
          ],
        ),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Shop'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          steps: _buildSteps(),
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < _buildSteps().length - 1) {
              setState(() => _currentStep += 1);
            } else {
              _saveShop();  // Call save function when last step is done
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
        ),
      ),
    );
  }
}
