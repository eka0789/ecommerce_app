import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: productProvider.products.isNotEmpty &&
                productProvider.categories.isNotEmpty &&
                productProvider.products.every(
                    (product) => productProvider.categories.any((category) => category.name == product.category)),
            onSelected: (selected) {
              if (selected) {
                productProvider.fetchProducts();
              }
            },
          ),
          const SizedBox(width: 8),
          ...productProvider.categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: productProvider.products.isNotEmpty &&
                    productProvider.products.every((product) => product.category == category.name),
                onSelected: (selected) {
                  if (selected) {
                    productProvider.fetchProductsByCategory(category.name);
                  }
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}