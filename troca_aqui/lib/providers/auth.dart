import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();


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
    saveIDPessoa(json.decode(responseCreate.body));
    saveToken();
  }

  saveIDPessoa(Map response) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(response['id']);
    prefs.setInt('id_pessoa',response['id']);
    prefs.setString('nome_pessoa',response['nome']);

  }

  saveToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _firebaseMessaging.getToken().then((token) {
      print('token');
      print(token);

      final urltoken = 'https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/tokens';
      final responsetoken =  http.post(
        urltoken,
        headers: {"Content-type": "application/json"},
        body: json.encode(
          {"token":
            {
              "token": token.toString(),
              "pessoa_id": prefs.getInt('id_pessoa')
            }
          },
        ),
      );




    });



  }




}
