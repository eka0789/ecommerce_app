import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  List<Cart> _cartItems = [];

  List<Cart> get cartItems => _cartItems;

  CartProvider() {
    _loadCart();
  }

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
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final item = _cartItems.firstWhere((item) => item.product.id == productId);
    if (quantity > 0) {
      item.quantity = quantity;
    } else {
      _cartItems.remove(item);
    }
    _saveCart();
    notifyListeners();
  }

  double get totalPrice {
    return _cartItems.fold(
        0, (sum, item) => sum + item.product.price * item.quantity);
  }

  Future<bool> processPayment() async {
    await Future.delayed(const Duration(seconds: 2));
    _cartItems.clear();
    await _saveCart();
    notifyListeners();
    return true;
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = _cartItems
        .map((item) => {
              'product': item.product.toJson(),
              'quantity': item.quantity,
            })
        .toList();
    await prefs.setString('cart', json.encode(cartJson));
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart');
    if (cartJson != null) {
      final List<dynamic> decoded = json.decode(cartJson);
      _cartItems = decoded
          .map((json) => Cart(
                product: Product.fromJson(json['product']),
                quantity: json['quantity'],
              ))
          .toList();
      notifyListeners();
    }
  }
}