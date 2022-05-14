import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingRequest {
  late double distance;
  late List<Package> price;
  late LatLng origin;
  late LatLng destination;
  late String polyline;
  late String polylineId;
  late String startaddress;
  late String endaddress;
  late LatLng northeastbound;
  late LatLng southwestbound;
  late String duration;
  BookingRequest({
    required this.distance,
    required this.price,
    required this.origin,
    required this.destination,
    required this.polyline,
  });
  BookingRequest.fromJson(json) {
    distance = double.parse(json['distance'].toString());
    Map packages = json['price'];
    price = packages.entries
        .map((package) => Package(package.key, package.value))
        .toList();
    origin = LatLng(
      double.parse(json['origin']['lat']),
      double.parse(json['origin']['lng']),
    );
    destination = LatLng(
      double.parse(json['destination']['lat']),
      double.parse(json['destination']['lng']),
    );
    polyline = json['polyline'];
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

class Package {
  late String packageName;
  late double price;
  Package(this.packageName, this.price);
}
