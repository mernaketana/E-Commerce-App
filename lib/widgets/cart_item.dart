import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final double price;
  final int quantity;
  final String title;
  final String productId;

  // ignore: use_key_in_widget_constructors
  const CartItem(
      {required this.id,
      required this.price,
      required this.quantity,
      required this.title,
      required this.productId});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(
      context,
      listen: false,
    );
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                title: const Text('Are you sure you want to delete this item?'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.of(c).pop(false);
                      },
                      child: const Text('No')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(c).pop(true);
                      },
                      child: const Text('Yes'))
                ],
              );
            });
      },
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        cart.removeItem(productId);
      },
      background: Container(
        color: Theme.of(context).errorColor,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(
                child: Text(
                  '\$$price',
                  style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.headline6?.color),
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 40,
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity).toStringAsFixed(2)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
