import 'package:flutter/material.dart';
import 'package:appdeliverytb/model/product_model.dart';

class BagProvider with ChangeNotifier {
  final Map<int, ProductModel> _items = {};
  final Map<int, int> _quantities = {};

  Map<int, ProductModel> get items => _items;
  Map<int, int> get quantities => _quantities;

  void addItem(ProductModel product) {
    if (_items.containsKey(product.id)) {
      _quantities[product.id] = (_quantities[product.id] ?? 1) + 1;
    } else {
      _items[product.id] = product;
      _quantities[product.id] = 1;
    }
    notifyListeners();
  }

  void removeItem(int id) {
    if (!_items.containsKey(id)) return;
    _items.remove(id);
    _quantities.remove(id);
    notifyListeners();
  }

  void removeOne(ProductModel product) {
  if (!_quantities.containsKey(product.id)) return;

  final currentQty = _quantities[product.id] ?? 0;

  if (currentQty > 1) {
    _quantities[product.id] = currentQty - 1;
  } else {
    // Se só tiver 1, remove o item completamente
    _items.remove(product.id);
    _quantities.remove(product.id);
  }

  notifyListeners();
}

  void increaseQuantity(int id) {
    if (_quantities.containsKey(id)) {
      _quantities[id] = _quantities[id]! + 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(int id) {
    if (!_quantities.containsKey(id)) return;

    if (_quantities[id]! > 1) {
      _quantities[id] = _quantities[id]! - 1;
    } else {
      removeItem(id);
    }
    notifyListeners();
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach((id, product) {
      final quantity = _quantities[id] ?? 1;
      total += product.price * quantity;
    });
    return total;
  }

  void clearBag() {
    _items.clear();
    _quantities.clear();
    notifyListeners();
  }

  // Alias para manter compatibilidade com código antigo
  void clear() => clearBag();

  double get total => totalPrice;
}
