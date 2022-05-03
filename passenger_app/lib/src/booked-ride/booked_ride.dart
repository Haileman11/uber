import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookedRide {
  late String bookedRideId;
  late String distance;
  late String price;
  late LatLng origin;
  late LatLng destination;
  late String polyline;
  String? licensePlate;
  RideStatus? status;
  BookedRide({
    required this.bookedRideId,
    required this.distance,
    required this.price,
    required this.origin,
    required this.destination,
    required this.polyline,
  });
  BookedRide.fromJson(json) {
    bookedRideId = json['bookedRideId'];
    distance = json['distance'] ?? "0";
    price = json['price'] ?? "0";
    origin = LatLng(
      double.parse(json['originlatitude']),
      double.parse(json['originlongitude']),
    );
    destination = LatLng(
      double.parse(json['destinationlatitude']),
      double.parse(json['destinationlongitude']),
    );
    polyline = json['polyline'] ?? "";
    licensePlate = json['licensePlateNo'];
    status = RideStatus.values
        .firstWhere((element) => element.toShortString() == json['rideStatus']);
  }
}

enum RideStatus { pending, ongoing, complete }

extension RideStatusToString on RideStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}
