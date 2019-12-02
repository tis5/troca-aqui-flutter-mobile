import 'package:flutter/material.dart';
import 'package:chat/pages/photogrid/data.dart';
import 'package:chat/pages/photogrid/product_view.dart';
import 'package:chat/pages/photogrid/fullScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class PhotoGrid extends StatefulWidget {
  @override
  _PhotoGridState createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  Map item;


  String baseUrl =
      'https://639879217272486:to1_F4Y-jY9jYqHiLaS3RnrvaH8@api.cloudinary.com/v1_1/hn4majmaq/resources/image';

  //Replace API Key with your cloudinary API Key
  //and also replace API Secret key with your cloudinary API Secret key.

  //When done, your baseUrl should look like this url below
  //'https://123456789987654:azdRJBNv1B3TBQLI4rK4xK1dPXD@api.cloudinary.com/v1_1/demo/resources/image';

  Future<List<Resources>> getPhotos() async {
    return await http.get(baseUrl).then((response) {
      Data an = Data.fromJson(json.decode(response.body.toString()));
//      print(json.decode(response.body));
//      print(an.resources[0]);
      return an.resources;
    });
  }
  fetchGet(String id,Resources i) async  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  await http.get('https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/items/$id').then((response) {

      setState(() {
        this.item = json.decode(response.body);
      });

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProductView(i,json.decode(response.body),preferences)));

      return json.decode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items para trocas'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              List<Resources> resources = snapshot.data;
              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.74,
                shrinkWrap: false,
                children: resources.map((i) {
                  return GestureDetector(
                    onTap: () {
                      RegExp regraItem = new RegExp(r"i-.?\d+");
                      RegExp regraPessoa = new RegExp(r"p-.?\d+");
                      final id_item = regraItem.firstMatch(i.publicId).group(0).substring(2);

                      fetchGet(id_item,i);


                    },
                    child: Card(
                      elevation: 5.0,
                      child: Column(
                        children: <Widget>[
                          new ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Hero(
                              tag: i.secureUrl,
                              child: Image.network(
                                i.secureUrl.replaceAll(new RegExp(r'upload/'), 'upload/c_thumb,w_172/'),
                                width: MediaQuery.of(context).size.width,
                                height: 208,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
          return Center(child: CircularProgressIndicator());
        },
        future: getPhotos(),
      ),
    );
  }
}
