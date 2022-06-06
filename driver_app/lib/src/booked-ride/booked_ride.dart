import 'package:driver_app/src/booking-request/trip_route.dart';
import 'package:driver_app/src/profile/profile.dart';

class BookedRide {
  late String bookedRideId;
  RideStatus? status;
  late TripRoute polylineToOrigin;
  late TripRoute? tripPolyline;
  double? price;
  late Profile passengerInfo;
  BookedRide({
    required this.bookedRideId,
    required this.polylineToOrigin,
    required this.status,
  });
  BookedRide.fromJson(json) {
    bookedRideId = json['bookedRideId'];
    polylineToOrigin = TripRoute.fromJson(json["polylineToOrigin"]);
    if (json["polylineToOrigin"] != null)
      tripPolyline = TripRoute.fromJson(json["polylineToOrigin"]);
    status = RideStatus.values.firstWhere(
        (element) => element.toShortString() == json['bookedRideStatus']);
    price = double.tryParse(json["price"] ?? "");
    passengerInfo = Profile.fromJson(json["passengerInfo"]);
  }
}

enum RideStatus { pending, ongoing, complete }

extension RideStatusToString on RideStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}
