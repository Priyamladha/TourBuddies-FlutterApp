/*
 * Copyright (C) 2019-2020 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */
import 'dart:math';
import 'dart:typed_data';


import 'package:flutter/services.dart' show rootBundle;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

import 'MapMarkerExample.dart';

//void main() async{
//  SdkContext.init(IsolateOrigin.main);
//  // Making sure that BuildContext has MaterialLocalizations widget in the widget tree,
//  // which is part of MaterialApp.
//  print("Firebase initializinggggggggg.........................................");
//  WidgetsFlutterBinding.ensureInitialized();
//  await Firebase.initializeApp();
//  print("Firebase initialized.........................................");
//  runApp(MaterialApp(home: MyApp()));
//}
class TrackingScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // Use _context only within the scope of this widget.
  BuildContext _context;
  MapMarkerExample _mapMarkerExample;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String email;
  double lat;
  double long;
  var startlocationstream =false;
  var useruid;

  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser(){
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        useruid=loggedInUser.uid;
        print(useruid);
        print(loggedInUser.email);
        email = loggedInUser.email;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
//                moodsStream();
                  _auth.signOut();
                  Navigator.pop(context);
                }),
          ],
          title: Text('Tracking',),
        ),
        body: Stack(
          children: <Widget>[
            HereMap(

                onMapCreated: _onMapCreated
            ),
            StreamBuilder<Position>(

                stream: getPositionStream(desiredAccuracy: LocationAccuracy.high),
                builder: (context,snapshot){
                  //return Text('lat : ${snapshot.data.latitude} Long :${snapshot.data.longitude}');

                  if(snapshot!=null && startlocationstream){
//                    print("marker true");
                    lat = snapshot.data.latitude;
                    long = snapshot.data.longitude;
                    _anchoredMapMarkersButtonClicked(lat,long);
//                    sleep(new Duration(seconds: 5));
                  }
//                  else
//                    return CircularProgressIndicator();
                  return Text('');
                }
            ),
            Positioned(
//              decoration: kMessageContainerDecoration,

              bottom: 10,
              right: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
//                      print("hello from the space");
                      _mapMarkerExample.centeruserlocation(lat, long);
                    },
                    child: Icon(Icons.location_on),
                  ),
                ],
              ),
            ),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: [
//                button('Anchored', _anchoredMapMarkersButtonClicked),
//                button('Centered', _centeredMapMarkersButtonClicked),
//                button('Clear', _clearButtonClicked),
//              ],
//            ),
          ],
        ),
      ),
    );
  }


  void _onMapCreated(HereMapController hereMapController) {
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.hybridDay,
            (MapError error) {
          if (error == null) {
//            print("marker false");
            _mapMarkerExample = MapMarkerExample(_context, hereMapController);
            //added flag by Priyam
            startlocationstream =true;
          } else {
            print("Map scene not loaded. MapError: " + error.toString());
          }
        });
  }

  void _anchoredMapMarkersButtonClicked (double lat, double long) async {

    Map<String,dynamic> demodata = {
      "Latitude": lat,
      "Longitude": long
    };
    bool docExists = await checkIfDocExists(useruid);
//    print("Document exists in Firestore? " + docExists.toString());
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('Location');
    if(docExists){
      DocumentReference documentReference= collectionReference.doc(useruid);
      documentReference.update(demodata);
    }
    else{
      collectionReference.doc(useruid).set(demodata);
    }


    final locations = await collectionReference.get();

    _mapMarkerExample.clearMap();
    for(var location in locations.docs){

      double temp_lat =location.data().values.first;
      double temp_long = location.data().values.last;
      _mapMarkerExample.showAnchoredMapMarkers(temp_lat,temp_long);
    }

  }
  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('Location');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }
//  void _centeredMapMarkersButtonClicked() {
//    _mapMarkerExample.showCenteredMapMarkers();
//  }
//
//  void _clearButtonClicked() {
//    _mapMarkerExample.clearMap();
//  }

  // A helper method to add a button on top of the HERE map.
  Align button(String buttonLabel, Function callbackFunction) {
    return Align(
      alignment: Alignment.topCenter,
      child: RaisedButton(
        color: Colors.lightBlueAccent,
        textColor: Colors.white,
        onPressed: () => callbackFunction(),
        child: Text(buttonLabel, style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

//class MyAppp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return StreamProvider<UserLocation>(
//      create: (context) => LocationService().locationStream,
//      child: MaterialApp(
//          title: 'Flutter Demo',
//          theme: ThemeData(
//            primarySwatch: Colors.blue,
//          ),
//          home: Scaffold(
//            body: HomeView(),
//          )),
//    );
//  }
//}
//


class HomeView extends StatelessWidget {
//  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
//    var userLocation = Provider.of<UserLocation>(context);
    return Center(
      child: Text(
          'hello there friends'),
    );
  }
}