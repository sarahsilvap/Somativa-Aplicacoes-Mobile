import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepOrange),
            accountName: Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text(""),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.deepOrange),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.store),
            title: const Text("Restaurantes"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text("Meus Pedidos"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("Endereços"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favoritos"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Pagamentos"),
            onTap: () {},
          ),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Sair",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: onLogout,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
