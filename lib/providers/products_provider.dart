import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import './auth.dart';

class Product with ChangeNotifier {
  //provider 3 on the list of products
  //We are usoing a changenotifier here to use toggleFavourite
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product(
      {required this.id,
      required this.description,
      required this.imageUrl,
      this.isFavourite = false,
      required this.price,
      required this.title});

  Future<void> toggleFavourite(String token, String userId) async {
    final oldStatus = isFavourite;
    final url = Uri.parse(
        'https://my-shop-flutter-app-f21c3-default-rtdb.europe-west1.firebasedatabase.app/favourites/$userId/$id.json?auth=$token');
    final response = await http.put(url,
        body: json.encode(isFavourite)); //to avoid redundancy
    if (response.statusCode >= 400) {
      isFavourite = oldStatus;
      notifyListeners();
      throw HttpException('Operation Failed');
    } else {
      isFavourite = !isFavourite;
      notifyListeners();
    }
  }
}

class Products with ChangeNotifier {
  List<Product> _items = [];
  late String authToken;
  late String userId;

// for main to get the token and the user id from auth
  void recieveToken(Auth auth, List<Product> items) {
    authToken = auth.token;
    userId = auth.userId;
    _items = items.isEmpty ? [] : items;
  }

  List<Product> get items {
    // if (_favourites == true) {
    //   return _items
    //       .where((element) => element.isFavourite == _favourites)
    //       .toList();
    // } else {
    return [..._items];
    // we only return a copy so that it cannot be changed outside of this class so that we can trigger notifyListeners
  }

  List<Product> get favourites {
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addProduct(Product product) async {
    // async automatically wraps the code in a Future therefore we don't have to use return anymore as it returns a future automatically
    final url = Uri.parse(
        'https://my-shop-flutter-app-f21c3-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      // used with synchronous code and since our code now looks as if it's synchronous it's used for codes that may face runtime errors such as codes that depend on user input or on internet connection
      final response =
          await http // it doesn't change how dart works, it doesn't actually stop the code but it wraps it in a then behind the scene however it looks as thought it stops code execution to wait for this block of code
              .post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId,
        }),
      );
      // the following code will only execute once the previos one is done
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price,
          title: product.title);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      // ignore: avoid_print
      print(error);
      rethrow;
    }
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filter = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://my-shop-flutter-app-f21c3-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filter');
    try {
      final response = await http.get(
        url,
      );
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      // ignore: unnecessary_null_comparison
      if (data == null) {
        // when I use .isEmpty it doesn't work
        return;
      }
      final favourites = await http.get(Uri.parse(
          'https://my-shop-flutter-app-f21c3-default-rtdb.europe-west1.firebasedatabase.app/favourites/$userId.json?auth=$authToken'));
      final favouriteData = json.decode(favourites.body);
      data.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            title: prodData['title'],
            isFavourite: favouriteData == null
                ? false
                : favouriteData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> update(String id, Product newProduct) async {
    final _productIndex = _items.indexWhere((element) => element.id == id);
    if (_productIndex >= 0) {
      final url = Uri.parse(
          'https://my-shop-flutter-app-f21c3-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[_productIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    // http delete doesn't threow an error
    // if deleting fails the server sends back status codes to confirm whether the operation succeeded or not
    // 200 and 201 signal that everything has worked
    //300 signal that you were redirected
    // 400 and 500 singnal that something went wrong
    // for get and post, an error is thrown for status codes bigger than or equal to 400 which is how we catch it
    // for delete this doesn't happen
    final url = Uri.parse(
        'https://my-shop-flutter-app-f21c3-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[
        existingProductIndex]; //restores a reference to the product that will be deleted
    _items.removeAt(
        existingProductIndex); //removes it from the list but not from the memory
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    } else {
      existingProduct = null;
    }
    // .catchError((_) {
    //   _items.insert(existingProductIndex,
    //       existingProduct!); //This is optimistic updating because it readds this product in the case that its removal fails
    //   notifyListeners();
    // }
  }
}
