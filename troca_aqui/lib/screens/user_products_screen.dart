import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user-products';

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  var _isLoading = false;
  var _isInit = true;

  @override
  void didChangeDependencies(){
    if(_isInit){
      _isLoading = true;
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: (_, i) => Column(
                  children: [
                    UserProductItem(
                      productsData.items[i].id,
                      productsData.items[i].nome,
                      productsData.items[i].valor_aprox,
                    ),
                    Divider(),
                  ],
                ),
          ),
        ),
    );

    // final productsData = Provider.of<Products>(context);
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Meus Produtos'),
    //     actions: <Widget>[
    //       IconButton(
    //         icon: const Icon(Icons.add),
    //         onPressed: () {
    //           Navigator.of(context).pushNamed(EditProductScreen.routeName);
    //         },
    //       ),
    //     ],
    //   ),
    //   drawer: AppDrawer(),
    //   body: RefreshIndicator(
    //     onRefresh: () => _refreshProducts(context),
    //     child: Padding(
    //       padding: EdgeInsets.all(8),
    //       child: ListView.builder(
    //         itemCount: productsData.items.length,
    //         itemBuilder: (_, i) => Column(
    //               children: [
    //                 UserProductItem(
    //                   productsData.items[i].id.toString(),
    //                   productsData.items[i].nome,
    //                   productsData.items[i].valor_aprox,
    //                 ),
    //                 Divider(),
    //               ],
    //             ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
