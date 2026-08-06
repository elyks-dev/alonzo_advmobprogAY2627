import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/product_model.dart';

class ProductService {
  final String _baseHost;

  ProductService({String? baseHost}) : _baseHost = baseHost ?? host;

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseHost/products')).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final List productsJson = decoded['products'] ?? decoded['data'] ?? [];
          return productsJson
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fall back to a small local catalog when the network request fails.
    }

    return [
      Product(
        id: '1',
        title: 'Sample Product',
        description: 'A fallback product shown when the network is unavailable.',
        price: 19.99,
        image: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=600&q=80',
      ),
      Product(
        id: '2',
        title: 'Starter Bundle',
        description: 'A second example product so the grid is populated.',
        price: 29.5,
        image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=600&q=80',
      ),
    ];
  }
}
