import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Review> _reviews = [];
  bool _isLoading = false;
  String _sortOption = 'none';
  bool _filterHighRating = false;
  String? _priceRangeFilter;

  List<Product> get products {
    List<Product> filteredProducts = _filterHighRating
        ? _products.where((product) => product.rating >= 4.0).toList()
        : List.from(_products);
    if (_priceRangeFilter != null) {
      if (_priceRangeFilter == '0-50') {
        filteredProducts = filteredProducts.where((product) => product.price <= 50).toList();
      } else if (_priceRangeFilter == '50-100') {
        filteredProducts = filteredProducts
            .where((product) => product.price > 50 && product.price <= 100)
            .toList();
      } else if (_priceRangeFilter == '100+') {
        filteredProducts = filteredProducts.where((product) => product.price > 100).toList();
      }
    }
    if (_sortOption == 'priceLowToHigh') {
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'priceHighToLow') {
      filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    }
    return filteredProducts;
  }

  List<Category> get categories => _categories;
  List<Review> getReviews(int productId) =>
      _reviews.where((review) => review.productId == productId).toList();
  bool get isLoading => _isLoading;
  String get sortOption => _sortOption;
  bool get filterHighRating => _filterHighRating;
  String? get priceRangeFilter => _priceRangeFilter;

  final ApiService _apiService = ApiService();

  ProductProvider() {
    _loadProducts();
    _loadReviews();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _apiService.fetchProducts();
      await _saveProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _apiService.fetchCategories();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _apiService.fetchProductsByCategory(category);
      await _saveProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  List<Product> searchProducts(String query) {
    List<Product> filteredProducts = _products
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()) &&
            (!_filterHighRating || product.rating >= 4.0) &&
            (_priceRangeFilter == null ||
                (_priceRangeFilter == '0-50' && product.price <= 50) ||
                (_priceRangeFilter == '50-100' &&
                    product.price > 50 &&
                    product.price <= 100) ||
                (_priceRangeFilter == '100+' && product.price > 100)))
        .toList();
    if (_sortOption == 'priceLowToHigh') {
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'priceHighToLow') {
      filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    }
    return filteredProducts;
  }

  void setSortOption(String option) {
    _sortOption = option;
    notifyListeners();
  }

  void toggleHighRatingFilter(bool value) {
    _filterHighRating = value;
    notifyListeners();
  }

  void setPriceRangeFilter(String? range) {
    _priceRangeFilter = range;
    notifyListeners();
  }

  void addReview(Review review) {
    _reviews.add(review);
    _saveReviews();
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productJson = _products.map((product) => product.toJson()).toList();
    await prefs.setString('products', json.encode(productJson));
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productJson = prefs.getString('products');
    if (productJson != null) {
      final List<dynamic> decoded = json.decode(productJson);
      _products = decoded.map((json) => Product.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewJson = _reviews.map((review) => review.toJson()).toList();
    await prefs.setString('reviews', json.encode(reviewJson));
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewJson = prefs.getString('reviews');
    if (reviewJson != null) {
      final List<dynamic> decoded = json.decode(reviewJson);
      _reviews = decoded.map((json) => Review.fromJson(json)).toList();
      notifyListeners();
    }
  }
}