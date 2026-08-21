import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.userId});

  final int userId;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _service = CartService();
  final ProductService _productService = ProductService();
  Cart? _cart;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    // Enhancement 3: Render the cart belonging to the saved authenticated user.
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final carts = await _service.getCartsByUserId(widget.userId);
      if (!mounted) return;
      setState(() {
        _cart = carts.isEmpty ? null : carts.first;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart · User ${widget.userId}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(message: _error!, onRetry: _loadCart)
          : _cart == null || _cart!.products.isEmpty
          ? const Center(
              child: CustomText(text: 'Your cart is empty', fontSize: 16),
            )
          : _CartContent(
              cart: _cart!,
              onQuantityChanged: _changeQuantity,
              onProductTap: _openProductDetails,
            ),
      bottomNavigationBar:
          !_loading &&
              _error == null &&
              _cart != null &&
              _cart!.products.isNotEmpty
          ? _CartSummary(cart: _cart!)
          : null,
    );
  }

  Future<void> _changeQuantity(CartProduct product, int change) async {
    final cart = _cart;
    if (cart == null) return;

    final nextQuantity = product.quantity + change;
    if (nextQuantity < 0) return;

    final updatedProducts = cart.products
        .where((item) => item.id != product.id || nextQuantity > 0)
        .map((item) {
          if (item.id != product.id) return item;
          return item.copyWith(
            quantity: nextQuantity,
            total: item.price * nextQuantity,
            discountedTotal: item.discountedPrice * nextQuantity,
          );
        })
        .toList();
    final updatedCart = _cartWithCalculatedTotals(cart, updatedProducts);

    setState(() => _cart = updatedCart);
    try {
      // Enhancement 1: Quantity controls update the same cart endpoint from
      // inside cart_screen; decreasing quantity 1 removes the whole item.
      await _service.updateCart(
        cartId: cart.id,
        products: updatedProducts
            .map((item) => {'id': item.id, 'quantity': item.quantity})
            .toList(),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _cart = cart);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update cart: $error')));
    }
  }

  Future<void> _openProductDetails(CartProduct cartProduct) async {
    try {
      // Enhancement 1: Load the complete product so Cart uses the same
      // description shown by the Shop feed's detail screen.
      final product = await _productService.getProductById(cartProduct.id);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load product details: $error')),
      );
    }
  }

  Cart _cartWithCalculatedTotals(Cart cart, List<CartProduct> products) {
    return cart.copyWith(
      products: products,
      total: products.fold<double>(0, (sum, item) => sum + item.total),
      discountedTotal: products.fold<double>(
        0,
        (sum, item) => sum + item.discountedTotal,
      ),
      totalProducts: products.length,
      totalQuantity: products.fold<int>(0, (sum, item) => sum + item.quantity),
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({
    required this.cart,
    required this.onQuantityChanged,
    required this.onProductTap,
  });

  final Cart cart;
  final Future<void> Function(CartProduct product, int change)
  onQuantityChanged;
  final Future<void> Function(CartProduct product) onProductTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Text(
              'Your items',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              '${cart.totalQuantity} items',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...cart.products.map(
          (product) => _CartItem(
            product: product,
            onQuantityChanged: onQuantityChanged,
            onProductTap: onProductTap,
          ),
        ),
      ],
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Order summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${cart.totalQuantity} items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TotalRow(label: 'Subtotal', value: cart.total),
            const SizedBox(height: 6),
            _TotalRow(
              label: 'You save',
              value: cart.total - cart.discountedTotal,
              valueColor: Colors.green,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            _TotalRow(
              label: 'Total',
              value: cart.discountedTotal,
              emphasize: true,
            ),
            const SizedBox(height: 12),
            // Temporary order action kept visible above the tab navigation.
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order confirmation is temporary.'),
                  ),
                ),
                icon: const Icon(Icons.lock_outline, size: 18),
                label: const Text('Confirm Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.product,
    required this.onQuantityChanged,
    required this.onProductTap,
  });

  final CartProduct product;
  final Future<void> Function(CartProduct product, int change)
  onQuantityChanged;
  final Future<void> Function(CartProduct product) onProductTap;

  @override
  Widget build(BuildContext context) {
    // Enhancement 1: Cart items are clickable and reuse the existing detail screen.
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                // Enhancement 1: The product content opens the same detail
                // screen used by Shop; back returns to this Cart route.
                onTap: () => onProductTap(product),
                child: Row(
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: product.thumbnail.isEmpty
                            ? Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 30,
                                ),
                              )
                            : Image.network(
                                product.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    size: 30,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '\$${product.discountedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            '\$${product.price.toStringAsFixed(2)} each',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => onQuantityChanged(product, 1),
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Increase quantity',
                  ),
                  Text(
                    '${product.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => onQuantityChanged(product, -1),
                    icon: Icon(
                      product.quantity == 1
                          ? Icons.delete_outline
                          : Icons.remove_circle_outline,
                    ),
                    tooltip: product.quantity == 1
                        ? 'Remove item'
                        : 'Decrease quantity',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final double value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
      fontSize: emphasize ? 18 : 14,
      color: valueColor,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: emphasize ? style : null),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
