import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _service = ProductService();

  List<Product> _products = [];
  List<Product> _filtered = [];
  bool _loading = true;

  bool _cartLoaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_cartLoaded) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<CartProvider>().loadCart(userId);
        _cartLoaded = true;
      }
    }
  }

  Future<void> _load() async {
    try {
      final list = await _service.getAllProducts();

      setState(() {
        _products = list;
        _filtered = list;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _products = [];
        _filtered = [];
        _loading = false;
      });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = _products
          .where((p) => p.title.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addToCart(Product product) async {
    try {
      await context.read<CartProvider>().addProduct(product);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search products',
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: CustomText(
                          text: 'No products found',
                          fontSize: 16,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.60,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final p = _filtered[index];

                          return Card(
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsScreen(product: p),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: p.image.isNotEmpty
                                        ? Image.network(
                                            p.image,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder:
                                                (_, __, ___) => Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported_outlined,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: p.title,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        const SizedBox(height: 6),
                                        CustomText(
                                          text:
                                              '\$${p.price.toStringAsFixed(2)}',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        const SizedBox(height: 10),
                                        Center(
                                          child: Chip(
                                            label: Text('ID ${p.id}'),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}