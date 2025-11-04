import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import '../theme/catppuccin_theme.dart';
import 'add_edit_product_screen.dart';

class ProductListScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Pulse'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firebaseService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: CatppuccinMocha.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: CatppuccinMocha.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: CatppuccinMocha.mauve,
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: CatppuccinMocha.overlay1,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: CatppuccinMocha.subtext0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first product',
                    style: TextStyle(
                      fontSize: 14,
                      color: CatppuccinMocha.overlay1,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(color: CatppuccinMocha.subtext1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: CatppuccinMocha.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: CatppuccinMocha.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditProductScreen(product: product),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: CatppuccinMocha.red),
                        onPressed: () {
                          _showDeleteDialog(context, product);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CatppuccinMocha.surface0,
        title: Text(
          'Delete Product',
          style: TextStyle(color: CatppuccinMocha.text),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: TextStyle(color: CatppuccinMocha.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: CatppuccinMocha.subtext1),
            ),
          ),
          TextButton(
            onPressed: () {
              if (product.id != null) {
                _firebaseService.deleteProduct(product.id!);
              }
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: CatppuccinMocha.red),
            ),
          ),
        ],
      ),
    );
  }
}
