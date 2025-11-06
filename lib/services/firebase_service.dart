import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'products';

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get products filtered by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection(collectionName)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get out of stock products
  Stream<List<Product>> getOutOfStockProducts() {
    return _firestore
        .collection(collectionName)
        .where('quantity', isEqualTo: 0)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Get low stock products (quantity < 5)
  Stream<List<Product>> getLowStockProducts() {
    return _firestore
        .collection(collectionName)
        .where('quantity', isLessThan: 5)
        .snapshots()
        .map((snapshot) {
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

  // Get all unique categories
  Future<List<String>> getCategories() async {
    final snapshot = await _firestore.collection(collectionName).get();
    final categories = snapshot.docs
        .map((doc) => doc.data()['category'] as String)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
