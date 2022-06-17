import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../providers/orders_provider.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  // ignore: use_key_in_widget_constructors
  const OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expand = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _expand ? min(widget.order.products.length + 200, 280) : 100,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.order.amount}'),
              subtitle: Text(
                  DateFormat('dd-MM-yyyy hh:mm').format(widget.order.dateTime)),
              trailing: IconButton(
                icon: Icon(_expand ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expand = !_expand;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height:
                  _expand ? min(widget.order.products.length + 100, 180) : 0,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color.fromARGB(33, 255, 109, 64),
              ),
              child: ListView(
                  children: widget.order.products
                      .map((e) => Container(
                            padding: const EdgeInsets.all(3),
                            margin: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${e.quantity} x \$${e.price}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                )
                              ],
                            ),
                          ))
                      .toList()),
            )
          ],
        ),
      ),
    );
  }
}
