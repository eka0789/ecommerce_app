import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist.dart';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  List<Wishlist> _wishlistItems = [];

  List<Wishlist> get wishlistItems => _wishlistItems;

  WishlistProvider() {
    _loadWishlist();
  }

  void addToWishlist(Product product) {
    if (!_wishlistItems.any((item) => item.product.id == product.id)) {
      _wishlistItems.add(Wishlist(product: product));
      _saveWishlist();
      notifyListeners();
    }
  }

  void removeFromWishlist(int productId) {
    _wishlistItems.removeWhere((item) => item.product.id == productId);
    _saveWishlist();
    notifyListeners();
  }

  bool isInWishlist(int productId) {
    return _wishlistItems.any((item) => item.product.id == productId);
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = _wishlistItems
        .map((item) => item.product.toJson())
        .toList();
    await prefs.setString('wishlist', json.encode(wishlistJson));
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = prefs.getString('wishlist');
    if (wishlistJson != null) {
      final List<dynamic> decoded = json.decode(wishlistJson);
      _wishlistItems = decoded
          .map((json) => Wishlist(product: Product.fromJson(json)))
          .toList();
      notifyListeners();
    }
  }
}