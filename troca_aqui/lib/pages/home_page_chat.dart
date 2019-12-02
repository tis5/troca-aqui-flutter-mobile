import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/registration_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';

class HomePageChat extends StatefulWidget {
  final SharedPreferences prefs;
  HomePageChat({this.prefs});
  @override
  _HomePageChatState createState() => _HomePageChatState();
}

class _HomePageChatState extends State<HomePageChat> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs;
  int _currentIndex = 0;
  String _tabTitle = "Contacts";
  List<Widget> _children = [Container(), Container()];

  final db = Firestore.instance;
  final ContactPicker _contactPicker = new ContactPicker();
  CollectionReference contactsReference;
  DocumentReference profileReference;
  DocumentSnapshot profileSnapshot;

  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _yourNameController = TextEditingController();
  bool editName = false;


  getDadosUser() async{
    final SharedPreferences prefs = await _prefs;
    contactsReference = db
        .collection("users")
        .document(prefs.getString('uid'))
        .collection('contacts');
    profileReference =
        db.collection("users").document(prefs.getString('uid'));

    profileReference.snapshots().listen((querySnapshot) {
      profileSnapshot = querySnapshot;
      prefs.setString('name', profileSnapshot.data["name"]);
      prefs.setString('profile_photo', profileSnapshot.data["profile_photo"]);

      setState(() {
        _yourNameController.text = profileSnapshot.data["name"];
        this.prefs = prefs;
      });
    });






  }





  @override
  void initState() {
    super.initState();
    if(prefs == null)
      prefs = widget.prefs;
    getDadosUser();
  }

  generateContactTab() {
    return Column(
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
          stream: contactsReference.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return new Text("No Contacts");
            return Expanded(
              child: new ListView(
                children: generateContactList(snapshot),
              ),
            );
          },
        )
      ],
    );
  }

  generateContactList(AsyncSnapshot<QuerySnapshot> snapshot) {

    return snapshot.data.documents
        .map<Widget>(
          (doc) => InkWell(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
              child: ListTile(
                title: Text(doc["name"]),
                subtitle: Text('Negociação'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            onTap: () async {
              QuerySnapshot result = await db
                  .collection('chats')
                  .where('contact1', isEqualTo: this.prefs.getString('uid'))
                  .where('contact2', isEqualTo: doc["uid"])
                  .getDocuments();
              List<DocumentSnapshot> documents = result.documents;
              if (documents.length == 0) {
                result = await db
                    .collection('chats')
                    .where('contact2', isEqualTo: this.prefs.getString('uid'))
                    .where('contact1', isEqualTo: doc["uid"])
                    .getDocuments();
                documents = result.documents;
                if (documents.length == 0) {
                  await db.collection('chats').add({
                    'contact1': this.prefs.getString('uid'),
                    'contact2': doc["uid"]
                  }).then((documentReference) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          prefs: this.prefs,
                          chatId: documentReference.documentID,
                          title: doc["name"],
                        ),
                      ),
                    );
                  }).catchError((e) {});
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        prefs: this.prefs,
                        chatId: documents[0].documentID,
                        title: doc["name"],
                      ),
                    ),
                  );
                }
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      prefs: this.prefs,
                      chatId: documents[0].documentID,
                      title: doc["name"],
                    ),
                  ),
                );
              }
            },
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {

    return generateContactTab();
  
  }
}
