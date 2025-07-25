import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final filteredProducts = productProvider.searchProducts(_query);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _query = '';
                });
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
        ),
        actions: [
          DropdownButton<String>(
            value: productProvider.sortOption,
            items: const [
              DropdownMenuItem(value: 'none', child: Text('Sort: Default')),
              DropdownMenuItem(value: 'priceLowToHigh', child: Text('Price: Low to High')),
              DropdownMenuItem(value: 'priceHighToLow', child: Text('Price: High to Low')),
            ],
            onChanged: (value) {
              if (value != null) {
                productProvider.setSortOption(value);
              }
            },
          ),
          IconButton(
            icon: Icon(
              productProvider.filterHighRating ? Icons.star : Icons.star_border,
              color: productProvider.filterHighRating ? Colors.amber : null,
            ),
            onPressed: () {
              productProvider.toggleHighRatingFilter(!productProvider.filterHighRating);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Filter by Price Range'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('All Prices'),
                        onTap: () {
                          productProvider.setPriceRangeFilter(null);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('\$0 - \$50'),
                        onTap: () {
                          productProvider.setPriceRangeFilter('0-50');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('\$50 - \$100'),
                        onTap: () {
                          productProvider.setPriceRangeFilter('50-100');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('\$100+'),
                        onTap: () {
                          productProvider.setPriceRangeFilter('100+');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: filteredProducts.isEmpty && _query.isNotEmpty
          ? const Center(child: Text('No products found'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: filteredProducts[index]);
              },
            ),
    );
  }
}