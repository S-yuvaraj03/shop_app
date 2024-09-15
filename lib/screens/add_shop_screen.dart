import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/services/firestore_service.dart';
import 'package:shop_app/models/shop.dart';

class AddShopScreen extends StatefulWidget {
  @override
  _AddShopScreenState createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();
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

  @override
  void initState() {
    super.initState();
    _shopImages = ['', '', ''];
    _isOnline = false;
    _isDeliveryAvailable = false;
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
        products: [],
      );

      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      firestoreService.addShop(shop);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Shop'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Shop Name'),
                validator: (value) => value!.isEmpty ? 'Enter a shop name' : null,
                onSaved: (value) => _shopName = value!,
              ),
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
              // Add owner details
              TextFormField(
                decoration: InputDecoration(labelText: 'Shop Owner Name'),
                validator: (value) => value!.isEmpty ? 'Enter the shop owner name' : null,
                onSaved: (value) => _shopOwnerName = value!,
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Banner Image 1'),
                onSaved: (value) => _shopImages[0] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Banner Image 2'),
                onSaved: (value) => _shopImages[1] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Banner Image 3'),
                onSaved: (value) => _shopImages[2] = value!,
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveShop,
                child: Text('Save Shop'),
              ),

              // Add other fields as shown earlier
            ],
          ),
        ),
      ),
    );
  }
}
