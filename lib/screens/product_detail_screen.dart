import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _animateAndAddToCart(CartProvider cartProvider) {
    _controller.forward().then((_) {
      _controller.reverse();
      cartProvider.addToCart(widget.product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.title} added to cart')),
      );
    });
  }

  void _animateAndToggleWishlist(WishlistProvider wishlistProvider) {
    _controller.forward().then((_) {
      _controller.reverse();
      if (wishlistProvider.isInWishlist(widget.product.id)) {
        wishlistProvider.removeFromWishlist(widget.product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.product.title} removed from wishlist')),
        );
      } else {
        wishlistProvider.addToWishlist(widget.product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.product.title} added to wishlist')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final reviews = productProvider.getReviews(widget.product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.title.length > 20 ? '${widget.product.title.substring(0, 20)}...' : widget.product.title,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: IconButton(
              icon: Icon(
                wishlistProvider.isInWishlist(widget.product.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: wishlistProvider.isInWishlist(widget.product.id) ? Colors.red : null,
              ),
              onPressed: () => _animateAndToggleWishlist(wishlistProvider),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.product.rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product.reviewCount} reviews',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category: ${widget.product.category}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Reviews',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Based on ${reviews.length} reviews',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          if (reviews.isEmpty)
                            const Text('No reviews yet.'),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              return ListTile(
                                title: Text(review.userName),
                                subtitle: Text('${review.comment}\n${review.timestamp.toString().substring(0, 10)}'),
                                leading: const Icon(Icons.person),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          if (authProvider.isAuthenticated)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _reviewController,
                                  decoration: const InputDecoration(
                                    labelText: 'Add a review',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_reviewController.text.isNotEmpty) {
                                      productProvider.addReview(
                                        Review(
                                          productId: widget.product.id,
                                          userName: authProvider.userName ?? 'User',
                                          comment: _reviewController.text,
                                          timestamp: DateTime.now(),
                                        ),
                                      );
                                      _reviewController.clear();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Submit Review'),
                                ),
                              ],
                            )
                          else
                            const Text('Please log in to add a review.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: ElevatedButton(
                      onPressed: () => _animateAndAddToCart(cartProvider),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}