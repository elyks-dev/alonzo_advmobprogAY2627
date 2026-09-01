import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _service = CartService();
  Cart? _cart;
  int? _userId;

  Cart? get cart => _cart;
  List<CartProduct> get products => _cart?.products ?? const [];
  double get total => _cart?.total ?? 0.0;
  int get totalQuantity => _cart?.totalQuantity ?? 0;

  Future<void> loadCart(int userId) async {
    _userId = userId;

    try {
      final carts = await _service.getCartsByUserId(userId);
      if (carts.isNotEmpty) {
        _cart = carts.first;
      } else if (_cart == null) {
        _cart = _emptyCart(userId);
      }
    } catch (_) {
      if (_cart == null) {
        _cart = _emptyCart(userId);
      }
    }

    _recalculate();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final targetId = int.tryParse(product.id) ?? -1;
    final currentProducts = List<CartProduct>.from(_cart?.products ?? const []);

    final existingIndex = currentProducts.indexWhere((item) => item.id == targetId);
    if (existingIndex >= 0) {
      final current = currentProducts[existingIndex];
      final nextQuantity = current.quantity + 1;
      currentProducts[existingIndex] = current.copyWith(
        quantity: nextQuantity,
        total: current.price * nextQuantity,
        discountedTotal: current.discountedPrice * nextQuantity,
      );
      _cart = _cart?.copyWith(products: currentProducts) ?? _emptyCart(_userId ?? 0);
      _recalculate();
      notifyListeners();
      return;
    }

    final localProduct = CartProduct(
      id: targetId,
      title: product.title,
      price: product.price,
      quantity: 1,
      total: product.price,
      discountPercentage: 0,
      discountedPrice: product.price,
      discountedTotal: product.price,
      thumbnail: product.image,
    );

    final userId = _userId;
    if (userId != null) {
      try {
        final cart = await _service.addToCart(
          userId: userId,
          productId: targetId,
          quantity: 1,
        );
        final addedProduct = cart.products.firstWhere(
          (item) => item.id == targetId,
          orElse: () => localProduct,
        );
        currentProducts.add(addedProduct);
        _cart = cart.copyWith(products: currentProducts);
        _recalculate();
        notifyListeners();
        return;
      } catch (_) {
        // DummyJSON's mock cart endpoint can reject adds, but the cart must
        // still update locally for the app experience.
      }
    }

    currentProducts.add(localProduct);
    _cart = _cart?.copyWith(products: currentProducts) ?? _emptyCart(_userId ?? 0);
    _recalculate();
    notifyListeners();
  }

  void changeQuantity(CartProduct product, int change) {
    if (_cart == null) return;

    final updatedProducts = List<CartProduct>.from(_cart!.products);
    final index = updatedProducts.indexWhere((item) => item.id == product.id);
    if (index == -1) return;

    final item = updatedProducts[index];
    final nextQuantity = item.quantity + change;

    if (nextQuantity <= 0) {
      updatedProducts.removeAt(index);
    } else {
      updatedProducts[index] = item.copyWith(
        quantity: nextQuantity,
        total: item.price * nextQuantity,
        discountedTotal: item.discountedPrice * nextQuantity,
      );
    }

    _cart = _cart!.copyWith(products: updatedProducts);
    _recalculate();
    notifyListeners();
  }

  void _recalculate() {
    final products = List<CartProduct>.from(_cart?.products ?? const []);
    if (_cart == null) {
      _cart = _emptyCart(_userId ?? 0);
      return;
    }

    final total = products.fold<double>(0, (sum, item) => sum + item.total);
    final discountedTotal = products.fold<double>(
      0,
      (sum, item) => sum + item.discountedTotal,
    );

    _cart = _cart!.copyWith(
      products: products,
      total: total,
      discountedTotal: discountedTotal,
      totalProducts: products.length,
      totalQuantity: products.fold<int>(0, (sum, item) => sum + item.quantity),
    );
  }

  Cart _emptyCart(int userId) {
    return Cart(
      id: 0,
      products: const [],
      total: 0,
      discountedTotal: 0,
      userId: userId,
      totalProducts: 0,
      totalQuantity: 0,
    );
  }
}
