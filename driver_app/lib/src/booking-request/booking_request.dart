import 'dart:convert';

import 'trip_route.dart';

class BookingRequest {
  late String bookingRequestId;
  late TripRoute route;
  // late RideStatus status;
  late double price;
  BookingRequest({
    required this.bookingRequestId,
    required this.price,
    required this.route,
  });
  BookingRequest.fromJson(bookingRequestJson) {
    bookingRequestId = bookingRequestJson['bookingRequestId'];
    price = double.parse(bookingRequestJson['price']);
    // status = RideStatus.values
    //     .firstWhere((element) => element.toShortString() == json['requestStatus']);
    route = TripRoute.fromJson(bookingRequestJson['polyline']);
  }
}
