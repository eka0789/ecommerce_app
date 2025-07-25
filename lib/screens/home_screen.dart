import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/search_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/login_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/category_filter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (productProvider.products.isEmpty && !productProvider.isLoading) {
        productProvider.fetchProducts();
        productProvider.fetchCategories();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Elegant Store${authProvider.userName != null ? ' - ${authProvider.userName}' : ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.favorite_border),
                if (wishlistProvider.wishlistItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${wishlistProvider.wishlistItems.length}',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartProvider.cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cartProvider.cartItems.length}',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: CategoryFilter(),
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
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
                    const SizedBox(width: 8),
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
              ],
            ),
          ),
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? const Center(child: Text('No products available'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: productProvider.products[index],
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => productProvider.fetchProducts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}