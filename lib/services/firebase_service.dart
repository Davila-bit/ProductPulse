import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'products';

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    await _firestore.collection(collectionName).add(product.toMap());
  }

  // Update an existing product
  Future<void> updateProduct(Product product) async {
    if (product.id != null) {
      await _firestore
          .collection(collectionName)
          .doc(product.id)
          .update(product.toMap());
    }
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }
}
