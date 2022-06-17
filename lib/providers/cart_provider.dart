import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  int quantity;
  final double price;

  CartItem(
      {required this.id,
      required this.price,
      required this.quantity,
      required this.title});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  void addItem(String id, double price, String title) {
    if (_items.containsKey(id)) {
      _items.update(
          id,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1,
              title: existingCartItem.title));
    } else {
      _items.putIfAbsent(
          id,
          () => CartItem(
              id: DateTime.now().toString(),
              price: price,
              quantity: 1,
              title: title));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void undo(String id) {
    if (!_items.containsKey(id)) {
      return;
    }
    if (_items[id]!.quantity > 1) {
      _items.update(
          id,
          (value) => CartItem(
              id: value.id,
              price: value.price,
              quantity: value.quantity - 1,
              title: value.title));
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  double get totalAmout {
    var sum = 0.0;
    _items.forEach((key, item) {
      sum += item.price * item.quantity;
    });
    return sum;
  }
}
