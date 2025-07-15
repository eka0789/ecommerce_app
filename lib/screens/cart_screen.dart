import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final Map<int, AnimationController> _controllers = {};

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Animation<double> _createShakeAnimation(int productId) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controllers[productId] = controller;
    return Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.cartItems[index];
                      Animation<double>? shakeAnimation;
                      if (_controllers.containsKey(item.product.id)) {
                        shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
                          CurvedAnimation(
                            parent: _controllers[item.product.id]!,
                            curve: Curves.elasticIn,
                          ),
                        );
                      }

                      return AnimatedBuilder(
                        animation: shakeAnimation ?? _createShakeAnimation(item.product.id),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              (shakeAnimation?.value ?? 0) * (index % 2 == 0 ? 1 : -1),
                              0,
                            ),
                            child: child,
                          );
                        },
                        child: ListTile(
                          leading: Image.network(
                            item.product.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 50),
                          ),
                          title: Text(
                            item.product.title.length > 30
                                ? '${item.product.title.substring(0, 30)}...'
                                : item.product.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            '\$${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  _controllers[item.product.id]?.forward().then((_) {
                                    _controllers[item.product.id]?.reverse();
                                  });
                                  cartProvider.updateQuantity(
                                    item.product.id,
                                    item.quantity - 1,
                                  );
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  _controllers[item.product.id]?.forward().then((_) {
                                    _controllers[item.product.id]?.reverse();
                                  });
                                  cartProvider.updateQuantity(
                                    item.product.id,
                                    item.quantity + 1,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cartProvider.removeFromCart(item.product.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: cartProvider.cartItems.isEmpty
                            ? null
                            : () async {
                                bool success = await cartProvider.processPayment();
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Payment Successful!')),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Payment Failed')),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Proceed to Payment'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}