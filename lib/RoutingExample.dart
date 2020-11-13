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
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart';
import 'package:here_sdk/routing.dart' as here;
import 'package:here_sdk/search.dart';
import 'package:http/http.dart' as http;
import 'package:poly/poly.dart';
import 'package:toast/toast.dart';

class RoutingExample {
  BuildContext _context;
  MapImage _poiMapImage;
  List<MapMarker> _mapMarkerList = [];
  HereMapController _hereMapController;
  List<MapPolygon> _mapPolygons = [];
  List<MapPolyline> _mapPolyLines = [];
  RoutingEngine _routingEngine;
  var current_lat;
  var current_long;
  int counter = 0;
  List<GeoCoordinates> isolinevertices = new List<GeoCoordinates>();
  List<Point> lp = new List<Point>();
  final List<String> drawerPlaces = new List<String>();
  final List<GeoCoordinates> drawerPoints = new List<GeoCoordinates>();
  // List<GeoCoordinates> polylineMid = new List<GeoCoordinates>();

  RoutingExample(BuildContext context, HereMapController hereMapController) {
    _context = context;
    _hereMapController = hereMapController;

    double distanceToEarthInMeters = 1000;
    // _hereMapController.camera.lookAtPointWithDistance(
    //     GeoCoordinates(28.3654, 77.3233), distanceToEarthInMeters);
    // Setting a tap handler to pick markers from map.

    _setTapGestureHandler();

    // _addPOIMapMarkerUser(GeoCoordinates(28.3654, 77.3233), 0);
    _routingEngine = new RoutingEngine();
  }

  Future<bool> isItIn(double lat, double lon) async {
    if (lp.isNotEmpty) {
      Polygon polygon = new Polygon(lp);
      if (polygon.contains(lat, lon)) {
        return true;
      }
      return false;
    }
    return true;
  }

  Future<void> getRoute(GeoCoordinates geoc) async {
    // print(current_lat);
    // print(current_long);
    var startGeoCoordinates = GeoCoordinates(current_lat, current_long);
    var destinationGeoCoordinates = geoc;
    var startWaypoint = Waypoint.withDefaults(startGeoCoordinates);
    var destinationWaypoint = Waypoint.withDefaults(destinationGeoCoordinates);
    //
    List<Waypoint> waypoints = [startWaypoint, destinationWaypoint];
    // print("inside getroute");
    await _routingEngine
        .calculatePedestrianRoute(waypoints, PedestrianOptions.withDefaults(),
            (RoutingError routingError, List<here.Route> routeList) async {
      if (routingError == null) {
        here.Route route = routeList.first;
        _showRouteDetails(route);
        _showRouteOnMap(route);
        // print("route");
        // return;
      } else {
        // print("no route");
        var error = routingError.toString();
        _showDialog('Error', 'Error while calculating a route: $error');
      }
    });
  }

  Future<void> addRoute(double lat, double long) async {
    isolinevertices = await getVerts(lat, long);
    lp.clear();
    for (GeoCoordinates gc in isolinevertices) {
      lp.add(Point(gc.latitude, gc.longitude));
    }
    _showIsoOnMap(isolinevertices);
  }

