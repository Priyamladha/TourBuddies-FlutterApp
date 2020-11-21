import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'lobby_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool spinner = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Register Screen",
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/registerbg.jpg"), fit: BoxFit.cover)),
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
                      height: 150.0,
                      child: Image.asset('assets/register.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.black,
                      filled: true,
                      prefix: Icon(
                        Icons.email,
                        color: Colors.green,
                        size: 24.0,
                        semanticLabel: 'Enter mail',
                      ),
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                      // enabledBorder: OutlineInputBorder(
                      //   borderSide:
                      //       BorderSide(color: Colors.blueAccent, width: 1.0),
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide:
                      //       BorderSide(color: Colors.blueAccent, width: 2.0),
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      //Do something with the user input.
                      password = value;
                    },
                    decoration: InputDecoration(
                      prefix: Icon(
                        Icons.lock,
                        color: Colors.green,
                        size: 24.0,
                        semanticLabel: 'Enter mail',
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                      // enabledBorder: OutlineInputBorder(
                      //   borderSide:
                      //       BorderSide(color: Colors.blueAccent, width: 1.0),
                      //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide:
                      //       BorderSide(color: Colors.blueAccent, width: 2.0),
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
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        setState(() {
                          spinner = true;
                        });
                        try {
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);
                          if (newUser != null) {
                            Navigator.pushNamed(context, LobbyScreen.id);
                          }
                          setState(() {
                            spinner = false;
                          });
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
