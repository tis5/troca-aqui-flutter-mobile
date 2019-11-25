import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {

  Future<void> signup(String email, String password, String nome, String cidade, String dataNascimento, String telefone) async {
    final urlRegister = 'https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/registrations';
    final responseRegister = await http.post(
      urlRegister,
      headers: {"Content-type": "application/json"},
      body: json.encode(
        {"user":
          {
            'email': email,
            'password': password,
          }
        },
      ),
    );
    print(json.decode(responseRegister.body));

    final urlCreate = 'https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/pessoas';
    final responseCreate = await http.post(
      urlCreate,
      headers: {"Content-type": "application/json"},
      body: json.encode(
        {
          "nome": nome, 
          "email": email,
          "cidade": cidade,
          "data_nasc": dataNascimento,
          "telefone": telefone
        },
      ),
    );
    print(json.decode(responseCreate.body));
  }

}