  Future<void> getPlaces(List<String> items, var lat, var long) async {
    SearchEngine se = new SearchEngine();
    // Add possible categories to this list.
    Map<String, List<String>> map = {
      "Restaurants": [
        PlaceCategory.eatAndDrink,
        PlaceCategory.eatAndDrinkRestaurant
      ],
      "Hospitals": [PlaceCategory.facilitiesHospitalHealthcare],
      "Cafe": [PlaceCategory.eatAndDrinkCoffeeTea],
      "Hotels": [PlaceCategory.accomodation],
      "Locations": [
        PlaceCategory.sightsAndMuseums,
        PlaceCategory.sightsLandmarkAttaction,
        PlaceCategory.sightsReligiousPlace
      ],
      "Facilities": [
        PlaceCategory.facilitiesEducation,
        PlaceCategory.facilitiesEventSpaces,
        PlaceCategory.facilitiesLibrary,
        PlaceCategory.facilitiesHospitalHealthcare,
        PlaceCategory.facilitiesParking
      ],
      "Transport": [PlaceCategory.transport],
      "Businesses": [PlaceCategory.businessAndServices],
    };
    List<PlaceCategory> cats = List<PlaceCategory>();
    for (var i in items) {
      for (var j in map[i]) {
        cats.add(PlaceCategory.withId(j));
      }
    }
    _hereMapController.camera
        .lookAtPointWithDistance(GeoCoordinates(lat, long), 1200);
    print(cats);
    lp.clear();
    for (GeoCoordinates gc in isolinevertices) {
      lp.add(Point(gc.latitude, gc.longitude));
    }
    Polygon polygon = new Polygon(lp);
    counter = 0;
    drawerPlaces.clear();
    drawerPoints.clear();
    for (int i = 0; i < 25; i++) {
      // Center of the area.
      GeoCoordinates center = _createRandomGeoCoordinatesInViewport();
      // Until random point is in the isoline polygon.
      while (!polygon.contains(center.latitude, center.longitude)) {
        center = _createRandomGeoCoordinatesInViewport();
      }
      CategoryQuery query = new CategoryQuery(cats, center);

      se.searchByCategory(query, new SearchOptions.withDefaults(), getDeets);
    }
  }

  Future<List<String>> getPlaceDeets() async {
    return drawerPlaces;
  }

  Future<List<GeoCoordinates>> getPlaceCoors() async {
    return drawerPoints;
  }

  Future<List<GeoCoordinates>> getVerts(var lat, var lon) async {
    Map data;
    List coordinates;
    List<GeoCoordinates> vertices = List<GeoCoordinates>();
    // var lat = 28.3654;
    // var lon = 77.3233;
    var range = 300;
    var rangeType = "distance";
    var response = await http.get(
        Uri.encodeFull(
            "https://isoline.route.ls.hereapi.com/routing/7.2/calculateisoline.json?apiKey=1K_rnKa0dsHsr6aPqKSCc2VBFGbxbEwx-vZhopO7u2I&mode=shortest;car;traffic:enabled&start=geo!$lat,$lon&range=$range&rangetype=$rangeType"),
        headers: {"Accept": "application/json"});
    data = json.decode(response.body);
    coordinates = data["response"]["isoline"][0]["component"][0]["shape"];
    for (var coordinate in coordinates) {
      vertices.add(GeoCoordinates(double.parse(coordinate.split(",")[0]),
          double.parse(coordinate.split(",")[1])));
    }
    return vertices;
  }

  Future<void> getDeets(SearchError e, List<Place> results) async {
    // List<GeoCoordinates> vertices = new List<GeoCoordinates>();
    // vertices = await getVerts();
    lp.clear();
    for (GeoCoordinates gc in isolinevertices) {
      lp.add(Point(gc.latitude, gc.longitude));
    }
    Polygon polygon = new Polygon(lp);
    if (e == null) {
      // var count = 0;
      for (var place in results) {
        // print(place.geoCoordinates.latitude);
        // print(place.geoCoordinates.longitude);

        if (polygon.contains(
            place.geoCoordinates.latitude, place.geoCoordinates.longitude)) {
          // print("Done");
          // _showDialog("place", "this");
          counter++;
          //_addPOIMapMarker(place.geoCoordinates, 0, place);
          bool flag = false;
          for (var k in drawerPlaces) {
            if (place.title == k) {
              flag = true;
              break;
            }
          }
          if (!flag) {
            _addPOIMapMarker(place.geoCoordinates, 0, place);
            drawerPlaces.add(place.title);
            drawerPoints.add(place.geoCoordinates);
          }
          //drawerSubs.add(await _getRouteDetails(place.geoCoordinates));
        }
        // _addPOIMapMarker(place.geoCoordinates, 0);
        // if (count < 5){
        //   _hereMapController.mapScene.addMapMarker(MapMarker(place.geoCoordinates, MapImage.withFilePathAndWidthAndHeight("/home/maanas/AndroidStudioProjects/isoline/assets/poi.png", 50, 50))
        //   );
        //   _addPOIMapMarker(place.geoCoordinates, 0);
        // }
        // var k = place.title;
        // _showDialog("lat", '$k');
      }
    } else {
      print(e);
    }
    if (counter == 0) {
      showToast("Category not found in range.");
    }
  }

