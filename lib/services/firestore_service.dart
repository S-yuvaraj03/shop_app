import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image, String path) async {
    final storageRef = _storage.ref().child(path);
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> addShop(Shop shop) {
    return _db.collection('shops').doc(shop.shopid).set(shop.toMap());
  }

  Future<void> updateShop(Shop shop) {
    return _db.collection('shops').doc(shop.shopid).update(shop.toMap());
  }

  Future<void> deleteShop(String shopId) {
    return _db.collection('shops').doc(shopId).delete();
  }

  Future<void> addProduct(String shopId, Product product) {
    return _db.collection('shops').doc(shopId).update({
      'products': FieldValue.arrayUnion([product.toMap()])
    });
  }

  Future<void> updateProduct(String shopId, Product product) async {
  // Retrieve the current shop document
  DocumentSnapshot shopDoc = await _db.collection('shops').doc(shopId).get();

  // Ensure the document exists and contains the 'products' field
  if (shopDoc.exists) {
    // Cast the shop data to Map<String, dynamic>
    Map<String, dynamic> shopData = shopDoc.data() as Map<String, dynamic>;

    // Get the list of products from the shop document, or an empty list if null
    List<dynamic> products = shopData['products'] ?? [];

    // Find the index of the product to update based on product_id
    int productIndex = products.indexWhere((p) => p['product_id'] == product.product_id);

    if (productIndex != -1) {
      // Replace the old product with the updated product
      products[productIndex] = product.toMap();

      // Update the entire products array
      await _db.collection('shops').doc(shopId).update({'products': products});
    } else {
      throw Exception('Product not found');
    }
  } else {
    throw Exception('Shop not found');
  }
}


  Future<void> deleteProduct(String shopId, Product product) {
    return _db.collection('shops').doc(shopId).update({
      'products': FieldValue.arrayRemove([product.toMap()])
    });
  }

  // Stream to get shops owned by the current user
  Stream<List<Shop>> getShopsByOwnerEmail(String email) {
    return _db.collection('shops')
      .where('shopowner_mailid', isEqualTo: email)
      .snapshots()
      .map((snapshot) =>
        snapshot.docs.map((doc) => Shop.fromMap(doc.data())).toList());
  }
}
