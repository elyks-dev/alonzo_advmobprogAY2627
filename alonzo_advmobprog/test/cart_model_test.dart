import 'package:flutter_test/flutter_test.dart';

import '../lib/models/cart.dart';
import '../lib/models/product.dart';
import '../lib/providers/cart_provider.dart';

void main() {
  test('Cart parses cart totals and products', () {
    final cart = Cart.fromJson({
      'id': 1,
      'userId': 6,
      'total': 100,
      'discountedTotal': 90.5,
      'totalProducts': 1,
      'totalQuantity': 2,
      'products': [
        {
          'id': 1,
          'title': 'Phone',
          'price': 50,
          'quantity': 2,
          'total': 100,
          'discountPercentage': 9.5,
          'discountedTotal': 90.5,
          'thumbnail': 'https://example.com/phone.png',
        },
      ],
    });

    expect(cart.userId, 6);
    expect(cart.totalQuantity, 2);
    expect(cart.products.single.toProduct().id, '1');
    expect(cart.products.single.toProduct().title, 'Phone');
  });

  test('CartProvider tracks local cart additions and quantity updates', () async {
    final provider = CartProvider();
    await provider.loadCart(7);

    final product = Product(
      id: '15',
      title: 'Wireless Mouse',
      description: 'Ergonomic mouse',
      price: 24.99,
      image: 'https://example.com/mouse.png',
    );

    await provider.addProduct(product);
    expect(provider.products.length, 1);
    expect(provider.totalQuantity, 1);
    expect(provider.cart?.products.single.quantity, 1);

    provider.changeQuantity(provider.products.first, 1);
    expect(provider.totalQuantity, 2);

    provider.changeQuantity(provider.products.first, -1);
    expect(provider.totalQuantity, 1);

    provider.changeQuantity(provider.products.first, -1);
    expect(provider.products, isEmpty);
    expect(provider.total, 0.0);
  });
}
