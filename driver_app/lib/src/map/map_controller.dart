import 'dart:math';
import 'package:common/settings/settings_controller.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  Set<Circle> circles = {};

  late String _darkMapStyle;
  late String _lightMapStyle;
  String? _placeDistance;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  String googleAPiKey = "AIzaSyAZncMtP-Cfxml3YvAtKLL4uOEeGub4Zrc";
  String googleDirectionsAPiKey = "AIzaSyBRErov981d9m8yhEyHOD7FVPQtfuO7OsI";

  Future setMapStyle(GoogleMapController myController) async {
    switch (ref.watch(settingsProvider).themeMode) {
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

  _createPolylines(double startLatitude, double startLongitude,
      double destinationLatitude, double destinationLongitude) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleDirectionsAPiKey,
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
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
    print(result.points);
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
    await _createPolylines(startLatitude, startLongitude, destinationLatitude,
        destinationLongitude);

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );

    double totalDistance = 0.0;

    // Calculating the total distance by adding the distance
    // between small segments
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += _coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }
    notifyListeners();
    return totalDistance;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void addDestination(LatLng currentPosition) async {
    var destinationName = await _mapService.getAddress(currentPosition);
    destinations.add(Tuple2(destinationName, currentPosition));
    notifyListeners();
  }

  void clearDestinations() {
    destinations.clear();
    polylines.clear();
    polylineCoordinates.clear();
    notifyListeners();
  }

  void toggleCircle() {
    var radius = 500.0;
    circles.isNotEmpty
        ? circles.clear()
        : circles.add(
            Circle(
                circleId: CircleId("circle"),
                fillColor: Color.fromRGBO(128, 128, 128, 0.5),
                center: ref.read(locationProvider).myLocation,
                radius: radius,
                strokeWidth: 1,
                strokeColor: Colors.transparent),
          );
    controller.animateCamera(
        CameraUpdate.newLatLngZoom(ref.read(locationProvider).myLocation, 13));
    notifyListeners();
  }
}

final mapProvider = ChangeNotifierProvider(((ref) {
  return MapController(MapService(), ref);
}));
final markersStreamProvider = StreamProvider(((ref) {
  return ref.watch(mapProvider).markersStateChanges();
}));
