import 'product.dart';

class Cart {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  const Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'];

    return Cart(
      id: _toInt(json['id']),
      products: productsJson is List
          ? productsJson
                .whereType<Map<String, dynamic>>()
                .map(CartProduct.fromJson)
                .toList()
          : const [],
      total: _toDouble(json['total']),
      discountedTotal: _toDouble(json['discountedTotal']),
      userId: _toInt(json['userId']),
      totalProducts: _toInt(json['totalProducts']),
      totalQuantity: _toInt(json['totalQuantity']),
    );
  }

  static int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static double _toDouble(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  Cart copyWith({
    List<CartProduct>? products,
    double? total,
    double? discountedTotal,
    int? totalProducts,
    int? totalQuantity,
  }) {
    return Cart(
      id: id,
      products: products ?? this.products,
      total: total ?? this.total,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      userId: userId,
      totalProducts: totalProducts ?? this.totalProducts,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }
}

class CartProduct {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedPrice;
  final double discountedTotal;
  final String thumbnail;

  const CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.discountedTotal,
    required this.thumbnail,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

    return CartProduct(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      price: toDouble(json['price']),
      quantity: json['quantity'] is num
          ? (json['quantity'] as num).toInt()
          : int.tryParse('${json['quantity']}') ?? 0,
      total: toDouble(json['total']),
      discountPercentage: toDouble(json['discountPercentage']),
      discountedPrice: toDouble(
        json['discountedPrice'] ?? json['discountedTotal'],
      ),
      discountedTotal: toDouble(json['discountedTotal']),
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }

  CartProduct copyWith({
    int? quantity,
    double? total,
    double? discountedTotal,
  }) {
    return CartProduct(
      id: id,
      title: title,
      price: price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      discountPercentage: discountPercentage,
      discountedPrice: discountedPrice,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      thumbnail: thumbnail,
    );
  }

  Product toProduct() {
    return Product(
      id: id.toString(),
      title: title,
      description: 'This product is included in cart quantity $quantity.',
      price: price,
      image: thumbnail,
    );
  }
}
