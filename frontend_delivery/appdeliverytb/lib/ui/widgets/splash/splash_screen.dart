// lib/ui/widgets/splash/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

/// Splash simples que redireciona para a tela de Login.
/// Ajuste o tempo se desejar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Aguarda 2 segundos e vai para /login
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Caso seu projeto possua assets/logo.png, será exibido.
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Se houver uma imagem 'assets/logo.png' será exibida; senão apenas o título.
            SizedBox(
              width: 140,
              height: 140,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const FlutterLogo(size: 120),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'App Delivery',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
