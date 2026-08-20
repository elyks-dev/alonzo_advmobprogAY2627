import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  final String _baseHost;
  final http.Client _client;

  CartService({String? baseHost, http.Client? client})
    : _baseHost = baseHost ?? host,
      _client = client ?? http.Client();

  /// Enhancement 3: Retrieves carts for one user through DummyJSON's
  /// `/carts/user/{userId}` endpoint. The screen selects the first result.
  Future<List<Cart>> getCartsByUserId(int userId) async {
    final response = await _client
        .get(Uri.parse('$_baseHost/carts/user/$userId'))
        .timeout(const Duration(seconds: 8));
    _checkResponse(response, 'Failed to load the cart');

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['carts'] is! List) {
      throw const FormatException('Invalid cart response');
    }

    return (decoded['carts'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Cart.fromJson)
        .toList();
  }

  /// Enhancement 3: Gets one cart by its cart ID using `/carts/{id}`.
  Future<Cart> getCartById(int cartId) async {
    final response = await _client
        .get(Uri.parse('$_baseHost/carts/$cartId'))
        .timeout(const Duration(seconds: 8));
    _checkResponse(response, 'Failed to load cart $cartId');
    return _decodeCart(response.body);
  }

  /// Enhancement 3: Gets the complete cart collection using `/carts`.
  Future<List<Cart>> getAllCarts() async {
    final response = await _client
        .get(Uri.parse('$_baseHost/carts'))
        .timeout(const Duration(seconds: 8));
    _checkResponse(response, 'Failed to load carts');
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['carts'] is! List) {
      throw const FormatException('Invalid carts response');
    }
    return (decoded['carts'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Cart.fromJson)
        .toList();
  }

  /// Enhancement 3: Adds a product using DummyJSON's `/carts/add` endpoint.
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    return addProductsToCart(
      userId: userId,
      products: [
        {'id': productId, 'quantity': quantity},
      ],
    );
  }

  /// Enhancement 3: Matches the documented `/carts/add` payload and supports
  /// adding multiple products in one request.
  Future<Cart> addProductsToCart({
    required int userId,
    required List<Map<String, int>> products,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseHost/carts/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'products': products}),
        )
        .timeout(const Duration(seconds: 8));
    _checkResponse(response, 'Failed to add the product to the cart');
    return _decodeCart(response.body);
  }

  /// Enhancement 3: Updates an existing cart with PUT or PATCH semantics.
  Future<Cart> updateCart({
    required int cartId,
    required List<Map<String, int>> products,
    bool merge = true,
    bool patch = false,
  }) async {
    final request = {'merge': merge, 'products': products};
    final response = patch
        ? await _client
              .patch(
                Uri.parse('$_baseHost/carts/$cartId'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(request),
              )
              .timeout(const Duration(seconds: 8))
        : await _client
              .put(
                Uri.parse('$_baseHost/carts/$cartId'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(request),
              )
              .timeout(const Duration(seconds: 8));
    _checkResponse(response, 'Failed to update cart $cartId');
    return _decodeCart(response.body);
  }

  /// Enhancement 3: Deletes a cart using `/carts/{id}`.
  Future<Cart> deleteCart(int cartId) async {
    final response = await _client
        .delete(Uri.parse('$_baseHost/carts/$cartId'))
        .timeout(const Duration(seconds: 8));
    _checkResponse(response, 'Failed to delete cart $cartId');
    return _decodeCart(response.body);
  }

  Cart _decodeCart(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid cart response');
    }
    return Cart.fromJson(decoded);
  }

  void _checkResponse(http.Response response, String message) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('$message (${response.statusCode})');
    }
  }

  void dispose() => _client.close();
}
