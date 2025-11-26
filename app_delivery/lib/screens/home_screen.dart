import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import '../models/restaurant.dart';
import '../widgets/network_image_widget.dart'; // Import new NetworkImageWidget for better CORS handling

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await ApiService.getCategories();
      final restaurants = await ApiService.getRestaurants();

      setState(() {
        _categories = categories;
        _restaurants = restaurants;
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
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery App'),
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            showBadge: cartProvider.itemCount > 0,
            badgeContent: Text(
              cartProvider.itemCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                child: Text('Hello, ${authProvider.username}!'),
                enabled: false,
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
                onTap: () async {
                  await authProvider.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        ],
      ),
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
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_categories.isNotEmpty) _buildCategoriesSection(),
                        _buildRestaurantsSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(category.icon),
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Restaurants',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        if (_restaurants.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No restaurants available'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = _restaurants[index];
              return _buildRestaurantCard(restaurant);
            },
          ),
      ],
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/restaurant',
            arguments: restaurant.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (restaurant.image.isNotEmpty)
              NetworkImageWidget(
                imageUrl: restaurant.image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 64),
                ),
              )
            else
              Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.restaurant, size: 64),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (restaurant.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      restaurant.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Free delivery',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
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

  IconData _getCategoryIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'pizza':
        return Icons.local_pizza;
      case 'burger':
        return Icons.lunch_dining;
      case 'coffee':
        return Icons.local_cafe;
      case 'dessert':
        return Icons.cake;
      case 'asian':
        return Icons.ramen_dining;
      default:
        return Icons.restaurant;
    }
  }
}