  Future<void> _addPOIMapMarker(
      GeoCoordinates geoCoordinates, int drawOrder, Place place) async {
    // Reuse existing MapImage for new map markers.

    Uint8List imagePixelData;
    imagePixelData = await _loadFileAsUint8List('round.png');
    _poiMapImage =
        MapImage.withPixelDataAndImageFormat(imagePixelData, ImageFormat.png);

    // By default, the anchor point is set to 0.5, 0.5 (= centered).
    // Here the bottom, middle position should point to the location.
    Anchor2D anchor2D = Anchor2D.withHorizontalAndVertical(0.5, 1);

    MapMarker mapMarker =
        MapMarker.withAnchor(geoCoordinates, _poiMapImage, anchor2D);
    mapMarker.drawOrder = drawOrder;
    Metadata metadata = new Metadata();
    metadata.setString("key_poi", place.title);
    metadata.setDouble("latitude", place.geoCoordinates.latitude);
    metadata.setDouble("longitude", place.geoCoordinates.longitude);

    //metadata.setString("key_poi", "Metadata: This is a POI.");

    var flag = 0;
    for (MapMarker i in _mapMarkerList) {
      if (i == mapMarker) {
        flag = 1;
      }
    }
    if (flag == 0) {
      mapMarker.metadata = metadata;
      _hereMapController.mapScene.addMapMarker(mapMarker);
      _mapMarkerList.add(mapMarker);
    }
  }

  Future<void> _addPOIMapMarkerUser(
      GeoCoordinates geoCoordinates, int drawOrder) async {
    // Reuse existing MapImage for new map markers.
    if (_poiMapImage == null) {
      Uint8List imagePixelData;
      imagePixelData = await _loadFileAsUint8List('poi.png');
      _poiMapImage =
          MapImage.withPixelDataAndImageFormat(imagePixelData, ImageFormat.png);
    }

    // By default, the anchor point is set to 0.5, 0.5 (= centered).
    // Here the bottom, middle position should point to the location.
    Anchor2D anchor2D = Anchor2D.withHorizontalAndVertical(0.5, 1);

    MapMarker mapMarker =
        MapMarker.withAnchor(geoCoordinates, _poiMapImage, anchor2D);
    mapMarker.drawOrder = drawOrder;
    // Metadata metadata = new Metadata();
    // metadata.setString("key_poi", place.title);
    // metadata.setDouble("latitude", place.geoCoordinates.latitude);
    // metadata.setDouble("longitude", place.geoCoordinates.longitude);

    //metadata.setString("key_poi", "Metadata: This is a POI.");

    _hereMapController.mapScene.addMapMarker(mapMarker);
  }

  void clearMap() {
    for (var mapPolygon in _mapPolygons) {
      _hereMapController.mapScene.removeMapPolygon(mapPolygon);
    }
    _mapPolygons.clear();
    for (var mapMarker in _mapMarkerList) {
      _hereMapController.mapScene.removeMapMarker(mapMarker);
    }
    _mapMarkerList.clear();
    for (var mapPolyline in _mapPolyLines) {
      _hereMapController.mapScene.removeMapPolyline(mapPolyline);
    }
    _mapPolyLines.clear();
  }

  void clearPlaces() {
    for (var mapMarker in _mapMarkerList) {
      _hereMapController.mapScene.removeMapMarker(mapMarker);
    }
    _mapMarkerList.clear();
  }

  void clearIsoline() {
    for (var mapPolygon in _mapPolygons) {
      _hereMapController.mapScene.removeMapPolygon(mapPolygon);
    }
    _mapPolygons.clear();
  }

  void clearRoute() {
    for (var mapPolyline in _mapPolyLines) {
      _hereMapController.mapScene.removeMapPolyline(mapPolyline);
    }
    _mapPolyLines.clear();
  }

  void _showRouteDetails(here.Route route) async {
    int estimatedTravelTimeInSeconds = route.durationInSeconds;
    int lengthInMeters = route.lengthInMeters;

    String routeDetails = 'Travel Time: ' +
        _formatTime(estimatedTravelTimeInSeconds) +
        ', Length: ' +
        _formatLength(lengthInMeters);

    _showDialog('Route Details', '$routeDetails');
  }

