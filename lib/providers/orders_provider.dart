import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/auth.dart';

import './cart_provider.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.amount,
      required this.dateTime,
      required this.id,
      required this.products});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  late String authToken;
  late String userId;

  void recieveToken(Auth auth, List<OrderItem> items) {
    authToken = auth.token;
    userId = auth.userId;
    _orders = items.isEmpty ? [] : items;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cart, double total) async {
    final url = Uri.parse(
        'https://my-shop-flutter-app-f21c3-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cart
              .map((e) => {
                    'id': e.id,
                    'quantity': e.quantity,
                    'price': e.price,
                    'title': e.title,
                  })
              .toList(),
        }),
      );
      _orders.insert(
          0,
          OrderItem(
              amount: total,
              dateTime: timeStamp,
              id: json.decode(response.body)['name'],
              products: cart));
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
        'https://my-shop-flutter-app-f21c3-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(
        url,
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrder = [];
      // ignore: unnecessary_null_comparison
      if (data == null) {
        return;
      }
      data.forEach((orderId, orderData) {
        loadedOrder.add(OrderItem(
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            id: orderId,
            products: (orderData['products'] as List<dynamic>)
                .map((e) => CartItem(
                    id: e['id'],
                    price: e['price'],
                    quantity: e['quantity'],
                    title: e['title']))
                .toList()));
      });
      _orders = loadedOrder.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
