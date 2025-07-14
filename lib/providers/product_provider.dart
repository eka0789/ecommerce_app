import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String _sortOption = 'none';

  List<Product> get products {
    List<Product> sortedProducts = List.from(_products);
    if (_sortOption == 'priceLowToHigh') {
      sortedProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'priceHighToLow') {
      sortedProducts.sort((a, b) => b.price.compareTo(a.price));
    }
    return sortedProducts;
  }

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get sortOption => _sortOption;

  final ApiService _apiService = ApiService();

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _apiService.fetchProducts();
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
            product.title.toLowerCase().contains(query.toLowerCase()))
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
}