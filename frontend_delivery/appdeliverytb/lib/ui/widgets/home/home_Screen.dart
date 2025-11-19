import 'package:appdeliverytb/data/categories_data.dart';
import 'package:appdeliverytb/data/restaurant_data.dart';
import 'package:appdeliverytb/model/restaurant.dart';
import 'package:appdeliverytb/ui/_core/app_colors.dart';
import 'package:appdeliverytb/ui/widgets/home/widgets/category_widget.dart';
import 'package:appdeliverytb/ui/widgets/home/widgets/restaurant_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appdeliverytb/ui/widgets/custom_drawer.dart';
import 'package:appdeliverytb/provider/user_provider.dart'; // <- não esqueça disso

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    RestaurantData restaurantData = Provider.of<RestaurantData>(context);

    return Scaffold(
      drawer: Consumer<UserProvider>(
        builder: (context, user, child) {
          return CustomDrawer(
            userName: user.userName.isEmpty ? "Visitante" : user.userName,
            onLogout: () {
              user.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          );
        },
      ),

      appBar: AppBar(
        title: const Text("App delivery"),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              spacing: 32,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/logo.png', width: 147),
                const Text('Boas vindas !'),
                const Text('Escolha por categoria'),

                // CATEGORIAS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: List.generate(
                      CategoriesData.listCategories.length,
                      (index) => CategoryWidget(
                        category: CategoriesData.listCategories[index],
                      ),
                    ),
                  ),
                ),

                Image.asset('assets/banners/banner_promo.png'),

                Text(
                  'Bem avaliados',
                  style: TextStyle(
                    color: AppColors.mainColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // RESTAURANTES
                Column(
                  spacing: 16,
                  children: List.generate(
                    restaurantData.listRestaurant.length,
                    (index) {
                      Restaurant restaurant =
                          restaurantData.listRestaurant[index];
                      return RestaurantWidget(restaurant: restaurant);
                    },
                  ),
                ),

                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
