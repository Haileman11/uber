import 'package:common/authentication/authentication_controller.dart';
import 'package:common/services/navigator_service.dart';
import 'package:common/services/notification_service.dart';
import 'package:driver_app/src/booking-request/booking_request_controller.dart';
import 'package:driver_app/src/booking-request/booking_request_view.dart';
import 'package:driver_app/src/map/map_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateChangesProvider = StreamProvider<bool?>((ref) {
  ref.read(authenticationProvider).userType = UserType.driver;
  return ref.watch(authenticationProvider).authStateChanges();
});
final bookingRequestJsonProvider =
    Provider((ref) => ref.watch(notificationProvider).bookingRequestJson);
