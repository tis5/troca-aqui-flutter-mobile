import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_client/cloudinary_client.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  int itemId;
  CloudinaryClient client = new CloudinaryClient('639879217272486', 'to1_F4Y-jY9jYqHiLaS3RnrvaH8','hn4majmaq');
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  void _clear() {
    setState(() => _image = null);
  }


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
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

        int responseId = await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
        print(responseId);

        try {
          if (_image != null){
            print('teste');
            var response = await client.uploadImage(_image.path,filename:'i-'+responseId.toString()+'p-'+prefs.getInt('id_pessoa').toString(),folder:'items');
            print(response);
          }
        } catch (e) {
          print("erro no upload de imagem");
        }

        // try {
        //   if (_image != null){
        //     var response = await client.uploadImage(_image.path, filename: responseId.toString());
        //     print(response);
        //   }
        // } catch (e) {
        //   print(e.toString());
        // }

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
                              return 'Informe um valor';
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
                              return 'Informe um valor_aprox';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Informe um número válido';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                nome: _editedProduct.nome,
                                valor_aprox: double.parse(value),
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
                          decoration: InputDecoration(labelText: 'Desejo'),
                          focusNode: _desejoFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_quantFocusNode);
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
                            if (double.tryParse(value) == null) {
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
                        // Center(
                        //   child: _image == null
                        //       ? Text('No image selected.')
                        //       : Image.file(_image),
                        // ),
                        if (_image != null) ...[

                          Image.file(_image),

                          Row(
                            children: <Widget>[
                              FlatButton(
                                child: Icon(Icons.delete),
                                onPressed: _clear,
                              ),
                            ],
                          ),
                        ] else ...[
                          IconButton(
                            icon: Icon(Icons.photo_camera),
                            onPressed: getImage,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
            ),
    );
  }
}
