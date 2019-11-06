import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class CreateNegociacaoScreen extends StatefulWidget {
  static const routeName = '/create-negociacao';

  @override
  _CreateNegociacaoScreenState createState() => _CreateNegociacaoScreenState();
}

class _CreateNegociacaoScreenState extends State<CreateNegociacaoScreen> {
  String _dropdownValue = 'Primeira Opção';

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
        title: Text('Nova Negociação'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 200,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.image),
                  SizedBox(width: 30),
                  Text(
                    'Item: ${loadedProduct.nome}'
                  ),
                ],
              )
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                    'Item para trocar:'
                  ),
                SizedBox(width: 15),
                DropdownButton<String>(
                  value: _dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    color: Colors.deepOrangeAccent
                  ),
                  underline: Container(
                    height: 2,
                    color: Colors.deepOrangeAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      _dropdownValue = newValue;
                    });
                  },
                  items: <String>['Primeira Opção', 'Segunda Opção', 'Terceira Opção', 'Quarta Opção']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              width: 250,
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Mensagem'),
                textInputAction: TextInputAction.next,
                // onSaved: (value) {
                //   _editedProduct = Product(
                //       nome: value,
                //       valor_aprox: _editedProduct.valor_aprox,
                //       categoria: _editedProduct.categoria,
                //       desejo: _editedProduct.desejo,
                //       id: _editedProduct.id,
                //       quant: _editedProduct.quant);
                // },
              ),
            ),
            SizedBox(
              height: 90,
            ),
            FlatButton(
              color: Colors.deepOrangeAccent,
              child: Text(
              'Iniciar Negociação'
              ),
              onPressed: (){}
            ),
            FlatButton(
              child: Text(
                'Cancelar'
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
