import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool favourite;
  // ignore: use_key_in_widget_constructors
  const ProductsGrid(
    this.favourite,
  );
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(
        context); //listener 1 listens on the entire provider Products() because I want the items
    final products = favourite ? productsData.favourites : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        // automatically disposes of the data that isn't required anymore
        //provider 2 --> creates provider for items inside the provider Products() [Nested providers]
        value: products[index],
        child: const ProductItem(),
        // products[index].id, products[index].title, products[index].imageUrl),
      ),
      itemCount: products.length,
    );
  }
}
