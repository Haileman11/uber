import 'dart:math';
import 'package:common/dio_client.dart';
import 'package:common/settings/settings_controller.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuple/tuple.dart';

import 'map_service.dart';

class MapController with ChangeNotifier {
  bool isLoading = false;

  MapController(this._mapService, this.ref) {
    Future.sync(() async {
      _darkMapStyle = await _mapService.loadDarkMapStyles();
      _lightMapStyle = await _mapService.loadLightMapStyles();
      myIcon = await MapService.loadCarBitmap();
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

  void setMapStyle(GoogleMapController myController) async {
    ref.listen(settingsProvider,
        (SettingsController? previous, SettingsController next) {
      ThemeMode theme = next.themeMode;
      switch (theme) {
        case ThemeMode.system:
          final theme = WidgetsBinding.instance.window.platformBrightness;
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

  Future<double> calculatePolyline(
      LatLng origin, LatLng destination, List<LatLng> wayPoints) async {
    Map response =
        await _mapService.getPolyline(origin, destination, wayPoints);
    String encodedPolylineString = response['polyline'];
    decodePolyline(encodedPolylineString, response['polylineId']);
    return double.parse(response['distance'].toString());
  }

  void decodePolyline(String encodedPolylineString, polylineId) {
    List<PointLatLng> polylinePoints =
        PolylinePoints().decodePolyline(encodedPolylineString);
    List<LatLng> polylineCoordinates = [];
    if (polylinePoints.isNotEmpty) {
      for (var point in polylinePoints) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = PolylineId(polylineId);
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  void addDestination(LatLng currentPosition) async {
    var destinationName = await MapService.getAddress(currentPosition);
    destinations.add(Tuple2(destinationName, currentPosition));
    notifyListeners();
  }

  void clearDestinations() {
    destinations.clear();
    polylines.clear();
    polylineCoordinates.clear();
    notifyListeners();
  }

  void addPolyline(PolylineId polylineId, Polyline polyline) {
    polylines[polylineId] = polyline;
    notifyListeners();
  }

  void clearPolylines() {
    polylines.clear();
    polylineCoordinates.clear();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: ref.read(locationProvider).myLocation, zoom: 16)));
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
        CameraUpdate.newLatLngZoom(ref.read(locationProvider).myLocation, 15));
    notifyListeners();
  }
}

final mapProvider = ChangeNotifierProvider(((ref) {
  return MapController(MapService(ref.read(dioClientProvider)), ref);
}));
final markersStreamProvider = StreamProvider(((ref) {
  return ref.watch(mapProvider).markersStateChanges();
}));
