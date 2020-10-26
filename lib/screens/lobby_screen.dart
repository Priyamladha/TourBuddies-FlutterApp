
import 'dart:math' show Random;
import 'package:mapmarker/screens/tracking_screen.dart';
import 'package:random_string/random_string.dart';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(

              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Text("Hello there"),
                SizedBox(
                  height: 70.0,
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  onChanged: (value) {
                    key = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter key bitch',
                    hintStyle: TextStyle(color: Colors.grey),
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
                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        setState(() {
                          spinner = true;
                        });
                        try {
                          bool docExists = await checkIfCollectionExists();
                          print(docExists);
                          if(docExists){
                            TrackingScreen.collection_name = key;
                            Navigator.pushNamed(context, TrackingScreen.id);
                          }
                          else
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
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        setState(() {
                          spinner = true;
                        });
                        try {
                          String temp = randomAlphaNumeric(5);
                          TrackingScreen.collection_name = temp;
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
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: ()=>_scan(),
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
    );
  }
  _scan () async{
    await FlutterBarcodeScanner.scanBarcode("#000000","Cancel",true,ScanMode.QR).then((value) => setState(()=>key = value));
    print(key);
    bool docExists = await checkIfCollectionExists();
    print(docExists);
    if(docExists){
      TrackingScreen.collection_name = key;
      Navigator.pushNamed(context, TrackingScreen.id);
    }
  }

  Future<bool> checkIfCollectionExists() async {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection(key);

      var snapshot = await collectionRef.get();
      if(snapshot.docs.length==0)
        return false;
      return true;


  }
}

