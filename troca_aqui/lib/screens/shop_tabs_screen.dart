import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import 'edit_product_screen.dart';
import 'user_products_screen.dart';

class UserTabsScreen extends StatefulWidget {

  static const routeName = '/user-products-tab';

  @override
  _UserTabsScreenState createState() => _UserTabsScreenState();
}

class _UserTabsScreenState extends State<UserTabsScreen> with SingleTickerProviderStateMixin {
    TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Troca Aqui'),
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(text: "Meus Itens",),
              Tab(text: "Chats",),
              Tab(text: "Trocas",),
            ],
          ),
        ), 
        drawer: AppDrawer(),
        body: TabBarView(controller: _tabController, children: <Widget>[
        UserProductsScreen(), 
        Center(child: Text("chats"),), 
        Center(child: Text("trocas"),),
      ],),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _bottomButtons(),
      ),
    );


}

Widget _bottomButtons() {
    return _tabController.index == 0
        ? FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
          )
        : null;
  }
}








// class UserTabsScreen extends StatelessWidget {
//   static const routeName = '/user-products-tab';

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(length: 3, child: Scaffold(
//       appBar: AppBar(title: Text('Troca Aqui'), bottom: TabBar(tabs: <Widget>[
//         Tab(text: "Meus Itens",),
//         Tab(text: "Chats",),
//         Tab(text: "Trocas",),
//       ],),
//       // actions: <Widget>[
//       //     IconButton(
//       //       icon: const Icon(Icons.add),
//       //       onPressed: () {
//       //         Navigator.of(context).pushNamed(EditProductScreen.routeName);
//       //       },
//       //     ),
//       //   ],
//       ),
//       drawer: AppDrawer(),
//       body: TabBarView(children: <Widget>[
//         UserProductsScreen(), 
//         Center(child: Text("chats"),), 
//         Center(child: Text("trocas"),),
//       ],),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//               Navigator.of(context).pushNamed(EditProductScreen.routeName);
//             },
//         ),
//     ),);
//   }
// }