import 'package:flutter/material.dart';
import '../models/wishlist.dart';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  List<Wishlist> _wishlistItems = [];

  List<Wishlist> get wishlistItems => _wishlistItems;

  void addToWishlist(Product product) {
    if (!_wishlistItems.any((item) => item.product.id == product.id)) {
      _wishlistItems.add(Wishlist(product: product));
      notifyListeners();
    }
  }

  void removeFromWishlist(int productId) {
    _wishlistItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  bool isInWishlist(int productId) {
    return _wishlistItems.any((item) => item.product.id == productId);
  }
}