import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/edit_add_product_screen.dart';
import '../providers/products_provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  // ignore: use_key_in_widget_constructors
  const UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
      trailing: SizedBox(
        width: 100,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                        EditAddProductScreen.routeName,
                        arguments: id);
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.grey,
                  )),
              IconButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                                'Are you sure you want to delete this item?'),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('No')),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop(true);
                                    try {
                                      await Provider.of<Products>(
                                        context,
                                        listen: false,
                                      ).delete(id);
                                    } catch (error) {
                                      scaffold.showSnackBar(const SnackBar(
                                          content: Text(
                                        'Deleting Failed',
                                        textAlign: TextAlign.center,
                                      )));
                                    }
                                  },
                                  child: const Text('Yes'))
                            ],
                          );
                        });
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  )),
            ]),
      ),
    );
  }
}
