import 'package:passenger_app/src/booking-request/trip_route.dart';
import 'package:passenger_app/src/profile/profile.dart';

class BookedRide {
  late String bookedRideId;
  RideStatus? status;
  late TripRoute polylineToOrigin;
  double? price;
  late Profile driverInfo;
  BookedRide({
    required this.bookedRideId,
    required this.polylineToOrigin,
    required this.status,
  });
  BookedRide.fromJson(json) {
    bookedRideId = json['bookedRideId'];
    polylineToOrigin = TripRoute.fromJson(json["polylineToOrigin"]);
    status = RideStatus.values.firstWhere(
        (element) => element.toShortString() == json['bookedRideStatus']);
    price = double.tryParse(json["price"] ?? "");
    driverInfo = Profile.fromJson(json["driverInfo"]);
  }
}

enum RideStatus { pending, ongoing, complete, cancelled }

extension RideStatusToString on RideStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}
