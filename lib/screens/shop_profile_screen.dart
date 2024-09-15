import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/screens/product_maintenance_screen.dart';
import 'package:shop_app/services/firestore_service.dart';

class ShopProfileScreen extends StatefulWidget {
  final Shop shop;

  ShopProfileScreen({required this.shop});

  @override
  _ShopProfileScreenState createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _shopName;
  late String _shopAddress;
  late String _shopContactNo;
  late String _openingTime;
  late String _closingTime;
  late String _googleMapLink;
  late bool _isOnline;
  late bool _deliveryAvailable;
  File? _shopImage;
  final ImagePicker _picker = ImagePicker();
  late String _shopOwnerName;
  late String _shopOwnerMailId;
  late String _shopOwnerMobileNo;

  @override
  void initState() {
    super.initState();
    _shopName = widget.shop.shopename;
    _shopAddress = widget.shop.shopaddress;
    _shopContactNo = widget.shop.shopcontactno;
    _openingTime = widget.shop.openingtime;
    _closingTime = widget.shop.closingtime;
    _googleMapLink = widget.shop.googleMapLink;
    _isOnline = widget.shop.isOnline;
    _deliveryAvailable = widget.shop.deliveryAvailable;
    _shopOwnerName = widget.shop.shopowner_name;
    _shopOwnerMailId = widget.shop.shopowner_mailid;
    _shopOwnerMobileNo = widget.shop.shopowner_mobileno;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _shopImage = File(pickedFile.path);
      });
    }
  }

  void _saveShop() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? shopImageUrl;

      if (_shopImage != null) {
        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
        shopImageUrl = await firestoreService.uploadImage(_shopImage!, 'shops/${widget.shop.shopid}/shop_image.jpg');
      }

      final shop = Shop(
        shopid: widget.shop.shopid,
        shopename: _shopName,
        shopaddress: _shopAddress,
        shopcontactno: _shopContactNo,
        openingtime: _openingTime,
        closingtime: _closingTime,
        googleMapLink: _googleMapLink,
        isOnline: _isOnline,
        deliveryAvailable: _deliveryAvailable,
        shopImageUrl: shopImageUrl ?? widget.shop.shopImageUrl,
        shopeimages: widget.shop.shopeimages,
        products: widget.shop.products,
        shopowner_name: _shopOwnerName,
        shopowner_mailid: _shopOwnerMailId,
        shopowner_mobileno: _shopOwnerMobileNo
      );

      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      await firestoreService.updateShop(shop);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductMaintenanceScreen(
            shopId: shop.shopid, // Assuming the Shop model has an 'id' field
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _shopName,
                decoration: InputDecoration(labelText: 'Shop Name'),
                validator: (value) => value!.isEmpty ? 'Enter shop name' : null,
                onSaved: (value) => _shopName = value!,
              ),
              TextFormField(
                initialValue: _shopAddress,
                decoration: InputDecoration(labelText: 'Shop Address'),
                validator: (value) => value!.isEmpty ? 'Enter shop address' : null,
                onSaved: (value) => _shopAddress = value!,
              ),
              TextFormField(
                initialValue: _shopContactNo,
                decoration: InputDecoration(labelText: 'Shop Contact No'),
                validator: (value) => value!.isEmpty ? 'Enter shop contact no' : null,
                onSaved: (value) => _shopContactNo = value!,
              ),
              TextFormField(
                initialValue: _openingTime,
                decoration: InputDecoration(labelText: 'Opening Time'),
                validator: (value) => value!.isEmpty ? 'Enter opening time' : null,
                onSaved: (value) => _openingTime = value!,
              ),
              TextFormField(
                initialValue: _closingTime,
                decoration: InputDecoration(labelText: 'Closing Time'),
                validator: (value) => value!.isEmpty ? 'Enter closing time' : null,
                onSaved: (value) => _closingTime = value!,
              ),
              TextFormField(
                initialValue: _googleMapLink,
                decoration: InputDecoration(labelText: 'Google Map Link'),
                validator: (value) => value!.isEmpty ? 'Enter Google map link' : null,
                onSaved: (value) => _googleMapLink = value!,
              ),
              SwitchListTile(
                title: Text('Is Online'),
                value: _isOnline,
                onChanged: (value) => setState(() => _isOnline = value),
              ),
              if (_isOnline)
                SwitchListTile(
                  title: Text('Delivery Available'),
                  value: _deliveryAvailable,
                  onChanged: (value) => setState(() => _deliveryAvailable = value),
                ),
              SizedBox(height: 10),
              _shopImage != null
                  ? Image.file(_shopImage!)
                  : widget.shop.shopImageUrl != null
                      ? Image.network(widget.shop.shopImageUrl!)
                      : Placeholder(fallbackHeight: 200, fallbackWidth: double.infinity),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text('Upload Image'),
                onPressed: _pickImage,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveShop ,
                child: Text('Save Shop'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
