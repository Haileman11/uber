import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookedRide {
  late String bookedRideId;
  late String distance;
  late String price;
  late LatLng origin;
  late LatLng destination;
  late String polyline;
  RideStatus? status;
  BookedRide({
    required this.bookedRideId,
    required this.distance,
    required this.price,
    required this.origin,
    required this.destination,
    required this.polyline,
    required this.status,
  });
  BookedRide.fromJson(json) {
    bookedRideId = json['bookedRideId'];
    distance = json['distance'];
    price = json['price'];
    origin = LatLng(
      double.parse(json['originlatitude']),
      double.parse(json['originlongitude']),
    );
    destination = LatLng(
      double.parse(json['destinationlatitude']),
      double.parse(json['destinationlongitude']),
    );
    polyline = json['polyline'];
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
