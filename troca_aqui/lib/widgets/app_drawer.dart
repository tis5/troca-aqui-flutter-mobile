import 'package:chat/pages/photogrid/photogrid.dart';

import '../pages/home_page_profile.dart';
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
            leading: Icon(Icons.verified_user),
            title: Text('Perfil'),
            onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePageProfile()),
            );
          },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Meus Items'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserTabsScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Items'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhotoGrid()),
              );
            },
          ),
        ],
      ),
    );
  }
}
