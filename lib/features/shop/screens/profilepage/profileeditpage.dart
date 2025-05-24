import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _gender = '';
  int _age = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch the user's document from Firestore
      DocumentSnapshot doc = await _firestore
          .collection(
              'shopkeepers_user_profile') // Changed to shopkeepers collection
          .doc(user.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _name = data['name'] ?? '';
          _email = data['email'] ?? '';
          _phone = data['phone'] ?? '';
          _address = data['address'] ?? '';
          _gender = data['gender'] ?? '';
          _age = data['age'] ?? 0;
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore
            .collection('shopkeepers_user_profile')
            .doc(user.uid)
            .set({
          'name': _name,
          'email': _email,
          'phone': _phone,
          'address': _address,
          'gender': _gender,
          'age': _age,
        }, SetOptions(merge: true)); // Use merge to update without overwriting
        Navigator.of(context).pop(); // Navigate back after saving
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double kheight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            const Text("Edit Profile", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: _buildFormContainer(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        _buildTextFormField('Name', _name, (value) {
                          _name = value!;
                        }),
                        _buildTextFormField('Email', _email, (value) {
                          _email = value!;
                        }),
                        IntlPhoneField(
                          initialValue: _phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: const TextStyle(color: Colors.black),
                            hintText: 'Phone Number',
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          onChanged: (phone) {
                            _phone = phone.completeNumber;
                          },
                        ),
                        _buildTextFormField('Address', _address, (value) {
                          _address = value!;
                        }),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            labelStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          value: _gender.isNotEmpty ? _gender : null,
                          items: ['Male', 'Female', 'Other']
                              .map((gender) => DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(
                                      gender,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your gender.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _gender = value!;
                          },
                        ),
                        _buildTextFormField('Age', _age.toString(), (value) {
                          _age = int.parse(value!);
                        }, keyboardType: TextInputType.number),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, kheight * 0.054),
                            backgroundColor: Colors.black,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    String initialValue,
    FormFieldSetter<String> onSaved, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        initialValue: initialValue,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter your $label.';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildFormContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: child,
    );
  }
}
