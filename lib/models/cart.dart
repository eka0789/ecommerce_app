import 'package:ecommerce_app/models/product.dart';

class Cart {
  final Product product;
  int quantity;

  Cart({required this.product, this.quantity = 1});
}