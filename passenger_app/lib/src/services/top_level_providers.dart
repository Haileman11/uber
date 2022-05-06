import 'package:common/authentication/authentication_controller.dart';
import 'package:common/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateChangesProvider = StreamProvider<bool?>((ref) {
  ref.read(authenticationProvider).userType = UserType.client;
  return ref.watch(authenticationProvider).authStateChanges();
});
final ongoingRideJsonProvider =
    Provider((ref) => ref.watch(notificationProvider).ongoingRideJson);
final completeRideJsonProvider =
    Provider((ref) => ref.watch(notificationProvider).completeRideJson);
