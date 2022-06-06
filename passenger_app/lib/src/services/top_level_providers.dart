import 'package:common/authentication/authentication_controller.dart';
import 'package:common/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passenger_app/src/booking/booking.dart';
import 'package:passenger_app/src/services/booking_data.dart';

final authStateChangesProvider = StreamProvider<bool?>((ref) {
  ref.read(authenticationProvider).userType = UserType.client;
  return ref.watch(authenticationProvider).authStateChanges();
});
final bookingStateChangesProvider = StreamProvider<Booking?>((ref) {
  return ref.watch(bookingDataProvider).activeBookingStateChanges();
});
// final ongoingRideJsonProvider =
//     Provider((ref) => ref.watch(notificationProvider).ongoingRideJson);
// final completeRideJsonProvider =
//     Provider((ref) => ref.watch(notificationProvider).completeRideJson);
