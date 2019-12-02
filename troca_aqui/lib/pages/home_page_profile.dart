import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:chat/widgets/app_drawer.dart';

class HomePageProfile extends StatefulWidget {
  final SharedPreferences prefs;

  HomePageProfile({this.prefs});
  @override
  _HomePageProfileState createState() => _HomePageProfileState();
}

class _HomePageProfileState extends State<HomePageProfile> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences prefs;
  int _currentIndex = 0;
  String _tabTitle = "Contacts";
  List<Widget> _children = [Container(), Container()];




  Future<void> _incrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    final String counter = prefs.getString('uid');
    this.prefs = prefs;
   print('teste: '+counter);

   print(this.prefs.getString('uid'));


    contactsReference = db
        .collection("users")
        .document(prefs.getString('uid'))
        .collection('contacts');
    profileReference =
        db.collection("users").document(prefs.getString('uid'));

    profileReference.snapshots().listen((querySnapshot) {
      profileSnapshot = querySnapshot;
      prefs.setString('name', profileSnapshot.data["name"]);
      prefs
          .setString('profile_photo', profileSnapshot.data["profile_photo"]);

      setState(() {
        _yourNameController.text = profileSnapshot.data["name"];
      });
    });








  }





  final db = Firestore.instance;
  final ContactPicker _contactPicker = new ContactPicker();
  CollectionReference contactsReference;
  DocumentReference profileReference;
  DocumentSnapshot profileSnapshot;

  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _yourNameController = TextEditingController();
  bool editName = false;






  @override
  void initState() {
    _incrementCounter();

    super.initState();

  }

  Future<void> getProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('profiles/${prefs.getString('uid')}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    print('File Uploaded');
    String fileUrl = await storageReference.getDownloadURL();
    profileReference.updateData({'profile_photo': fileUrl});
  }

  generateProfileTab() {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (profileSnapshot != null
                ? (profileSnapshot.data['profile_photo'] != null
                    ? InkWell(
                        child: Container(
                          width: 190.0,
                          height: 190.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  '${profileSnapshot.data['profile_photo']}'),
                            ),
                          ),
                        ),
                        onTap: () {
                          getProfilePicture();
                        },
                      )
                    : Container())
                : Container()),
            SizedBox(
              height: 20,
            ),
            (!editName && profileSnapshot != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('${profileSnapshot.data["name"]}'),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            editName = true;
                          });
                        },
                      ),
                    ],
                  )
                : Container()),
            (editName
                ? Form(
                    key: _formStateKey,
                    autovalidate: true,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Por vafor entre com um nome valido';
                              }
                              if (value.trim() == "")
                                return "Uso de apenas espaco nao e valido!!!";
                              return null;
                            },
                            controller: _yourNameController,
                            decoration: InputDecoration(
                              focusedBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      width: 2, style: BorderStyle.solid)),
                              labelText: "Your Name",
                              icon: Icon(
                                Icons.verified_user,
                              ),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container()),
            (editName
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        child: Text(
                          'UPDATE',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          if (_formStateKey.currentState.validate()) {
                            profileReference
                                .updateData({'name': _yourNameController.text});
                            setState(() {
                              editName = false;
                            });
                          }
                        },
                        color: Colors.lightBlue,
                      ),
                      RaisedButton(
                        child: Text('Cancelar'),
                        onPressed: () {
                          setState(() {
                            editName = false;
                          });
                        },
                      )
                    ],
                  )
                : Container())
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
          title: Text('Troca Aqui'),
        ), 
        drawer: AppDrawer(),
        body: generateProfileTab(),
      );
  }
}
