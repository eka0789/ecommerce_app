import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String _sortOption = 'none';
  bool _filterHighRating = false;

  List<Product> get products {
    List<Product> filteredProducts = _filterHighRating
        ? _products.where((product) => product.rating >= 4.0).toList()
        : List.from(_products);
    if (_sortOption == 'priceLowToHigh') {
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'priceHighToLow') {
      filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    }
    return filteredProducts;
  }

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get sortOption => _sortOption;
  bool get filterHighRating => _filterHighRating;

  final ApiService _apiService = ApiService();

  ProductProvider() {
    _loadProducts();
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
            (!_filterHighRating || product.rating >= 4.0))
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
}