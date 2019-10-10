import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: ListTile(
          title: Text(product.nome),
          leading: CircleAvatar(
            child: Text(product.valor_aprox.toString()),
          ),
          trailing: Text(product.desejo),
        ),
    );
  }
}
