import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final int id;
  final String nome;
  final String categoria;
  final double valor_aprox;
  final String desejo;
  final int quant;

  Product({
    @required this.id,
    @required this.nome,
    @required this.categoria,
    @required this.valor_aprox,
    @required this.desejo,
    @required this.quant,
  });
}
