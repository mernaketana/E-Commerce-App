import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/the_drawer.dart';
import '../screens/cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';

enum favourites {
  all,
  favs,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);
  static const routeName = 'products-overview';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavouritesOnly = false;
  var _isInit =
      true; //we implement this so that we make sure didChangeDependencies executes only one time
  var _isLoading = false;

  // @override
  // void initState() {
  //   super.initState();
  //   // Future.delayed(Duration.zero).then((_) {
  //   //   Provider.of<Products>(context).fetchProducts();
  //   // });
  // }

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      if (_isInit) {
        setState(() {
          _isLoading = true;
        });
        Provider.of<Products>(context).fetchProducts().then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
      _isInit = false;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const TheDrawer(),
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: ((_) => [
                  const PopupMenuItem(
                      child: Text('Favourites'), value: favourites.favs),
                  const PopupMenuItem(
                      child: Text('All'), value: favourites.all),
                ]),
            icon: const Icon(
              Icons.more_vert,
            ),
            onSelected: (favourites value) {
              setState(() {
                if (value == favourites.favs) {
                  _showFavouritesOnly = true;
                } else {
                  _showFavouritesOnly = false;
                }
              });
            },
          ),
          Consumer<Cart>(
              builder: (_, cart, child) => Badge(
                  child: child as Widget, value: cart.itemCount.toString()),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductsGrid(_showFavouritesOnly),
    );
  }
}
