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
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:mapmarker/screens/chat_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:steel_crypt/steel_crypt.dart';

import '../RoutingExample.dart';
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
  static String id = 'tracking_screen';
  static String collection_name;
  static var admin_flag;
  static double current_lat;
  static double current_long;
  static String userName = "XYZ";
  static var key32 = "iiDW9Wjrcybj22snqaWYpHrHtfAWUI6JAlujGP7xgHQ=";
  static var iv16 = "5nnxuwf0KM91rlPxw2Ok2g==";
  static var aes = AesCrypt(key: key32, padding: PaddingAES.pkcs7);
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // Use _context only within the scope of this widget.
  BuildContext _context;
  // MyDrawer _myDrawer;
  static RoutingExample routingExample;
  MapMarkerExample _mapMarkerExample;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String email;
  double lat;
  double long;
  var startlocationstream = false;
  var useruid;
  List<String> result = new List<String>();
  static List<String> isChecked = [];
  bool status = true;
  var notleave = true;
  int flag = 0;

  void initState() {
    super.initState();
    getCurrentUser();
    // print(generateRandomString(20));
    print(randomAlphaNumeric(10));
  }

  // YdEWFHoOmigH8CfI2yUip5z2zP12
  // BRUb6YkR5bSdIYdAshTBqJmFm2B2
  // w40JWW4L73NSazHnEMBI
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        useruid = loggedInUser.uid;
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
//             IconButton(
//                 icon: Icon(Icons.logout),
//                 onPressed: () {
// //                moodsStream();
//                   _auth.signOut();
//                   // Navigator.pop(context);
//                   // Navigator.push(context, route)
//                   Navigator.popUntil(context, (route) => route.isFirst);
//                 }),
            PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return Constants.choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
          // title: Text(
          //   'Tracking',
          // ),
        ),
        body: Stack(
          children: <Widget>[
            HereMap(onMapCreated: _onMapCreated),
            SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: IconThemeData(size: 22.0),
              marginBottom: 30,
              marginRight: 30,
              overlayOpacity: 0.0,
              children: [
                floatingButton(
                    _addRouteButtonClicked, Icons.add, "Get Isoline"),
                floatingButton(_clearIsoline, Icons.clear, "Clear Isoline"),
                floatingButton(_clearRoute, Icons.arrow_back, "Clear Routes"),
                floatingButton(_clearPlaces, Icons.place, "Clear Places"),

                // switchButton(Icons.place),
                //floatingButton(_getPlacesClicked, Icons.local_cafe),
              ],
            ),
            switchButton(Icons.place),
            StreamBuilder<Position>(
                stream:
                    getPositionStream(desiredAccuracy: LocationAccuracy.high),
                builder: (context, snapshot) {
                  //return Text('lat : ${snapshot.data.latitude} Long :${snapshot.data.longitude}');

                  if (snapshot != null && startlocationstream) {
//                    print("marker true");

                    lat = snapshot.data.latitude;
                    long = snapshot.data.longitude;
                    TrackingScreen.current_lat = lat;
                    TrackingScreen.current_long = long;
                    // print(TrackingScreen.current_lat);
                    routingExample.current_lat = lat;
                    routingExample.current_long = long;
                    if (notleave) {
                      _anchoredMapMarkersButtonClicked(lat, long);
                    }
                    awaitStatus(lat, long);
//                    sleep(new Duration(seconds: 5));
                  }
//                  else
//                    return CircularProgressIndicator();
                  return Text('');
                }),
            Positioned(
//              decoration: kMessageContainerDecoration,

              top: 20,
              left: 10,
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
        drawer: DrawerMaker(trackcontext: _context),
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.hybridDay,
        (MapError error) {
      if (error == null) {
//            print("marker false");

        _mapMarkerExample = MapMarkerExample(_context, hereMapController);
        routingExample = RoutingExample(_context, hereMapController);
        //added flag by Priyam
        startlocationstream = true;
      } else {
        print("Map scene not loaded. MapError: " + error.toString());
      }
    });
  }

  void _anchoredMapMarkersButtonClicked(double lat, double long) async {
    if (routingExample.isroute) {
      routingExample.updateRoute();
    }
    // print("stream ok");
    var encLat = TrackingScreen.aes.gcm
        .encrypt(inp: lat.toString(), iv: TrackingScreen.iv16);
    var encLon = TrackingScreen.aes.gcm
        .encrypt(inp: long.toString(), iv: TrackingScreen.iv16);
    var encuserName = TrackingScreen.aes.gcm
        .encrypt(inp: TrackingScreen.userName, iv: TrackingScreen.iv16);
    // print(encuserName);
    Map<String, dynamic> demodata = {
      "Latitude": encLat,
      "Longitude": encLon,
      "UserName": encuserName
    };
    bool docExists = await checkIfDocExists(useruid);
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(TrackingScreen.collection_name);

    if (docExists) {
      DocumentReference documentReference = collectionReference.doc(useruid);
      documentReference.update(demodata);
    } else {
      collectionReference.doc(useruid).set(demodata);
      if (TrackingScreen.admin_flag) {
        Map<String, dynamic> masterdata = {
          "Latitude": encLat,
          "Longitude": encLon
        };
        collectionReference.doc("MasterCoordinates").set(masterdata);
      }
    }

    final locations = await collectionReference.get();
    _mapMarkerExample.clearMap();
    _mapMarkerExample.clearPins();
    for (var location in locations.docs) {
      // print(location.id);
      if (location.id != "MasterCoordinates") {
        // var decLat = encrypter.decrypt(location.data().values.first, iv: iv);
        // var decLon = encrypter.decrypt(location.data().values.last, iv: iv);
        var decLat = TrackingScreen.aes.gcm
            .decrypt(enc: location.data()['Latitude'], iv: TrackingScreen.iv16);
        var decLon = TrackingScreen.aes.gcm.decrypt(
            enc: location.data()['Longitude'], iv: TrackingScreen.iv16);
        var decuserName = TrackingScreen.aes.gcm
            .decrypt(enc: location.data()['UserName'], iv: TrackingScreen.iv16);

        double temp_lat = double.parse(decLat);
        double temp_long = double.parse(decLon);

        _mapMarkerExample.showAnchoredMapMarkers(
            temp_lat, temp_long, decuserName);
      }
    }
  }

  void awaitStatus(double lat, double lon) async {
    status = await routingExample.isItIn(lat, lon);
    if (!status) {
      if (flag == 1) {
        _showDialog("Warning", "You're outside the range!");
        flag++;
      }
    } else {
      flag = 1;
    }
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef =
          FirebaseFirestore.instance.collection(TrackingScreen.collection_name);

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

  Future<void> _showDialog(String title, String message) async {
    return showDialog<void>(
      context: _context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addRouteButtonClicked() async {
    routingExample.clearIsoline();
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(TrackingScreen.collection_name);
    DocumentReference documentReference =
        collectionReference.doc("MasterCoordinates");
    final masterlocation = await documentReference.get();
    // var decLat = encrypter.decrypt(masterlocation.data().values.first, iv: iv);
    // var decLon = encrypter.decrypt(masterlocation.data().values.last, iv: iv);
    var decLat = TrackingScreen.aes.gcm.decrypt(
        enc: masterlocation.data().values.first, iv: TrackingScreen.iv16);
    var decLon = TrackingScreen.aes.gcm.decrypt(
        enc: masterlocation.data().values.last, iv: TrackingScreen.iv16);
    double lat = double.parse(decLat);
    double long = double.parse(decLon);
    // double lat = masterlocation.data().values.first;
    // double long = masterlocation.data().values.last;
    routingExample.addRoute(lat, long);
  }

  void _clearMapButtonClicked() {
    routingExample.clearMap();
  }

  void _clearPlaces() {
    routingExample.clearPlaces();
  }

  void _clearIsoline() {
    routingExample.clearIsoline();
  }

  void _getPlacesClicked(List<String> items) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(TrackingScreen.collection_name);
    DocumentReference documentReference =
        collectionReference.doc("MasterCoordinates");
    final masterlocation = await documentReference.get();
    var decLat = TrackingScreen.aes.gcm.decrypt(
        enc: masterlocation.data().values.first, iv: TrackingScreen.iv16);
    var decLon = TrackingScreen.aes.gcm.decrypt(
        enc: masterlocation.data().values.last, iv: TrackingScreen.iv16);

    double lat = double.parse(decLat);
    double long = double.parse(decLon);
    // double lat = masterlocation.data().values.first;
    // double long = masterlocation.data().values.last;
    routingExample.getPlaces(items, lat, long);
  }

  void _clearRoute() {
    routingExample.isroute = false;
    routingExample.clearRoute();
  }

  SpeedDialChild floatingButton(
      Function callbackFunction, IconData icn, String text) {
    return SpeedDialChild(
      label: text,
      child: FloatingActionButton(
        heroTag: Text("btn2"),
        onPressed: () => callbackFunction(),
        child: Icon(icn),
        backgroundColor: Colors.green,
      ),
    );
  }

  Positioned switchButton(IconData icn) {
    return Positioned(
      bottom: 14,
      left: 14,
      //margin: const EdgeInsets.all(70.0),
      // child : Positioned(
      // //alignment: Alignment.bottomRight,
      //   bottom: 20,
      //   left: 18,
      child: FloatingActionButton.extended(
        label: Text("Places"),
        heroTag: Text("btn1"),
        onPressed: () => {
          _awaitReturnValueFromSecondScreen(_context),
        },
        backgroundColor: Colors.green,
        icon: Icon(Icons.place_rounded),
        //child: Icon(icn),
      ),
      //)
    );
  }

  void _awaitReturnValueFromSecondScreen(BuildContext context) async {
    result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ListP()));
    try {
      if (result.length > 0) {
        _clearPlaces();
        _getPlacesClicked(result);
      } else {
        _clearPlaces();
      }
    } on NoSuchMethodError catch (e) {
      print("error");
    }
  }

  void choiceAction(String choice) async {
    if (choice == Constants.Leave) {
      // print('Leave');
      notleave = false;
      await new Future.delayed(const Duration(milliseconds: 50));
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection(TrackingScreen.collection_name);
      collectionReference.doc(useruid).delete();
      Navigator.pop(context);
    } else if (choice == Constants.SignOut) {
      // print('SignOut');
      notleave = false;
      await new Future.delayed(const Duration(milliseconds: 50));
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection(TrackingScreen.collection_name);
      collectionReference.doc(useruid).delete();
      _auth.signOut();
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }
}

