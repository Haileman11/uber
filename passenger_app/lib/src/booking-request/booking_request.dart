import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingRequest {
  late double distance;
  late List<Package> price;
  // late LatLng origin;
  // late LatLng destination;
  late String polyline;
  late String polylineId;
  BookingRequest({
    required this.distance,
    required this.price,
    // required this.origin,
    // required this.destination,
    required this.polyline,
  });
  BookingRequest.fromJson(json) {
    distance = json['distance'];
    Map packages = json['price'];
    price = packages.entries
        .map((package) => Package(package.key, package.value))
        .toList();
    // origin = LatLng(
    //   double.parse(json['originlatitude']),
    //   double.parse(json['originlongitude']),
    // );
    // destination = LatLng(
    //   double.parse(json['destinationlatitude']),
    //   double.parse(json['destinationlongitude']),
    // );
    polyline = json['polyline'];
    polylineId = json['polylineId'];
  }
}

class Package {
  late String packageName;
  late double price;
  Package(this.packageName, this.price);
}
