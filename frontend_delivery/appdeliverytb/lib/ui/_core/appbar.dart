import 'package:appdeliverytb/provider/bag_provider.dart';
import 'package:appdeliverytb/ui/widgets/checkout/checkoutscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

AppBar getAppBar({
  required BuildContext context,
  String? title,
}) {
  BagProvider bagProvider = Provider.of<BagProvider>(context);

  // calcular total de itens no carrinho
  final totalItems = bagProvider.quantities.values.fold(0, (a, b) => a + b);

  return AppBar(
    title: title != null ? Text(title) : null,
    centerTitle: true,
    actions: [
      badges.Badge(
        showBadge: totalItems > 0,
        position: badges.BadgePosition.bottomStart(start: 0, bottom: 0),
        badgeContent: Text(
          totalItems.toString(),
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Checkoutscreen()),
            );
          },
          icon: const Icon(Icons.shopping_basket),
        ),
      ),
    ],
  );
}
