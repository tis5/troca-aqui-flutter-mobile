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

  Product findById(int id) {
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

  Future<int> addProduct(Product product) async {
    const url = 'https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/items';
    try {
      final response = await http.post(
        url,
        headers: {"Content-type": "application/json"},
        body: json.encode({"item":{
          'nome': product.nome,
          'categoria': product.categoria,
          'valor_aprox': product.valor_aprox,
          'desejo': product.desejo,
          'quant': product.quant, 
          "pessoa_id": 1,
          "disp": true
        }}),
      );
      // print(response.body);
      final newProduct = Product(
        id: json.decode(response.body)['id'],
        nome: product.nome,
        categoria: product.categoria,
        valor_aprox: product.valor_aprox,
        desejo: product.desejo,
        quant: product.quant,
      );
      _items.add(newProduct);
      notifyListeners();

      return json.decode(response.body)['id'];

    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(int id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = 'https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/items/$id'; 
      await http.patch(
        url,
        headers: {"Content-type": "application/json"},
        body: json.encode({"item":{
          'nome': newProduct.nome,
          'categoria': newProduct.categoria,
          'valor_aprox': newProduct.valor_aprox,
          'desejo': newProduct.desejo,
          'quant': newProduct.quant
        }}));
      _items[prodIndex] = newProduct;
      print(newProduct.nome); // correto
      print(newProduct.categoria); // esta recebendo desejo
      print(newProduct.valor_aprox); //esta recebendo quant
      print(newProduct.desejo); // null
      print(newProduct.quant); // sempre zero
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(int id) async {
    final url = 'https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/items/$id';
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
