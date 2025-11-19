import 'package:appdeliverytb/data/restaurant_data.dart';
import 'package:appdeliverytb/ui/_core/app_theme.dart';
import 'package:appdeliverytb/provider/bag_provider.dart';
import 'package:appdeliverytb/provider/user_provider.dart';
import 'package:appdeliverytb/ui/widgets/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appdeliverytb/ui/widgets/auth/login_screen.dart';
import 'package:appdeliverytb/ui/widgets/home/home_screen.dart';
import 'package:appdeliverytb/ui/widgets/checkout/checkoutscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega restaurantes antes do app
  RestaurantData restaurantData = RestaurantData();
  await restaurantData.getRestaurant();

  runApp(
    MultiProvider(
      providers: [
        // Provider do usuário (para mostrar nome no Drawer)
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Provider da sacola
        ChangeNotifierProvider(create: (_) => BagProvider()),

        // Provider dos restaurantes (já carregado)
        ChangeNotifierProvider(create: (_) => restaurantData),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/checkout': (_) => const Checkoutscreen(),
      },
    );
  }
}
