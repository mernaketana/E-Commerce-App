import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './helpers/custom_routes.dart';
import './widgets/splash_screen.dart';
import './providers/auth.dart';
import './screens/auth_screen.dart';
import './screens/edit_add_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/orders_screen.dart';
import './providers/orders_provider.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './providers/products_provider.dart';
import './providers/cart_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products(),
            update: (context, auth, previousProduct) =>
                previousProduct!..recieveToken(auth, previousProduct.items),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (context) => Orders(),
            update: (context, auth, previousOrders) =>
                previousOrders!..recieveToken(auth, previousOrders.orders),
          ),
        ],
        child: Consumer<Auth>(
          builder: ((context, value, _) => MaterialApp(
                title: 'My Shop',
                theme: ThemeData(
                  pageTransitionsTheme: PageTransitionsTheme(builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                    TargetPlatform.iOS: CustomPageTransitionBuilder(),
                  }),
                  fontFamily: 'lato',
                  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red)
                      .copyWith(secondary: Colors.white54),
                ),
                home: value.isAuth
                    ? const ProductsOverviewScreen()
                    : FutureBuilder(
                        future: value.tryAutoLogIn(),
                        builder: (context, snapshot) =>
                            snapshot.connectionState == ConnectionState.waiting
                                ? const SplashScreen()
                                : const AuthScreen(),
                      ),
                debugShowCheckedModeBanner: false,
                routes: {
                  ProductsOverviewScreen.routeName: (context) =>
                      const ProductsOverviewScreen(),
                  ProductDetailScreen.routeName: (context) =>
                      const ProductDetailScreen(),
                  CartScreen.routeName: (context) => const CartScreen(),
                  OrdersScreen.routeName: (context) => const OrdersScreen(),
                  UserProductsScreen.routeName: (context) =>
                      const UserProductsScreen(),
                  EditAddProductScreen.routeName: (context) =>
                      const EditAddProductScreen(),
                  AuthScreen.routeName: (context) => const AuthScreen(),
                },
              )),
        ));
  }
}


      //provider 1 --> creates provider for changes in provider Products()
      //video 193
      // allows us to register a class that the child widgets can listen to
      // whenever that class updates only the widgets that are listening to it are rebuilt
      
      // value: Products(), // since it doesn't depend on the value
