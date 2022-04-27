import 'dart:io';
import 'dart:math';

import 'package:common/dio_client.dart';
import 'package:common/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:tuple/tuple.dart';

import 'map_service.dart';

class MapController with ChangeNotifier {
  MapController(this._mapService, this.ref) {
    Future.sync(() async {
      _darkMapStyle = await _mapService.loadDarkMapStyles();
      _lightMapStyle = await _mapService.loadLightMapStyles();
    });
  }
  final MapService _mapService;
  late GoogleMapController controller;
  ChangeNotifierProviderRef<MapController> ref;

  Set<Tuple2<String, LatLng>> destinations = {};
  BitmapDescriptor myIcon = BitmapDescriptor.defaultMarker;
  List<Marker> _markers = [];
  List<Marker> get markers => _markers;
  Stream<List<Marker>> markersStateChanges() {
    return Stream.value(_markers);
  }

  late String _darkMapStyle;
  late String _lightMapStyle;
  String? _placeDistance;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  String googleAPiKey = "AIzaSyAZncMtP-Cfxml3YvAtKLL4uOEeGub4Zrc";
  String googleDirectionsAPiKey = "AIzaSyBRErov981d9m8yhEyHOD7FVPQtfuO7OsI";

  void setMapStyle(GoogleMapController myController, ThemeMode theme) {
    switch (theme) {
      case ThemeMode.system:
        final theme = WidgetsBinding.instance!.window.platformBrightness;
        if (theme == Brightness.dark) {
          myController.setMapStyle(_darkMapStyle);
        } else {
          myController.setMapStyle(_lightMapStyle);
        }
        break;
      case ThemeMode.light:
        myController.setMapStyle(_lightMapStyle);
        break;
      case ThemeMode.dark:
        myController.setMapStyle(_darkMapStyle);
        break;
    }
  }

  void addMapStyleListner(GoogleMapController myController) {
    ref.listen(settingsProvider,
        (SettingsController? previous, SettingsController next) {
      ThemeMode theme = next.themeMode;
      setMapStyle(myController, theme);
    });
  }

  Future<void> loadMarkers() async {
    List<LatLng> markersLocation = await _mapService.loadMarkersLocation();
    _markers = markersLocation.map(
      (e) => Marker(
          markerId: MarkerId("Car ${markersLocation.indexOf(e)}"),
          position: e,
          icon: myIcon),
    ) as List<Marker>;

    notifyListeners();
  }

  // _createPolylines(double startLatitude, double startLongitude,
  //     double destinationLatitude, double destinationLongitude) async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleDirectionsAPiKey,
  //     PointLatLng(startLatitude, startLongitude),
  //     PointLatLng(destinationLatitude, destinationLongitude),
  //     travelMode: TravelMode.driving,
  //   );
  //   if (result.points.isNotEmpty) {
  //     for (var point in result.points) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     }
  //   }

  //   PolylineId id = const PolylineId('poly');
  //   Polyline polyline = Polyline(
  //     polylineId: id,
  //     color: Colors.red,
  //     points: polylineCoordinates,
  //     width: 3,
  //   );
  //   polylines[id] = polyline;
  //   print(result.points);
  // }

  Future<double> calculatePolyline(
      LatLng origin, LatLng destination, List<LatLng> wayPoints) async {
    Map response =
        await _mapService.getPolyline(origin, destination, wayPoints);
    String encodedPolylineString = response['polyline'];
    List<PointLatLng> polylinePoints =
        PolylinePoints().decodePolyline(encodedPolylineString);
    List<LatLng> polylineCoordinates = [];
    if (polylinePoints.isNotEmpty) {
      for (var point in polylinePoints) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    return double.parse(response['distance'].toString());
  }

  Future<double> calculateDistance(
      LatLng myLocation, LatLng myDestination) async {
    print(myLocation);
    print(myDestination);
    double startLatitude = myLocation.latitude;
    double startLongitude = myLocation.longitude;
    double destinationLatitude = myDestination.latitude;
    double destinationLongitude = myDestination.longitude;

    // Calculating to check that the position relative
    // to the frame, and pan & zoom the camera accordingly.
    double miny = (startLatitude <= destinationLatitude)
        ? startLatitude
        : destinationLatitude;
    double minx = (startLongitude <= destinationLongitude)
        ? startLongitude
        : destinationLongitude;
    double maxy = (startLatitude <= destinationLatitude)
        ? destinationLatitude
        : startLatitude;
    double maxx = (startLongitude <= destinationLongitude)
        ? destinationLongitude
        : startLongitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

    // Accommodate the two locations within the
    // camera view of the map
    // await _createPolylines(startLatitude, startLongitude, destinationLatitude,
    //     destinationLongitude);
    double totalDistance =
        await calculatePolyline(myLocation, myDestination, []);
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );

    // double totalDistance = 0.0;

    // // Calculating the total distance by adding the distance
    // // between small segments
    // for (int i = 0; i < polylineCoordinates.length - 1; i++) {
    //   totalDistance += _coordinateDistance(
    //     polylineCoordinates[i].latitude,
    //     polylineCoordinates[i].longitude,
    //     polylineCoordinates[i + 1].latitude,
    //     polylineCoordinates[i + 1].longitude,
    //   );
    // }
    notifyListeners();
    return totalDistance;
  }

  // double _coordinateDistance(lat1, lon1, lat2, lon2) {
  //   var p = 0.017453292519943295;
  //   var c = cos;
  //   var a = 0.5 -
  //       c((lat2 - lat1) * p) / 2 +
  //       c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  //   return 12742 * asin(sqrt(a));
  // }

  void addDestination(LatLng currentPosition) async {
    var destinationName = await MapService.getAddress(currentPosition);
    destinations.add(Tuple2(destinationName, currentPosition));
    notifyListeners();
  }

  void clearDestinations() {
    destinations.clear();
    polylines.clear();
    polylineCoordinates.clear();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: ref.read(locationProvider).myLocation, zoom: 16)));
    notifyListeners();
  }
}

final mapProvider = ChangeNotifierProvider(((ref) {
  return MapController(MapService(ref.read(dioClientProvider)), ref);
}));
final markersStreamProvider = StreamProvider(((ref) {
  return ref.watch(mapProvider).markersStateChanges();
}));
