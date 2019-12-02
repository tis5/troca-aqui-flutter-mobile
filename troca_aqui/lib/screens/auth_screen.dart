import 'dart:math';
import '../providers/auth.dart';
import 'package:chat/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:chat/screens/shop_tabs_screen.dart';
enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';






  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              // gradient: LinearGradient(
              //   colors: [
              //     Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
              //     Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   stops: [0, 1],
              // ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      // transform: Matrix4.rotationZ(-8 * pi / 180)
                      //   ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Troca Aqui',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    // flex: deviceSize.width > 600 ? 2 : 1,
                    flex: 0,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'nome': '',
    'cidade': '',
    'dataNascimento': '',
    'telefone': '',
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();
  String token;

  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  final db = Firestore.instance;

  @override
  initState() {
    super.initState();
  }



  Future<void> verifyPhone() async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {});
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo, // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent:
          smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException e) {
            print('${e.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Informe o codigo de verificação SMS'),
            content: Container(
              height: 120,
              child: Column(children: [
                TextField(
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                (errorMessage != ''
                    ? Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                )
                    : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Confirmar'),
                onPressed: () {
                  _auth.currentUser().then((user) async {
                    signIn();
                  });
                },
              )
            ],
          );
        });
  }

  handleError(PlatformException error) {
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {});
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      assert(user.uid == currentUser.uid);
      Navigator.of(context).pop();
      DocumentReference mobileRef = db
          .collection("mobiles")
          .document(phoneNo.replaceAll(new RegExp(r'[^\w\s]+'), ''));
      await mobileRef.get().then((documentReference) {
        if (!documentReference.exists) {
          mobileRef.setData({}).then((documentReference) async {
            await db.collection("users").add({
              'name': "No Name",
              'mobile': phoneNo.replaceAll(new RegExp(r'[^\w\s]+'), ''),
              'profile_photo': "",
            }).then((documentReference) {
              prefs.setBool('is_verified', true);
              prefs.setString(
                'mobile',
                phoneNo.replaceAll(new RegExp(r'[^\w\s]+'), ''),
              );
              prefs.setString('uid', documentReference.documentID);
              prefs.setString('name', "No Name");
              prefs.setString('profile_photo', "");

              mobileRef.setData({'uid': documentReference.documentID}).then(
                      (documentReference) async {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => HomePage(prefs: prefs)));
                  }).catchError((e) {
                print(e);
              });
            }).catchError((e) {
              print(e);
            });
          });
        } else {
          prefs.setBool('is_verified', true);
          prefs.setString(
            'mobile_number',
            phoneNo.replaceAll(new RegExp(r'[^\w\s]+'), ''),
          );
          prefs.setString('uid', documentReference["uid"]);
          prefs.setString('name', documentReference["name"]);
          prefs
              .setString('profile_photo', documentReference["profile_photo"]);

          Navigator.of(context)
              .pushReplacementNamed(UserTabsScreen.routeName);
        }
      }).catchError((e) {});
    } catch (e) {
      handleError(e);
    }
  }
   _submit() async {
     _formKey.currentState.save();
//     if (!_formKey.currentState.validate()) {
//
//       this.phoneNo = "+55"+_authData['telefone'];
//       print(this.phoneNo);
//      verifyPhone();
//
//
//     }

       this.phoneNo = "+55"+_authData['telefone'];
       print(this.phoneNo);
      verifyPhone();


    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // Navigator.pushReplacementNamed(context, '/user-products-tab');

    if (_authMode == AuthMode.Login) {

      Navigator.pushReplacementNamed(context, '/user-products-tab');

      // await Provider.of<Auth>(context, listen: false).login(
      //   _authData['email'],
      //   _authData['password'],
      // );

    } else {

      await Provider.of<Auth>(context, listen: false).signup(
        _authData['email'],
        _authData['password'],
        _authData['nome'],
        _authData['cidade'],
        _authData['dataNascimento'],
        _authData['telefone'],
      );

       Navigator.pushReplacementNamed(context, '/user-products-tab');
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 480 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 480 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // if (value.isEmpty || !value.contains('@')) {
                    //   return 'Email inválido!';
                    // }
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    // if (value.isEmpty || value.length < 1) {
                    //   return 'Senha muito curta!';
                    // }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                // if (_authMode == AuthMode.Signup)
                //   TextFormField(
                //     enabled: _authMode == AuthMode.Signup,
                //     decoration: InputDecoration(labelText: 'Confirmar Senha'),
                //     obscureText: true,
                //     validator: _authMode == AuthMode.Signup
                //         ? (value) {
                //             if (value != _passwordController.text) {
                //               return 'Senhas não estao iguais!';
                //             }
                //           }
                //         : null,
                //   ),
                // SizedBox(
                //   height: 20,
                // ),
                if (_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: InputDecoration(labelText: 'Nome'),
                  onSaved: (value) {
                    _authData['nome'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: InputDecoration(labelText: 'Cidade'),
                  onSaved: (value) {
                    _authData['cidade'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(labelText: 'Data de Nascimento'),
                  onSaved: (value) {
                    _authData['dateNascimento'] = value.toString();
                  },
                ),
                if (_authMode == AuthMode.Signup)
                TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Telefone'),
                  onSaved: (value) {
                    _authData['telefone'] = value;
                  },
                ),
                SizedBox(
                  height: 15,
                ),

                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'CADASTRO'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'CADASTRO' : 'LOGIN'}'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
