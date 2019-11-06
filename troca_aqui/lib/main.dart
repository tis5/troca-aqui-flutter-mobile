import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import './screens/create_negociacao_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/shop_tabs_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Products(),
        ),
      ],
      child: MaterialApp(
          title: 'Troca Aqui',
          theme: ThemeData(
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          // home: UserTabsScreen(),
          home: AuthScreen(),
          routes: {
            CreateNegociacaoScreen.routeName: (ctx) => CreateNegociacaoScreen(), 
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            // UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            UserTabsScreen.routeName: (ctx) => UserTabsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          }),
    );
  }
}
