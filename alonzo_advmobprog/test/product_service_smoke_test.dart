import 'package:flutter_test/flutter_test.dart';

import '../lib/services/product_service.dart';

void main() {
  test('ProductService fetches products from DummyJSON', () async {
    final service = ProductService(baseHost: 'https://dummyjson.com');
    final products = await service.getAllProducts();
    expect(products, isNotEmpty);
  }, timeout: Timeout(Duration(seconds: 15)));
}
