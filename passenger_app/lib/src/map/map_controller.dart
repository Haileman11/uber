import 'package:common/dio_client.dart';
import 'package:common/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booking-request/booking_request.dart';
import 'package:passenger_app/src/booking-request/booking_request_controller.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:tuple/tuple.dart';

import 'map_service.dart';

class MapController with ChangeNotifier {
  GlobalKey mapKey = GlobalKey(debugLabel: "googlemap");
  MapController(this._mapService, this.ref) {
    Future.sync(() async {
      _darkMapStyle = await _mapService.loadDarkMapStyles();
      _lightMapStyle = await _mapService.loadLightMapStyles();
    });
  }
  final MapService _mapService;
  late GoogleMapController controller;
  ChangeNotifierProviderRef<MapController> ref;
  bool isLoading = false;

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

  void updateCameraToPositions(LatLng origin, LatLng destination) {
    double startLatitude = origin.latitude;
    double startLongitude = origin.longitude;
    double destinationLatitude = destination.latitude;
    double destinationLongitude = destination.longitude;

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

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );
  }

  Future<double> calculateDistance(LatLng origin, LatLng destination,
      {List<LatLng> waypoints = const []}) async {
    isLoading = true;
    notifyListeners();
    try {
      BookingRequest bookingRequest = await ref
          .read(bookingRequestProvider)
          .calculatePolyline(origin, destination, waypoints);
      decodePolyline(bookingRequest.polyline, bookingRequest.polylineId);
      notifyListeners();
      updateCameraToPositions(origin, destination);
      isLoading = false;
      notifyListeners();
      return bookingRequest.distance;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return Future.error(e);
    }
  }

  void addDestination(LatLng selectedLocation) async {
    var destinationName = await MapService.getAddress(selectedLocation);
    destinations.add(Tuple2(destinationName, selectedLocation));
    markers.add(
      Marker(
        markerId: MarkerId(selectedLocation.toString()),
        position: selectedLocation,
      ),
    );
    notifyListeners();
  }

  void addPolyline(PolylineId polylineId, Polyline polyline) {
    polylines[polylineId] = polyline;
    notifyListeners();
  }

  void clearDestinations() {
    markers.clear();
    destinations.clear();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: ref.read(locationProvider).myLocation, zoom: 16)));
    notifyListeners();
  }

  void clearPolylines() {
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
