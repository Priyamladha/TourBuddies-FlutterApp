import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TourBuddies',
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/pic.jpg"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Image.asset('assets/logo.png'),
                      height: 200.0,
                    ),
                  ],
                ),
                SizedBox(
                  height: 58.0,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  width: double.infinity,
                  child: FlatButton(
                    color: Colors.greenAccent,
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: const Text(
                      'Log In',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    },
                  ),
                ),
                SizedBox(
                  height: 10.0,
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
                    onPressed: () {
                      Navigator.pushNamed(context, RegistrationScreen.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
