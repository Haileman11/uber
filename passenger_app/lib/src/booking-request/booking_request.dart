import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'trip_route.dart';

class BookingRequest {
  late String bookingRequestId;
  late TripRoute route;
  // late RideStatus status;
  late double price;
  BookingRequest({
    required this.price,
    required this.route,
  });
  BookingRequest.fromJson(json) {
    bookingRequestId = json['bookingRequestId'];
    price = double.parse(json['price']);
    // status = RideStatus.values
    //     .firstWhere((element) => element.toShortString() == json['requestStatus']);
    route = TripRoute.fromJson(json['polyline']);
  }
}

class Package {
  late String packageName;
  late double price;
  Package(this.packageName, this.price);
}
