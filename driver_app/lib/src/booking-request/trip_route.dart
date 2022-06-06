import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripRoute {
  late double distance;
  late LatLng origin;
  late LatLng destination;
  late String polyline;
  late String polylineId;
  late String startaddress;
  late String endaddress;
  late LatLng northeastbound;
  late LatLng southwestbound;
  late String duration;
  TripRoute({
    required this.distance,
    required this.origin,
    required this.destination,
    required this.polyline,
  });
  TripRoute.fromJson(json) {
    distance = double.parse(json['distance'].toString());
    origin = LatLng(
      double.parse(json['origin']['lat']),
      double.parse(json['origin']['lng']),
    );
    destination = LatLng(
      double.parse(json['destination']['lat']),
      double.parse(json['destination']['lng']),
    );
    polyline = json['polylineString'];
    polylineId = json['polylineId'];

    northeastbound = LatLng(
      double.parse(json['northeastbound']['lat']),
      double.parse(json['northeastbound']['lng']),
    );
    southwestbound = LatLng(
      double.parse(json['southwestbound']['lat']),
      double.parse(json['southwestbound']['lng']),
    );
    startaddress = json["startaddress"];
    endaddress = json["endaddress"];
    duration = json["duration"];
  }
}
