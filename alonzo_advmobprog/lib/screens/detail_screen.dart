import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.userId = 6,
  });

  final Product product;
  final int userId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _adding = false;

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    try {
      final userId = context.read<AuthProvider>().user?.id ?? widget.userId;
      final cartProvider = context.read<CartProvider>();
      cartProvider.loadCart(userId);

      for (var i = 0; i < _quantity; i++) {
        await cartProvider.addProduct(widget.product);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added to cart!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to add product: $error')),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.product.image.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(widget.product.image, fit: BoxFit.cover),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: widget.product.title,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text: '\$${widget.product.price.toStringAsFixed(2)}',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 12),
                    CustomText(text: widget.product.description, fontSize: 14),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          tooltip: 'Decrease quantity',
                        ),
                        Text('$_quantity'),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'Increase quantity',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _adding ? null : _addToCart,
                            icon: _adding
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.shopping_cart_outlined),
                            label: Text(_adding ? 'Adding...' : 'Add to cart'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
