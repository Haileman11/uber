import 'package:driver_app/src/booked-ride/booked_ride.dart';
import 'package:driver_app/src/booking-request/booking_request.dart';

class Booking {
  late BookingRequest bookingRequest;
  BookedRide? bookedRide;
  Booking({
    this.bookedRide,
    required this.bookingRequest,
  });
  Booking.fromJson(json) {
    bookingRequest = BookingRequest.fromJson(json['bookingRequest']);
    bookedRide = json['bookedRide'] == null
        ? null
        : BookedRide.fromJson(json['bookedRide']);
  }
}
