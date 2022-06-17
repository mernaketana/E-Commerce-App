import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/the_drawer.dart';
import '../providers/orders_provider.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  static const routeName = 'orders-screen';

//   @override
//   State<OrdersScreen> createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
  // var _isLoading = false;

  // @override
  // void initState() {
  //   super.initState();
  //   Provider.of<Orders>(context, listen: false).fetchProducts().then((value) {
  //     // We can use of(context) here because we set listen to false
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // final orders = Provider.of<Orders>(context);

    return Scaffold(
        drawer: const TheDrawer(),
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        body: FutureBuilder(
          // we are doing this instead of turning the widget into a stateful one just to implement _isLoading
          future: Provider.of<Orders>(context, listen: false).fetchProducts(),
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapShot.error != null) {
                return const Center(
                  child: Text(''),
                );
              } else {
                return Consumer<Orders>(
                  builder: ((context, value, _) {
                    return ListView.builder(
                      itemBuilder: (context, index) =>
                          OrderItem(value.orders[index]),
                      itemCount: value.orders.length,
                    );
                  }),
                );
              }
            }
          },
        ));
  }
}
