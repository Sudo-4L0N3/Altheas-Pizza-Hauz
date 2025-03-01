import 'package:flutter/foundation.dart';
import '../../../../Model/product_model.dart';

class CartModel extends ChangeNotifier {
  final List<Map<Product, int>> _cartItems = [];

  List<Map<Product, int>> get cartItems => _cartItems;

  double get totalPrice => _cartItems.fold(0, (sum, item) => sum + (item.keys.first.price * item.values.first));

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.values.first);

  void addItem(Product product) {
    bool productExists = false;
    
    for (var item in _cartItems) {
      if (item.keys.first.id == product.id) {
        item[product] = item.values.first + 1;
        productExists = true;
        break;
      }
    }
    
    if (!productExists) {
      _cartItems.add({product: 1});
    }
    
    notifyListeners();
  }

  void removeItem(Product product) {
    for (var item in _cartItems) {
      if (item.keys.first.id == product.id) {
        if (item.values.first > 1) {
          item[product] = item.values.first - 1;
        } else {
          _cartItems.remove(item);
        }
        break;
      }
    }
    
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
