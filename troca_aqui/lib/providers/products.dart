import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    const url = 'https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/items';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as List<dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodData) {
        loadedProducts.add(Product(
          id:  prodData['id'],
          nome: prodData['nome'],
          categoria: prodData['categoria'],
          valor_aprox: prodData['valor_aprox'],
          desejo: prodData['desejo'],
          quant: prodData['quant'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    const url = 'https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/items'; //TODO
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'nome': product.nome,
          'categoria': product.categoria,
          'valor_aprox': product.valor_aprox,
          'desejo': product.desejo,
          'quant': product.quant,
        }),
      );
      // final newProduct = Product(
      //   id: json.decode(response.body)['id'], //TODO
      //   nome: product.nome,
      //   categoria: product.categoria,
      //   valor_aprox: product.valor_aprox,
      //   desejo: product.desejo,
      //   quant: product.quant,
      // );
      // _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = 'https://flutter-teste.firebaseio.com/items/$id.json'; //TODO
      await http.patch(url, //TODO
          body: json.encode({
            'nome': newProduct.nome,
            'categoria': newProduct.categoria,
            'valor_aprox': newProduct.valor_aprox,
            'desejo': newProduct.desejo,
            'quant': newProduct.quant,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://flutter-teste.firebaseio.com/items/$id.json'; //TODO
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Não houve como deletar o produto');
    }
    existingProduct = null;
  }
}
