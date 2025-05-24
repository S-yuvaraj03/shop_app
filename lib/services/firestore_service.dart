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

  // Future<void> deleteShop(String shopId) {
  //   return _db.collection('shops').doc(shopId).delete();
  // }

  // Archive shop and add timestamp
  Future<void> archiveShop(String shopId) async {
    DocumentSnapshot shopDoc = await _db.collection('shops').doc(shopId).get();
    if (shopDoc.exists) {
      Map<String, dynamic> shopData = shopDoc.data() as Map<String, dynamic>;

      // Add timestamp when archiving
      shopData['archived_at'] = FieldValue.serverTimestamp();

      // Move the shop to 'archive_shops'
      await _db.collection('archive_shops').doc(shopId).set(shopData);

      // Remove from the 'shops' collection
      await _db.collection('shops').doc(shopId).delete();
    }
  }

  // Cancel shop archiving: Move back from 'archive_shops' to 'shops'
  Future<void> cancelArchiveShop(String shopId) async {
    DocumentSnapshot shopDoc = await _db.collection('archive_shops').doc(shopId).get();
    if (shopDoc.exists) {
      Map<String, dynamic> shopData = shopDoc.data() as Map<String, dynamic>;

      // Move shop back to 'shops' collection
      await _db.collection('shops').doc(shopId).set(shopData);

      // Remove shop from 'archive_shops'
      await _db.collection('archive_shops').doc(shopId).delete();
    }
  }

  // Delete archived shops after 30 days
  Future<void> deleteExpiredArchivedShops() async {
    QuerySnapshot archivedShops = await _db.collection('archive_shops').get();

    for (var doc in archivedShops.docs) {
      Map<String, dynamic> shopData = doc.data() as Map<String, dynamic>;

      // Check if 'archived_at' exists and calculate time difference
      Timestamp? archivedAt = shopData['archived_at'] as Timestamp?;
      if (archivedAt != null) {
        DateTime archivedDate = archivedAt.toDate();
        DateTime currentDate = DateTime.now();
        Duration timeElapsed = currentDate.difference(archivedDate);

        if (timeElapsed.inDays >= 30) {
          // If 30 days have passed, delete the shop
          await _db.collection('archive_shops').doc(doc.id).delete();
        }
      }
    }
  }

  // Stream to get archived shops
  Stream<List<Shop>> getArchivedShops() {
    return _db.collection('archive_shops').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Shop.fromMap(doc.data())).toList());
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


  // Future<void> deleteProduct(String shopId, Product product) {
  //   return _db.collection('shops').doc(shopId).update({
  //     'products': FieldValue.arrayRemove([product.toMap()])
  //   });
  // }

  
  // Archive product by moving it from shop products to 'archive_products' collection
  Future<void> archiveProduct(String shopId, Product product) async {
    DocumentSnapshot shopDoc = await _db.collection('shops').doc(shopId).get();

    if (shopDoc.exists) {
      Map<String, dynamic> shopData = shopDoc.data() as Map<String, dynamic>;

      List<dynamic> products = shopData['products'] ?? [];
      int productIndex = products.indexWhere((p) => p['product_id'] == product.product_id);

      if (productIndex != -1) {
        // Remove the product from the shop's product list
        products.removeAt(productIndex);
        await _db.collection('shops').doc(shopId).update({'products': products});

        // Add the product to the 'archive_products' collection
        await _db.collection('archive_products').add({
          ...product.toMap(),
          'archived_at': FieldValue.serverTimestamp(),
          'shop_id': shopId,
        });
      }
    }
  }
  

  // Stream to get archived products
  Stream<List<Product>> getArchivedProducts(String shopId) {
    return _db.collection('archive_products')
      .where('shop_id', isEqualTo: shopId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList());
  }

  // Cancel product archiving: Move back from 'archive_products' to shop products
  Future<void> cancelArchiveProduct(String productId, String shopId) async {
    QuerySnapshot productQuery = await _db.collection('archive_products')
        .where('product_id', isEqualTo: productId)
        .where('shop_id', isEqualTo: shopId)
        .get();

    if (productQuery.docs.isNotEmpty) {
      DocumentSnapshot productDoc = productQuery.docs.first;
      Map<String, dynamic> productData = productDoc.data() as Map<String, dynamic>;

      // Add product back to shop's product list
      await _db.collection('shops').doc(shopId).update({
        'products': FieldValue.arrayUnion([productData])
      });

      // Remove the product from the 'archive_products' collection
      await _db.collection('archive_products').doc(productDoc.id).delete();
    }
  }

  // Clean up expired archived products when loading the page
  Future<void> deleteExpiredArchivedProducts() async {
    QuerySnapshot archivedProducts = await _db.collection('archive_products').get();

    for (var doc in archivedProducts.docs) {
      Map<String, dynamic> productData = doc.data() as Map<String, dynamic>;

      // Check if 'archived_at' exists and calculate time difference
      Timestamp? archivedAt = productData['archived_at'] as Timestamp?;
      if (archivedAt != null) {
        DateTime archivedDate = archivedAt.toDate();
        DateTime currentDate = DateTime.now();
        Duration timeElapsed = currentDate.difference(archivedDate);

        if (timeElapsed.inDays >= 30) {
          // If 30 days have passed, delete the product
          await _db.collection('archive_products').doc(doc.id).delete();
        }
      }
    }
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
