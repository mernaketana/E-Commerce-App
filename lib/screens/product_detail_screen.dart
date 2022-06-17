import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // ProductDetailScreen(this.title);
  const ProductDetailScreen({Key? key}) : super(key: key);
  static const routeName = 'product-details-screen';

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String;
    final loadedProduct = Provider.of<Products>(
      //listener 4 on the provider Products() which includes the list of products
      context,
      listen:
          false, //this means that this widget won't rebuild if a change happens in the Products provider
    ).findById(id);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(// slivers are scrollable areas on the screen
          slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 300, //when it's not the appbar but the image
          pinned: true, //the appbar will always be visible when we scroll
          flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ) // the part that we won't always see
              ), //what is inside the appbar
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          Container(
            decoration: const BoxDecoration(
                color: Color.fromARGB(185, 0, 0, 0),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5))),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 300,
                  child: Text(
                    loadedProduct.description,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                ),
                Text(
                  '\$${loadedProduct.price}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ])), //delegate tells it how to renders the content of the list
      ]),
    );
  }
}
