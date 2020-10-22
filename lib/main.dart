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
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:collection/collection.dart';
import 'RoutingExample.dart';

void main() {
  SdkContext.init(IsolateOrigin.main);
  // Making sure that BuildContext has MaterialLocalizations widget in the widget tree,
  // which is part of MaterialApp.
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  // Use _context only within the scope of this widget.
  BuildContext _context;
  RoutingExample _routingExample;
  List<String> result = new List<String>();
  static List<String> isChecked = [];

  @override
  Widget build(BuildContext context) {
    _context = context;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Isoline'),
        ),
        body: Stack(
          children: [
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
            // Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //               children: [
            //                 // button('Get Isoline', _addRouteButtonClicked),
            //                 // button('Clear Map', _clearMapButtonClicked),
            //                 // button('Get Places', _getPlacesClicked),
            //                 switchButton(Icons.place),
            //
            //               ],
            //             ),
            switchButton(Icons.place),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.hybridDay,
        (MapError error) {
      if (error == null) {
        _routingExample = RoutingExample(_context, hereMapController);
      } else {
        print("Map scene not loaded. MapError: " + error.toString());
      }
    });
  }

  void _addRouteButtonClicked() {
    _routingExample.clearIsoline();
    _routingExample.addRoute();
  }

  void _clearMapButtonClicked() {
    _routingExample.clearMap();
  }

  void _clearPlaces() {
    _routingExample.clearPlaces();
  }

  void _clearIsoline() {
    _routingExample.clearIsoline();
  }

  void _getPlacesClicked(List<String> items) {
    _routingExample.getPlaces(items);
  }

  void _clearRoute() {
    _routingExample.clearRoute();
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
  List<String> isChecked = MyApp.isChecked;
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
