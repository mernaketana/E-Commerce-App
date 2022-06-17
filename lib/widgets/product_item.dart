import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../screens/product_detail_screen.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final product = Provider.of<Product>(context,
        listen: false); //listener 3 for the Product model
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: (() {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          }),
          child: Hero(
            tag: product
                .id, // to know which image on the new page to float over should be unique for the image
            child: FadeInImage(
              placeholder:
                  const AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            // almost the same as Provider.of, it also helps when you want to rebuild only a subpart of a widget
            builder: (context, product, child) {
              return IconButton(
                  onPressed: () async {
                    try {
                      await product.toggleFavourite(auth.token, auth.userId);
                    } catch (error) {
                      scaffold.showSnackBar(SnackBar(
                          content: Text(error.toString(),
                              textAlign: TextAlign.center)));
                    }
                  },
                  icon: product.isFavourite
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : Icon(Icons.favorite,
                          color: theme.colorScheme.secondary));
            },
            // child: , // the child is a widget that won't change while rebuilding
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  'Item added to cart!',
                ),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    cart.undo(product.id);
                  },
                  textColor: Theme.of(context).colorScheme.primary,
                ),
              )); //We establish a connection to the nearest scaffold which is in the products overview
            },
            icon: const Icon(
              Icons.shopping_cart,
            ),
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
