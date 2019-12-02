import 'package:flutter/material.dart';
import 'package:chat/screens/create_negociacao_screen.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context).settings.arguments as int;
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes - ${loadedProduct.nome}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 200,
              width: double.infinity,
              child: Icon(Icons.image)
            ),
            SizedBox(height: 30),
            Text(
              'Item: ${loadedProduct.nome}'
            ),
            SizedBox(height: 30),
            Text(
              'Categoria: ${loadedProduct.categoria}'
            ),
            SizedBox(height: 30),
            Text(
              'Valor Aproximado: \$${loadedProduct.valor_aprox}'
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Item de Interesse: ${loadedProduct.desejo}'
            ),
            SizedBox(
              height: 30,
            ),
             Text(
              'Quantidade: ${loadedProduct.quant}'
            ),
            SizedBox(
              height: 90,
            ),
            FlatButton(
              color: Colors.deepOrangeAccent,
              child: Text(
              'Negociar'
              ),
              onPressed:  () {
                Navigator.of(context).pushNamed(
                  CreateNegociacaoScreen.routeName,
                  arguments: productId,
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}
