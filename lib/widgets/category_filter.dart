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
        children: [
          _buildCategoryChip(context, 'All', productProvider, true),
          ...productProvider.categories.map((category) =>
              _buildCategoryChip(context, category.name, productProvider, false)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
      BuildContext context, String label, ProductProvider provider, bool isAll) {
    final isSelected = isAll
        ? provider.products.isNotEmpty &&
            provider.categories.isNotEmpty &&
            provider.products.every((product) =>
                provider.categories.any((category) => category.name == product.category))
        : provider.products.isNotEmpty &&
            provider.products.every((product) => product.category == label);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isSelected ? 1.0 : 0.6,
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              if (isAll) {
                provider.fetchProducts();
              } else {
                provider.fetchProductsByCategory(label);
              }
            }
          },
        ),
      ),
    );
  }
}