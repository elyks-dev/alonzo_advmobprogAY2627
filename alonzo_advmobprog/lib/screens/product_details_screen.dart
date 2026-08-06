import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../widgets/custom_text.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.image.isNotEmpty)
                AspectRatio(aspectRatio: 16 / 9, child: Image.network(product.image, fit: BoxFit.cover)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: product.title, fontSize: 20, fontWeight: FontWeight.w800),
                    const SizedBox(height: 8),
                    CustomText(text: '\$${product.price.toStringAsFixed(2)}', fontSize: 18, fontWeight: FontWeight.w700),
                    const SizedBox(height: 12),
                    CustomText(text: product.description, fontSize: 14),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Add to cart'),
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
