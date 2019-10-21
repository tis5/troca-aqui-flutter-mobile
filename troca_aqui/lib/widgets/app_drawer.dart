import 'package:flutter/material.dart';

import '../screens/shop_tabs_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Bem Vindo!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Loja'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Meus Produtos'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserTabsScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
