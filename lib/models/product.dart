import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final String category;
  final String description;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert a Product to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create a Product from a Firestore document
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Helper to check if item is low stock
  bool get isLowStock => quantity < 5;

  // Helper to check if item is out of stock
  bool get isOutOfStock => quantity == 0;
}
