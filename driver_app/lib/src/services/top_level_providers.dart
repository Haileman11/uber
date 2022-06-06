import 'package:common/authentication/authentication_controller.dart';
import 'package:common/services/notification_service.dart';
import 'package:driver_app/src/booking/booking.dart';
import 'package:driver_app/src/services/booking_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateChangesProvider = StreamProvider<bool?>((ref) {
  ref.read(authenticationProvider).userType = UserType.driver;
  return ref.watch(authenticationProvider).authStateChanges();
});
// final bookingRequestJsonProvider =
//     Provider((ref) => ref.watch(notificationProvider).bookingRequestJson);
final bookingStateChangesProvider = StreamProvider<Booking?>((ref) {
  return ref.watch(bookingDataProvider).activeBookingStateChanges();
});