class Constants {
  static const String Leave = "Leave";
  static const String SignOut = 'Sign out';

  static const List<String> choices = <String>[Leave, SignOut];
}

class HomeView extends StatelessWidget {
//  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
//    var userLocation = Provider.of<UserLocation>(context);
    return Center(
      child: Text('hello there friends'),
    );
  }
}

class ListP extends StatefulWidget {
  @override
  ListPage createState() => new ListPage();
}

class ListPage extends State<ListP> {
  List<String> items = [
    'Restaurants',
    'Hospitals',
    'Cafe',
    'Hotels',
    'Locations',
    'Facilities',
    'Transport',
    'Businesses'
  ];
  List<String> descriptions = [
    'Includes non-accommodation',
    'Includes Health-care services',
    'Coffee/Tea',
    'Accommodation',
    'Landmarks, Museums, Religious Places',
    'Clinics, Event Spaces, Libraries etc.',
    'Public Transport, Airport, Cargo',
    'ATMs, Banking, Car Rental etc.'
  ];
  List<String> isChecked = _TrackingScreenState.isChecked;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Where do you want to go?"),
      ),
      body: new ListView(
        children: <Widget>[
          ...IterableZip([items, descriptions])
              .map(
                (item) => CheckboxListTile(
                  subtitle: Text(item[1]),
                  // secondary: Text('This is Secondary text'),
                  title: Text(item[0]),
                  value: isChecked.contains(item[0]),
                  onChanged: (bool value) {
                    if (value) {
                      setState(() {
                        isChecked.add(item[0]);
                      });
                    } else {
                      setState(() {
                        isChecked.remove(item[0]);
                      });
                    }
                  },
                ),
              )
              .toList()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(isChecked);
          _sendDataBack(context);
        },
        backgroundColor: Colors.green,
        //icon: Icon(Icons.check),
        child: Icon(Icons.check),
      ),
    );
  }

  void _sendDataBack(BuildContext context) {
    print(isChecked);
    Navigator.pop(context, isChecked);
  }
}

