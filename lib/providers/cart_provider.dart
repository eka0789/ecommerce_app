import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  List<Cart> _cartItems = [];

  List<Cart> get cartItems => _cartItems;

  void addToCart(Product product) {
    final existingItem = _cartItems.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => Cart(product: product),
    );
    if (!_cartItems.contains(existingItem)) {
      _cartItems.add(existingItem);
    } else {
      existingItem.quantity++;
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final item = _cartItems.firstWhere((item) => item.product.id == productId);
    if (quantity > 0) {
      item.quantity = quantity;
    } else {
      _cartItems.remove(item);
    }
    notifyListeners();
  }

  double get totalPrice {
    return _cartItems.fold(
        0, (sum, item) => sum + item.product.price * item.quantity);
  }

  Future<bool> processPayment() async {
    // Simulate payment processing with a 2-second delay
    await Future.delayed(const Duration(seconds: 2));
    _cartItems.clear();
    notifyListeners();
    return true;
  }
}