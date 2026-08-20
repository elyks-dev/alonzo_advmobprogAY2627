import 'package:flutter_test/flutter_test.dart';

import '../lib/models/cart.dart';

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
}
