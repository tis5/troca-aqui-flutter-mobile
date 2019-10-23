import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _valor_aproxFocusNode = FocusNode();
  final _categoriaFocusNode = FocusNode();
  final _desejoFocusNode = FocusNode();
  final _quantFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    nome: '',
    valor_aprox: 0,
    categoria: '',
    desejo: '',
    quant: 0,
  );
  var _initValues = {
    'nome': '',
    'categoria': '',
    'valor_aprox': '',
    'desejo': '',
    'quant': ''
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as int;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'nome': _editedProduct.nome,
          'categoria': _editedProduct.categoria,
          'valor_aprox': _editedProduct.valor_aprox.toString(),
          'desejo': _editedProduct.desejo,
          'quant': _editedProduct.quant.toString(),
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _valor_aproxFocusNode.dispose();
    _categoriaFocusNode.dispose();
    _desejoFocusNode.dispose();
    _quantFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Um erro ocorreu!'),
                content: Text('Algo errado aconteceu.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['nome'],
                      decoration: InputDecoration(labelText: 'Nome'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_valor_aproxFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe um nome';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            nome: value,
                            valor_aprox: _editedProduct.valor_aprox,
                            categoria: _editedProduct.categoria,
                            desejo: _editedProduct.desejo,
                            id: _editedProduct.id,
                            quant: _editedProduct.quant);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['valor_aprox'],
                      decoration: InputDecoration(labelText: 'Valor Aproximado'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _valor_aproxFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_categoriaFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe um valor';
                        }
                        if (double.tryParse(value.replaceAll(',', '.')) == null) {
                          return 'Informe um número válido';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            nome: _editedProduct.nome,
                            valor_aprox: double.parse(value.replaceAll(',', '.')),
                            categoria: _editedProduct.categoria,
                            desejo: _editedProduct.desejo,
                            id: _editedProduct.id,
                            quant: _editedProduct.quant);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['categoria'],
                      decoration: InputDecoration(labelText: 'Categoria'),
                      textInputAction: TextInputAction.next,
                      focusNode: _categoriaFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_desejoFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe uma categoria.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          nome: _editedProduct.nome,
                          valor_aprox: _editedProduct.valor_aprox,
                          categoria: value,
                          desejo: _editedProduct.desejo,
                          id: _editedProduct.id,
                          quant: _editedProduct.quant,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['desejo'],
                      decoration: InputDecoration(labelText: 'Item Desejado'),
                      focusNode: _desejoFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_quantFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe um item desejado.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          nome: _editedProduct.nome,
                          valor_aprox: _editedProduct.valor_aprox,
                          categoria: _editedProduct.categoria,
                          desejo: value,
                          id: _editedProduct.id,
                          quant: _editedProduct.quant,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['quant'],
                      decoration: InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                      focusNode: _quantFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe uma quantidade';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Informe um número válido';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            nome: _editedProduct.nome,
                            valor_aprox: _editedProduct.valor_aprox,
                            categoria: _editedProduct.categoria,
                            desejo: _editedProduct.desejo,
                            id: _editedProduct.id,
                            quant: int.parse(value));
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
