import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService with ChangeNotifier {
  bool? serviceEnabled;
  late LatLng myLocation;

  bool isStreaming = false;
  Future<LatLng> getMyLocation() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    LocationPermission permission;

    // Test if location services are enabled.
    if (!serviceEnabled!) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    notifyListeners();
    print(position.latitude);
    print(position.longitude);
    myLocation = LatLng(position.latitude, position.longitude);
    return myLocation;
  }

  void startLocationStream() {
    _locationController = StreamController<LatLng>();
    Geolocator.requestPermission().then((locationPermission) {
      if (locationPermission != LocationPermission.denied &&
          locationPermission != LocationPermission.deniedForever) {
        // If granted listen to the onLocationChanged stream and emit over our controller
        Geolocator.getPositionStream().listen((locationData) {
          if (!_locationController.isClosed) {
            _locationController.add(LatLng(
              locationData.latitude,
              locationData.longitude,
            ));
          }
        });
      }
    });
    isStreaming = true;
    notifyListeners();
  }

  late StreamController<LatLng> _locationController;

  Stream<LatLng> get locationStream => _locationController.stream;

  void stopLocationStream() {
    _locationController.close();
    isStreaming = false;
    notifyListeners();
  }
}

final locationProvider = ChangeNotifierProvider(((ref) => LocationService()));
// final locationStreamProvider =
//     StreamProvider.autoDispose(((ref) => ref.read(locationProvider).locationStream));
