import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import '../theme/catppuccin_theme.dart';

class DashboardScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
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
          final stats = _calculateStats(products);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Items',
                        stats['totalItems'].toString(),
                        Icons.inventory_2,
                        CatppuccinMocha.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Value',
                        '\$${stats['totalValue'].toStringAsFixed(2)}',
                        Icons.attach_money,
                        CatppuccinMocha.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Categories',
                        stats['categories'].toString(),
                        Icons.category,
                        CatppuccinMocha.mauve,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Stock',
                        stats['totalQuantity'].toString(),
                        Icons.warehouse,
                        CatppuccinMocha.peach,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Out of Stock Section
                Text(
                  'Out of Stock Items',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CatppuccinMocha.text,
                  ),
                ),
                const SizedBox(height: 12),
                _buildOutOfStockSection(products),

                const SizedBox(height: 24),

                // Low Stock Section
                Text(
                  'Low Stock Items (< 5)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CatppuccinMocha.text,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLowStockSection(products),

                const SizedBox(height: 24),

                // Category Breakdown
                Text(
                  'Category Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CatppuccinMocha.text,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryBreakdown(products),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<Product> products) {
    final totalItems = products.length;
    final totalValue = products.fold<double>(
      0,
      (sum, product) => sum + (product.price * product.quantity),
    );
    final categories = products.map((p) => p.category).toSet().length;
    final totalQuantity =
        products.fold<int>(0, (sum, product) => sum + product.quantity);

    return {
      'totalItems': totalItems,
      'totalValue': totalValue,
      'categories': categories,
      'totalQuantity': totalQuantity,
    };
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: CatppuccinMocha.subtext1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CatppuccinMocha.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutOfStockSection(List<Product> products) {
    final outOfStock = products.where((p) => p.isOutOfStock).toList();

    if (outOfStock.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: CatppuccinMocha.green, size: 32),
              const SizedBox(width: 12),
              Text(
                'All items in stock!',
                style: TextStyle(
                  fontSize: 16,
                  color: CatppuccinMocha.text,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: outOfStock.map((product) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.warning, color: CatppuccinMocha.red),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(product.category),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CatppuccinMocha.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'OUT',
                style: TextStyle(
                  color: CatppuccinMocha.base,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLowStockSection(List<Product> products) {
    final lowStock = products
        .where((p) => p.isLowStock && !p.isOutOfStock)
        .toList();

    if (lowStock.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: CatppuccinMocha.green, size: 32),
              const SizedBox(width: 12),
              Text(
                'No low stock items!',
                style: TextStyle(
                  fontSize: 16,
                  color: CatppuccinMocha.text,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: lowStock.map((product) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.warning_amber, color: CatppuccinMocha.yellow),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(product.category),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CatppuccinMocha.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${product.quantity}',
                style: TextStyle(
                  color: CatppuccinMocha.base,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryBreakdown(List<Product> products) {
    final categoryStats = <String, Map<String, dynamic>>{};

    for (final product in products) {
      if (!categoryStats.containsKey(product.category)) {
        categoryStats[product.category] = {
          'count': 0,
          'value': 0.0,
          'quantity': 0,
        };
      }
      categoryStats[product.category]!['count'] =
          categoryStats[product.category]!['count'] + 1;
      categoryStats[product.category]!['value'] =
          categoryStats[product.category]!['value'] +
              (product.price * product.quantity);
      categoryStats[product.category]!['quantity'] =
          categoryStats[product.category]!['quantity'] + product.quantity;
    }

    final sortedCategories = categoryStats.entries.toList()
      ..sort((a, b) => b.value['value'].compareTo(a.value['value']));

    return Column(
      children: sortedCategories.map((entry) {
        final category = entry.key;
        final stats = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CatppuccinMocha.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CatppuccinMocha.mauve,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${stats['count']} items',
                        style: TextStyle(
                          color: CatppuccinMocha.base,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Value',
                          style: TextStyle(
                            fontSize: 12,
                            color: CatppuccinMocha.subtext1,
                          ),
                        ),
                        Text(
                          '\$${stats['value'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CatppuccinMocha.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Quantity',
                          style: TextStyle(
                            fontSize: 12,
                            color: CatppuccinMocha.subtext1,
                          ),
                        ),
                        Text(
                          '${stats['quantity']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CatppuccinMocha.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
