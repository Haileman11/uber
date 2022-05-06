import 'dart:io';
import 'dart:math';

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
  static const calculatePolylineUrl = "Request/calculate-polyline";
  MapService(this._dioClient);
  Future<String> loadDarkMapStyles() async {
    return await rootBundle
        .loadString('packages/common/assets/map_styles/dark.json');
  }

  Future<String> loadLightMapStyles() async {
    return await rootBundle
        .loadString('packages/common/assets/map_styles/light.json');
  }

  static Future<BitmapDescriptor> loadCarBitmap() async {
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

  Future<Map> getPolyline(
    LatLng origin,
    LatLng destination,
    List<LatLng> wayPoints,
  ) async {
    try {
      List wayPointsArray = ["ds"];
      for (var point in wayPoints) {
        wayPointsArray.add("'${point.latitude},${point.longitude}'");
      }

      Response response = await _dioClient.dio.post(calculatePolylineUrl,
          data: {
            "origin": {
              "latitude": origin.latitude,
              "longitude": origin.longitude
            },
            "destination": {
              "latitude": destination.latitude,
              "longitude": destination.longitude
            },
            "wayPoints": ["string"]
          },
          options: Options(headers: {'requiresToken': true}));
      return response.data;
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  static String encodePoly(List<List<double>> coordinates, int? precision) {
    if (coordinates.length == null) {
      return '';
    }

    num factor = pow(10, precision is int ? precision : 5);

    var output = _encode(coordinates[0][0], 0, factor.toInt()) +
        _encode(coordinates[0][1], 0, factor.toInt());

    for (var i = 1; i < coordinates.length; i++) {
      var a = coordinates[i], b = coordinates[i - 1];
      output += _encode(a[0], b[0], factor.toInt());
      output += _encode(a[1], b[1], factor.toInt());
    }

    return output;
  }

  /// Returns the character string
  /// @param {double} current
  /// @param {double} previous
  /// @param {int} factor
  /// @returns {String}
  static String _encode(double current, double previous, int factor) {
    final _current = (current * factor).round();
    final _previous = (previous * factor).round();

    var coordinate = _current - _previous;
    coordinate <<= 1;
    if (_current - _previous < 0) {
      coordinate = ~coordinate;
    }

    var output = '';
    while (coordinate >= 0x20) {
      output += String.fromCharCode((0x20 | (coordinate & 0x1f)) + 63);
      coordinate >>= 5;
    }
    output += String.fromCharCode(coordinate + 63);
    return output;
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
      LatLng origin, LatLng destination, GoogleMapController controller) {
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
}
