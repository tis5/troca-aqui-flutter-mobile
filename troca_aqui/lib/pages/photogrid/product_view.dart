import 'package:flutter/material.dart';
import 'package:chat/pages/photogrid/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductView extends StatefulWidget {
  final Resources resources;
  final Map item;
  final SharedPreferences preferences;
  ProductView(this.resources,this.item,this.preferences);

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  var user;
  DocumentReference profileReference;
  final db = Firestore.instance;
  CollectionReference contactsReference;
  String selected = "blue";
  bool favourite = false;
  String id_pessoa;
  String id_item;
  String phone;
  String token;
  var pessoa;
  var item;

  _makePostRequest() async {
    // set up POST request arguments
    String url = 'https://fcm.googleapis.com/fcm/send';
    Map<String, String> headers = {"Content-type": "application/json",
      "Authorization":"key=AIzaSyDv-RRfjFDahzzNg172HqDoC3mJz5OmM2A"};
    String json = '{"to":"'+this.token +'","collapse_key": "type_a", '
        '"notification": {'
        ' "image":"'+widget.resources.secureUrl.replaceAll(new RegExp(r'upload/'),'upload/c_thumb,h_400,w_400/')+'",'
        ' "body" :"Seu item tem um solicitação de troca",'
        ' "title":"Negociação"}}';
    // make POST request
    print(json);
    final response = await http.post(url, headers: headers, body: json);
    // check the status code for the result
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    String body = response.body;


  }





  @override
initState() {
  super.initState();
  RegExp regraPessoa = new RegExp(r"p-.?\d+");
  final id_pessoa = regraPessoa.firstMatch(widget.resources.publicId).group(0).substring(2);

  getToken(id_pessoa);
  getPhone(id_pessoa);

  contactsReference = db
      .collection("users")
      .document(widget.preferences.getString('uid'))
      .collection('contacts');
  profileReference = db.collection("users").document(widget.preferences.getString('uid'));
  user = db.collection("users").document(widget.preferences.getString('uid'));

}
  getToken(String id)  {
    return  http.get('https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/tokenpessoa/$id').then((response) {

      var teste = json.decode(response.body);
      this.token =teste['token'];

      print(this.token);
      return json.decode(response.body);
    });
  }
  getPhone(String id)  {
    return  http.get('https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/pessoas/$id').then((response) {

      var pessoa = json.decode(response.body);
      this.phone =pessoa['telefone'];
      this.pessoa = pessoa;

      print(this.token);
      return json.decode(response.body);
    });
  }




  openChat(String phone) async {

        DocumentReference mobileRef = db
            .collection("mobiles")
            .document(phone.replaceAll(new RegExp(r'[^\w\s]+'), ''));
        await mobileRef.get().then((documentReference) {
          if (documentReference.exists) {
            contactsReference.add({
              'uid': documentReference['uid'],
              'name': pessoa['nome'],
              'mobile': phone.replaceAll(new RegExp(r'[^\w\s]+'), ''),
            });
          } else {
            print('User Not Registered');
          }
        }).catchError((e) {});

  }

  fetchGet(String id)  {
    return  http.get('https://troca-aqui-api-e7p5jefkcq-uc.a.run.app/items/$id').then((response) {

      setState(() {
        this.item = json.decode(response.body);
      });

      print(this.item);
      return json.decode(response.body);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //The whole application area
      body:SafeArea(
        child: Column(
          children: <Widget>[
            appBar(),
            hero(),
            spaceVertical(20),
            //Center Items
            Expanded (
              child: sections(),
            ),
            //Bottom Button
            purchase()
          ],
        ),
      ),
    );
  }


  ///************** Hero   ***************************************************/

  Widget hero(){
    return Container(
      child: Stack(
        children: <Widget>[

          Image.network(widget.resources.secureUrl.replaceAll(new RegExp(r'upload/'), 'upload/c_thumb,w_400/'),
          width: 400,height: 300,), //This
          // should be a paged
          // view.

          Positioned(child: FloatingActionButton(
              elevation: 2,
              child:Image.asset(favourite? "images/heart_icon.png" : "images/heart_icon_disabled.png",
                width: 30,
                height: 30,),
              backgroundColor: Colors.white,
              onPressed: (){
                setState(() {
                  favourite = !favourite;
                });
              }
          ),
            bottom: 0,
            right: 20,
          ),

        ],
      ),
    );
  }


  Widget appBar(){
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.asset("images/back_button.png"),
          Container(
            child: Column(
              children: <Widget>[
                Text("Troca-Aqui",style: TextStyle(
                    fontWeight: FontWeight.w100,
                    fontSize: 14
                ),),
                Text("Item", style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2F3E)
                ),),
              ],
            ),
          ),
          Image.asset("images/bag_button.png", width: 27, height: 30,),
        ],
      ),
    );
  }

  /***** End */






  ///************ SECTIONS  *************************************************/

  Widget sections(){
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          description(),
          spaceVertical(20),
          property(),
        ],
      ),
    );
  }

  Widget description(){
    return Text(widget.item['nome'].toString(),
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: 30, color: Color(0xFF2F2F3E)),);
  }

  Widget property(){
    return Container(
      padding: EdgeInsets.only(right: 20,left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Desejo", textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2F3E)
                ),
              ),
              spaceVertical(2),
              Container(
                width: 70,
                padding: EdgeInsets.all(10),
                color: Color(0xFFF5F8FB),
                child: Text(widget.item['desejo'].toString(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F3E)
                  ),
                ),
              )

            ],
          ),
          size()
        ],
      ),
    );
  }



  Widget size(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Valor", textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F2F3E)
          ),
        ),
        spaceVertical(2),
        Container(
          width: 70,
          padding: EdgeInsets.all(10),
          color: Color(0xFFF5F8FB),
          child: Text(widget.item['valor_aprox'].toString(),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F2F3E)
            ),
          ),
        )


      ],
    );
  }

  /***** End */



  ///************** BOTTOM BUTTON ********************************************/
  Widget purchase(){
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.deepOrange,
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width-50,
              padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
              onPressed: () {_makePostRequest();},
              child: Text("trocar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white ),
            ),
          )
          )
        ],
      ),
    );
  }

  /***** End */





  ///************** UTILITY WIDGET ********************************************/

  Widget spaceVertical(double size){
    return SizedBox(height: size,);
  }

  Widget spaceHorizontal(double size){
    return SizedBox(width: size,);
  }
/***** End */
}


class ColorTicker extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback selectedCallback;

  ColorTicker({this.color, this.selected, this.selectedCallback});


  @override
  Widget build(BuildContext context) {
    print(selected);
    return
      GestureDetector(
          onTap: () {
            selectedCallback();
          },
          child: Container(
            padding: EdgeInsets.all(7),
            margin: EdgeInsets.all(5),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.7)),
            child: selected ? Image.asset("images/checker.png") :
            Container(),
          )
      );
  }

}
