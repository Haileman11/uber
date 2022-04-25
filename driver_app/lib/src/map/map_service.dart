import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<String> loadDarkMapStyles() async {
    return await rootBundle
        .loadString('packages/common/assets/map_styles/dark.json');
  }

  Future<String> loadLightMapStyles() async {
    return await rootBundle
        .loadString('packages/common/assets/map_styles/light.json');
  }

  Future<BitmapDescriptor> loadCarBitmap() async {
    return await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 24)),
        Platform.isIOS
            ? 'assets/images/car-ios-32.png'
            : 'assets/images/car-android-128.png');
  }

  Future<List<LatLng>> loadMarkersLocation() async {
    return [
      const LatLng(9.01, 38.78),
      const LatLng(9.02, 38.78),
      const LatLng(9.03, 38.78),
    ];
  }

  Future<String> getAddress(LatLng currentPosition) async {
    List<Placemark> p = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);
    Placemark place = p[0];
    String address = "";
    if (place.subThoroughfare!.isNotEmpty)
      address += "${place.subThoroughfare},";
    if (place.thoroughfare!.isNotEmpty) address += "${place.thoroughfare},";
    if (place.subLocality!.isNotEmpty) address += "${place.subLocality},";
    if (place.locality!.isNotEmpty) address += "${place.locality}";
    return address;
  }
}