class DrawerMaker extends StatefulWidget {
  DrawerMaker({this.trackcontext});
  final BuildContext trackcontext;
  @override
  MyDrawer createState() => new MyDrawer(trackcontext: this.trackcontext);
}

class MyDrawer extends State<DrawerMaker> {
  final Function onTap;
  final BuildContext trackcontext;
  // elements for the listview
  final List<Widget> listArray = [];
  List<String> names = new List<String>();
  List<GeoCoordinates> points = new List<GeoCoordinates>();
  bool loading = true;
  _TrackingScreenState tss;
  RoutingExample re = _TrackingScreenState.routingExample;

  void onTapMaster() {
    // print(TrackingScreen.current_lat);
    // print(long);
    var encLat = TrackingScreen.aes.gcm.encrypt(
        inp: TrackingScreen.current_lat.toString(), iv: TrackingScreen.iv16);
    var encLon = TrackingScreen.aes.gcm.encrypt(
        inp: TrackingScreen.current_long.toString(), iv: TrackingScreen.iv16);
    // var encLat =
    //     encrypter.encrypt(TrackingScreen.current_lat.toString(), iv: iv);
    // var encLon =
    //     encrypter.encrypt(TrackingScreen.current_long.toString(), iv: iv);
    Map<String, dynamic> demodata = {"Latitude": encLat, "Longitude": encLon};
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(TrackingScreen.collection_name);
    DocumentReference documentReference =
        collectionReference.doc("MasterCoordinates");
    documentReference.update(demodata);
  }

