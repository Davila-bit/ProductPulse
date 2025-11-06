import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import '../theme/catppuccin_theme.dart';
import 'add_edit_product_screen.dart';
import 'dashboard_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStockFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }

    // Filter by stock status
    if (_selectedStockFilter == 'Out of Stock') {
      filtered = filtered.where((product) => product.isOutOfStock).toList();
    } else if (_selectedStockFilter == 'Low Stock') {
      filtered = filtered.where((product) => product.isLowStock && !product.isOutOfStock).toList();
    } else if (_selectedStockFilter == 'In Stock') {
      filtered = filtered.where((product) => !product.isLowStock).toList();
    }

    return filtered;
  }

  Widget _buildFilterChip(String label, {required bool isCategory}) {
    final isSelected = isCategory
        ? _selectedCategory == label
        : _selectedStockFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (isCategory) {
              _selectedCategory = label;
            } else {
              _selectedStockFilter = label;
            }
          });
        },
        selectedColor: CatppuccinMocha.mauve,
        backgroundColor: CatppuccinMocha.surface0,
        labelStyle: TextStyle(
          color: isSelected ? CatppuccinMocha.base : CatppuccinMocha.text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Pulse'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            },
            tooltip: 'Dashboard',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: CatppuccinMocha.surface0,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Category Filters
                _buildFilterChip('All', isCategory: true),
                _buildFilterChip('Networking', isCategory: true),
                _buildFilterChip('Storage', isCategory: true),
                _buildFilterChip('Computing', isCategory: true),
                _buildFilterChip('Power', isCategory: true),
                _buildFilterChip('Cooling', isCategory: true),
                _buildFilterChip('Monitoring', isCategory: true),
                _buildFilterChip('Accessories', isCategory: true),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 32,
                  color: CatppuccinMocha.surface1,
                ),
                const SizedBox(width: 8),
                // Stock Filters
                _buildFilterChip('All', isCategory: false),
                _buildFilterChip('In Stock', isCategory: false),
                _buildFilterChip('Low Stock', isCategory: false),
                _buildFilterChip('Out of Stock', isCategory: false),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Product List
          Expanded(
            child: StreamBuilder<List<Product>>(
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

                final allProducts = snapshot.data ?? [];
                final products = _filterProducts(allProducts);

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
                          _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedStockFilter != 'All'
                              ? 'No products match your filters'
                              : 'No products yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: CatppuccinMocha.subtext0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedStockFilter != 'All'
                              ? 'Try adjusting your filters'
                              : 'Tap + to add your first product',
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
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            if (product.isOutOfStock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CatppuccinMocha.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'OUT OF STOCK',
                                  style: TextStyle(
                                    color: CatppuccinMocha.base,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else if (product.isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CatppuccinMocha.yellow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'LOW STOCK',
                                  style: TextStyle(
                                    color: CatppuccinMocha.base,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CatppuccinMocha.surface1,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: TextStyle(
                                      color: CatppuccinMocha.mauve,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.inventory_2,
                                  size: 16,
                                  color: CatppuccinMocha.subtext0,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.quantity}',
                                  style: TextStyle(
                                    color: CatppuccinMocha.subtext1,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: TextStyle(color: CatppuccinMocha.subtext1),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditProductScreen(),
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
