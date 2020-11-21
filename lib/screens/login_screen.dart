import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'lobby_screen.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email, password;
  bool spinner = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Screen',
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/userlogin2.jpg"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ModalProgressHUD(
            inAsyncCall: spinner,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      height: 100.0,
                      child: Image.asset('assets/user2.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                  ),
                  TextField(
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                      prefix: Icon(
                        Icons.email,
                        color: Colors.green,
                        size: 24.0,
                        semanticLabel: 'Enter mail',
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                      // enabledBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: Colors.lightBlueAccent, width: 1.0),
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: Colors.lightBlueAccent, width: 2.0),
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    obscureText: true,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: InputDecoration(
                      prefix: Icon(
                        Icons.lock,
                        color: Colors.green,
                        size: 24.0,
                        semanticLabel: 'Enter password',
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      hintText: 'Enter your password.',
                      hintStyle: TextStyle(color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                      // enabledBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: Colors.lightBlueAccent, width: 1.0),
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: Colors.lightBlueAccent, width: 2.0),
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                    width: double.infinity,
                    child: FlatButton(
                      color: Colors.blueAccent,
                      padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        setState(() {
                          spinner = true;
                        });
                        try {
                          final User = await _auth.signInWithEmailAndPassword(
                              email: email, password: password);
                          if (User != null) {
                            Navigator.pushNamed(context, LobbyScreen.id);
                            setState(() {
                              spinner = false;
                            });
                          }
                        } catch (e) {
                          print(e);
                          setState(() {
                            spinner = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
