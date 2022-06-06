import 'dart:convert';
import 'dart:io';

import 'package:common/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  /// Persists the user's preferred ThemeMode to local or remote storage.
  late DioClient _dioClient;

  MapService(this._dioClient);
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

  static Future<String> getAddress(LatLng currentPosition) async {
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

  static Polyline decodePolyline(String encodedPolylineString, polylineId) {
    List<PointLatLng> polylinePoints =
        PolylinePoints().decodePolyline(encodedPolylineString);
    List<LatLng> polylineCoordinates = [];
    if (polylinePoints.isNotEmpty) {
      for (var point in polylinePoints) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = PolylineId(polylineId);
    return Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
  }

  static void updateCameraToPositions(
      LatLng northEast, LatLng southWest, GoogleMapController controller) {
    // double startLatitude = origin.latitude;
    // double startLongitude = origin.longitude;
    // double destinationLatitude = destination.latitude;
    // double destinationLongitude = destination.longitude;

    // // Calculating to check that the position relative
    // // to the frame, and pan & zoom the camera accordingly.
    // double miny = (startLatitude <= destinationLatitude)
    //     ? startLatitude
    //     : destinationLatitude;
    // double minx = (startLongitude <= destinationLongitude)
    //     ? startLongitude
    //     : destinationLongitude;
    // double maxy = (startLatitude <= destinationLatitude)
    //     ? destinationLatitude
    //     : startLatitude;
    // double maxx = (startLongitude <= destinationLongitude)
    //     ? destinationLongitude
    //     : startLongitude;

    // double southWestLatitude = miny;
    // double southWestLongitude = minx;

    // double northEastLatitude = maxy;
    // double northEastLongitude = maxx;

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: northEast,
          southwest: southWest,
        ),
        100.0,
      ),
    );
  }
}