  void onTapChat() {
    String msgcollection = TrackingScreen.collection_name + "_messages";
    ChatScreen.collection_name = msgcollection;
    Navigator.pushNamed(trackcontext, ChatScreen.id);
  }

  void awaitPlaceNames() async {
    listArray.clear();
    names = await re.getPlaceDeets();
    points = await re.getPlaceCoors();
    try {
      if (names.length > 0) {
        print(names.length);
        for (var i = 0; i < names.length; i++) {
          listArray.add(new ListTile(
            title: new Text(names[i]),
            onTap: () => re.getRoute(points[i]),
          ));
        }
        setState(() {
          loading = false;
        });
      }
    } on NoSuchMethodError catch (e) {
      print("error");
    }
  }

  MyDrawer({this.onTap, this.trackcontext});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      child: QrImage(
                        data: TrackingScreen.collection_name,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      TrackingScreen.collection_name,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: TrackingScreen.userName,
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  TrackingScreen.userName = value;
                  // name_entered = value;
                  // print(value);
                },
                decoration: InputDecoration(
                  labelText: 'Enter Name',
                  hintText: 'Enter Name',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            Visibility(
              child: ListTile(
                leading: Icon(Icons.location_pin),
                title: Text("Update Master Coordinates"),
                onTap: () => onTapMaster(),
              ),
              visible: TrackingScreen.admin_flag,
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text("Chat with group"),
              onTap: () => onTapChat(),
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text("Refresh list"),
              onTap: () => awaitPlaceNames(),
            ),
            Expanded(
                child: ListView(
              //awaitPlaceNames(),
              children: loading ? [] : listArray,
              // children: [
              //   ListTile(
              //     leading: Icon(Icons.chat),
              //     title: Text("example"),
              //     //onTap: () => onTapChat(),
              //   ),
              // ],
            ))
          ],
        ),
      ),
    );

    _onTapMaster() {
      print("hello");
    }
  }
}
