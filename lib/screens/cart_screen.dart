import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './orders_screen.dart';
import '../providers/cart_provider.dart'
    show Cart; //So it doesn't import the CartItem
import '../widgets/cart_item.dart';
import '../providers/orders_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = 'cart-screen';

  @override
  Widget build(BuildContext context) {
    final cartItem = Provider.of<Cart>(context);
    final orders = Provider.of<Orders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text('\$${cartItem.totalAmout.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 17)),
                    const Spacer(),
                    OrderButton(cartItem: cartItem, orders: orders)
                  ]),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) => CartItem(
                id: cartItem.items.values
                    .toList()[index]
                    .id, //to turn the values of the map into a list
                price: cartItem.items.values.toList()[index].price,
                quantity: cartItem.items.values.toList()[index].quantity,
                title: cartItem.items.values.toList()[index].title,
                productId: cartItem.items.keys.toList()[index]),
            itemCount: cartItem.itemCount,
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cartItem,
    required this.orders,
  }) : super(key: key);

  final Cart cartItem;
  final Orders orders;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (widget.cartItem.totalAmout <= 0 || _isLoading == true)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await widget.orders.addOrder(
                  widget.cartItem.items.values.toList(),
                  widget.cartItem.totalAmout);
              setState(() {
                _isLoading = false;
              });
              widget.cartItem.clear();
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('Order Now!'),
    );
  }
}
