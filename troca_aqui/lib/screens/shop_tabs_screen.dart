import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import 'edit_product_screen.dart';
import 'user_products_screen.dart';


class UserTabsScreen extends StatelessWidget {
  static const routeName = '/user-products-tab';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 3, child: Scaffold(
      appBar: AppBar(title: Text('Troca Aqui'), bottom: TabBar(tabs: <Widget>[
        Tab(text: "Meus Itens",),
        Tab(text: "Chats",),
        Tab(text: "Trocas",),
      ],),
      // actions: <Widget>[
      //     IconButton(
      //       icon: const Icon(Icons.add),
      //       onPressed: () {
      //         Navigator.of(context).pushNamed(EditProductScreen.routeName);
      //       },
      //     ),
      //   ],
      ),
      drawer: AppDrawer(),
      body: TabBarView(children: <Widget>[
        UserProductsScreen(), 
        Center(child: Text("chats"),), 
        Center(child: Text("trocas"),),
      ],),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
        ),
    ),);
  }
}