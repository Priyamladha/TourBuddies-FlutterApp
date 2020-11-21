import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mapmarker/screens/tracking_screen.dart';
import 'package:random_string/random_string.dart';

class LobbyScreen extends StatefulWidget {
  static String id = 'lobby_screen';

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  // Use _context only within the scope of this widget.
  final _auth = FirebaseAuth.instance;
  String key;
  // String password;
  bool spinner = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lobby',
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/lobby.jpg"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title:
                Text('Group Creation', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
            // leading: null,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
//                moodsStream();
                    _auth.signOut();
                    // Navigator.pop(context);
                    // Navigator.push(context, route)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }),
            ],
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Text("Hello there"),
                SizedBox(
                  height: 100.0,
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    key = value;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.blueAccent,
                    filled: true,
                    hintText: 'Please enter the key!',
                    hintStyle: TextStyle(color: Colors.black),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.orange,
                    // borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        setState(() {
                          spinner = true;
                        });
                        try {
                          bool docExists = await checkIfCollectionExists();
                          print(docExists);
                          if (docExists) {
                            TrackingScreen.collection_name = key;
                            TrackingScreen.admin_flag = false;
                            Navigator.pushNamed(context, TrackingScreen.id);
                          } else
                            spinner = false;
                        } catch (e) {
                          print(e);
                          setState(() {
                            spinner = false;
                          });
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Join Lobby',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 50.0),
                  child: Material(
                    color: Colors.white,
                    // borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        setState(() {
                          spinner = true;
                        });
                        try {
                          String temp = randomAlphaNumeric(5);
                          TrackingScreen.collection_name = temp;
                          TrackingScreen.admin_flag = true;
                          Navigator.pushNamed(context, TrackingScreen.id);
                        } catch (e) {
                          print(e);
                          setState(() {
                            spinner = false;
                          });
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Create Lobby',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.green,
                    // borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () => _scan(),
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Scan QR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // FlatButton(
                //   child: Text("Scan Barcode"),
                //   onPressed: ()=>_scan(),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _scan() async {
    await FlutterBarcodeScanner.scanBarcode(
            "#000000", "Cancel", true, ScanMode.QR)
        .then((value) => setState(() => key = value));
    print(key);
    bool docExists = await checkIfCollectionExists();
    print(docExists);
    if (docExists) {
      TrackingScreen.collection_name = key;
      TrackingScreen.admin_flag = false;
      Navigator.pushNamed(context, TrackingScreen.id);
    }
  }

  Future<bool> checkIfCollectionExists() async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection(key);

    var snapshot = await collectionRef.get();
    if (snapshot.docs.length == 0) return false;
    return true;
  }
}
