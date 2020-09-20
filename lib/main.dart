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

import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

import 'MapMarkerExample.dart';



void main() async{
  SdkContext.init(IsolateOrigin.main);
  // Making sure that BuildContext has MaterialLocalizations widget in the widget tree,
  // which is part of MaterialApp.
  print("Firebase initializinggggggggg.........................................");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("Firebase initialized.........................................");
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  // Use _context only within the scope of this widget.
  BuildContext _context;
  MapMarkerExample _mapMarkerExample;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('HERE SDK - Map Marker Example'),
        ),
        body: Stack(
          children: [
            HereMap(

                onMapCreated: _onMapCreated
            ),
            StreamBuilder<Position>(

                stream: getPositionStream(desiredAccuracy: LocationAccuracy.high),
                builder: (context,snapshot){
                  //return Text('lat : ${snapshot.data.latitude} Long :${snapshot.data.longitude}');

                  if(snapshot!=null){
                    _anchoredMapMarkersButtonClicked(snapshot.data.latitude,snapshot.data.longitude);
//                    sleep(new Duration(seconds: 5));
                  }
                  else
                    return CircularProgressIndicator();
                  return Text('');
                }
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
        _mapMarkerExample = MapMarkerExample(_context, hereMapController);
      } else {
        print("Map scene not loaded. MapError: " + error.toString());
      }
    });
  }

  void _anchoredMapMarkersButtonClicked(double lat, double long) {
    Map<String,dynamic> demodata = {
      "Latitude": lat,
      "Longitude": long
    };
    CollectionReference collectionReference = FirebaseFirestore.instance.collection('Location');
    DocumentReference documentReference = collectionReference.doc('VTjoLa5Elka1EjW6ryBq');
    documentReference.update(demodata);
    _mapMarkerExample.showAnchoredMapMarkers(lat,long);
  }

  void _centeredMapMarkersButtonClicked() {
    _mapMarkerExample.showCenteredMapMarkers();
  }

  void _clearButtonClicked() {
    _mapMarkerExample.clearMap();
  }

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