import 'package:authentication/authentication_controller.dart';
import 'package:common/settings/settings_controller.dart';
import 'package:common/settings/settings_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateChangesProvider = StreamProvider<bool?>((ref) {
  ref.read(authenticationProvider).userType = UserType.driver;
  return ref.watch(authenticationProvider).authStateChanges();
});
