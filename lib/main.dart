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
              marginRight: 18,
              marginBottom: 20,
              overlayOpacity: 0.0,
              children: [
                floatingButton(_addRouteButtonClicked, Icons.add),
                floatingButton(_clearMapButtonClicked, Icons.clear),
                floatingButton(_getPlacesClicked, Icons.local_cafe),
              ],
            )
            // Row(
            //             //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //             //   children: [
            //             //     button('Get Isoline', _addRouteButtonClicked),
            //             //     button('Clear Map', _clearMapButtonClicked),
            //             //     button('Get Places', _getPlacesClicked),
            //             //   ],
            //             // ),
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
    _routingExample.addRoute();
  }

  void _clearMapButtonClicked() {
    _routingExample.clearMap();
  }

  void _getPlacesClicked(){
    _routingExample.getPlaces();
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
  SpeedDialChild floatingButton(Function callbackFunction, IconData icn) {
    return SpeedDialChild(
      child: FloatingActionButton(
        onPressed: () => callbackFunction(),
        child: Icon(icn),
        backgroundColor: Colors.green,
      ),
    );
  }
}
