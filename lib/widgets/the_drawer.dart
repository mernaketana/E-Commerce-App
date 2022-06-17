import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../helpers/custom_routes.dart';
import '../providers/auth.dart';
import '../screens/user_products_screen.dart';
import '../screens/orders_screen.dart';

class TheDrawer extends StatelessWidget {
  const TheDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Hello there!'),
            automaticallyImplyLeading: false,
          ), //no back button
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_bag_sharp),
            title: const Text('Shop'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Orders'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(OrdersScreen.routeName),
            // Navigator.of(context).pushReplacement(CustomRoute(builder: (context) => const OrdersScreen(),),)
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage Products'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(UserProductsScreen.routeName),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logOut();
            },
          ),
        ],
      ),
    );
  }
}
