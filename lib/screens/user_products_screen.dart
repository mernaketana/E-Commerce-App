import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_add_product_screen.dart';
import '../providers/products_provider.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);
  static const routeName = 'user-products-screen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final products = Provider.of<Products>(context);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
              icon: const Icon(Icons.arrow_back)),
          title: const Text('Your Products'),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    EditAddProductScreen.routeName,
                  );
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: FutureBuilder(
          //I don't remember it
          future: _refreshProducts(context),
          builder: (ctx, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: Consumer<Products>(
                        builder: (context, value, _) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                            itemBuilder: (_, index) => Column(
                              children: <Widget>[
                                UserProductItem(
                                    value.items[index].id,
                                    value.items[index].title,
                                    value.items[index].imageUrl),
                                const Divider(),
                              ],
                            ),
                            itemCount: value.items.length,
                          ),
                        ),
                      ),
                    ),
        ));
  }
}
