import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/restaurant.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/network_image_widget.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Restaurant? _restaurant;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final restaurants = await ApiService.getRestaurants();
      final restaurant = restaurants.firstWhere(
        (r) => r.id == widget.restaurantId,
      );

      setState(() {
        _restaurant = restaurant;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadRestaurant,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _restaurant == null
                  ? const Center(child: Text('Restaurant not found'))
                  : CustomScrollView(
                      slivers: [
                        _buildAppBar(),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _restaurant!.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (_restaurant!.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _restaurant!.description,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                Text(
                                  'Menu',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _restaurant!.products.isEmpty
                            ? const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Center(
                                    child: Text('No products available'),
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final product = _restaurant!.products[index];
                                    return _buildProductItem(product);
                                  },
                                  childCount: _restaurant!.products.length,
                                ),
                              ),
                      ],
                    ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _restaurant!.image.isNotEmpty
            ? NetworkImageWidget(
                imageUrl: _restaurant!.image,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 64),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 64),
              ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageWidget(
                  imageUrl: product.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                  ),
                  errorWidget: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.fastfood, size: 32),
                  ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fastfood, size: 32),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          cartProvider.addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              duration: const Duration(seconds: 1),
                              action: SnackBarAction(
                                label: 'View Cart',
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/cart');
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('Add'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
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