  _showRouteOnMap(here.Route route) async {
    // Show route as polyline.
    GeoPolyline routeGeoPolyline = GeoPolyline(route.polyline);

    double widthInPixels = 20;
    MapPolyline routeMapPolyline = MapPolyline(
        routeGeoPolyline, widthInPixels, Color.fromARGB(150, 255, 0, 0));

    _hereMapController.mapScene.addMapPolyline(routeMapPolyline);
    _mapPolyLines.add(routeMapPolyline);
  }

  String _formatTime(int sec) {
    int hours = sec ~/ 3600;
    int minutes = (sec % 3600) ~/ 60;

    return '$hours:$minutes min';
  }

  String _formatLength(int meters) {
    int kilometers = meters ~/ 1000;
    int remainingMeters = meters % 1000;

    return '$kilometers.$remainingMeters km';
  }

  Future<Uint8List> _loadFileAsUint8List(String fileName) async {
    // The path refers to the assets directory as specified in pubspec.yaml.
    ByteData fileData = await rootBundle.load('assets/' + fileName);
    return Uint8List.view(fileData.buffer);
  }

  // _showPolyLineOnMap(vertices){
  //   GeoPolyline polyline = GeoPolyline(vertices);
  //   MapPolyline mapPolyline = MapPolyline(
  //       polyline, 500,Color.fromARGB(160, 0, 144, 138));
  //   _hereMapController.mapScene.addMapPolyline(mapPolyline);
  //   _mapPolyLines.add(mapPolyline);
  // }
  _showIsoOnMap(vertices) {
    // Show route as polyline.
    GeoPolygon isolineGeoPolylgon = GeoPolygon(vertices);

    //double widthInPixels = 20;
    MapPolygon isolineMapPolygon =
        MapPolygon(isolineGeoPolylgon, Color.fromARGB(160, 0, 144, 180));

    _hereMapController.mapScene.addMapPolygon(isolineMapPolygon);
    _mapPolygons.add(isolineMapPolygon);
  }

  void _setTapGestureHandler() {
    _hereMapController.gestures.tapListener =
        TapListener.fromLambdas(lambda_onTap: (Point2D touchPoint) {
      _pickMapMarker(touchPoint);
    });
  }

  void _pickMapMarker(Point2D touchPoint) {
    double radiusInPixel = 2;
    _hereMapController.pickMapItems(touchPoint, radiusInPixel,
        (pickMapItemsResult) {
      List<MapMarker> mapMarkerList = pickMapItemsResult.markers;
      if (mapMarkerList.length == 0) {
        print("No map markers found.");
        return;
      }

      MapMarker topmostMapMarker = mapMarkerList.first;
      Metadata metadata = topmostMapMarker.metadata;
      if (metadata != null) {
        String message = metadata.getString("key_poi") ?? "No message found.";
        double lat = metadata.getDouble("latitude");
        double lon = metadata.getDouble("longitude");

        _showDialogWithInfo("Name", message, GeoCoordinates(lat, lon));
        return;
      }

      _showDialog("Map Marker picked", "No metadata attached.");
    });
  }

  GeoCoordinates _createRandomGeoCoordinatesInViewport() {
    GeoBox geoBox = _hereMapController.camera.boundingBox;
    if (geoBox == null) {
      // Happens only when map is not fully covering the viewport.
      return GeoCoordinates(52.530932, 13.384915);
    }

    GeoCoordinates northEast = geoBox.northEastCorner;
    GeoCoordinates southWest = geoBox.southWestCorner;

    double minLat = southWest.latitude;
    double maxLat = northEast.latitude;
    double lat = _getRandom(minLat, maxLat);

    double minLon = southWest.longitude;
    double maxLon = northEast.longitude;
    double lon = _getRandom(minLon, maxLon);

    return new GeoCoordinates(lat, lon);
  }

  _routeMaker(GeoCoordinates destination) {
    getRoute(destination);
  }

  double _getRandom(double min, double max) {
    return min + Random().nextDouble() * (max - min);
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

  void showToast(String text) {
    Toast.show(text, _context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }

  Future<void> _showDialogWithInfo(
      String title, String message, GeoCoordinates geo) async {
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
            FlatButton(
              child: Text('Get Route'),
              onPressed: () {
                _routeMaker(geo);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
