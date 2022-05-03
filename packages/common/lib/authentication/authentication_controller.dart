import './view/login.dart';
import './view/otp_verification.dart';
import 'package:common/dio_client.dart';
import 'package:common/services/navigator_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'authentication_service.dart';
import 'authentication_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class AuthenticationController with ChangeNotifier {
  late UserType _userType;
  AuthenticationController(
    this._authenticationService,
    this._navigationService,
  ) {
    loadLoggedInStatus();
    print("IS LOGGED IN: $isLoggedIn");
  }

  late final NavigationService _navigationService;
  // Make SettingsService a private variable so it is not used directly.
  final AuthenticationService _authenticationService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late bool _isLoggedIn;

  // Allow Widgets to read the user's preferred ThemeMode.
  bool get isLoggedIn => _isLoggedIn;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  void loadLoggedInStatus() {
    _isLoggedIn = _authenticationService.isLoggedIn();

    // Important! Inform listeners a change has occurred.
    print("Notified $isLoggedIn");
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> login(
      {required String phoneNumber,
      required String password,
      required String fcmToken}) async {
    // Important! Inform listeners a change has occurred.
    final formData = {
      "username": phoneNumber,
      "password": password,
      "loginRole": _userType.toShortString(),
      "fcmToken": fcmToken
    };
    if (await _authenticationService.login(formData)) {
      loadLoggedInStatus();
    }
    // Persist the changes to a local database or the internet using the
    // SettingService.
  }

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String fcmToken,
  }) async {
    Map<String, String> formData = {};
    // formData['firstName'] = firstName;
    // formData['lastName'] = lastName;
    formData['username'] = phoneNumber;
    formData['phoneNumber'] = phoneNumber;
    formData['password'] = password;
    formData['firstName'] = firstName;
    formData['lastName'] = lastName;
    formData["roletype"] = _userType.toShortString();
    formData['fcmToken'] = fcmToken;
    try {
      if (await _authenticationService.register(formData)) {
        _navigationService.navigateTo(MaterialPageRoute(
            builder: (context) => VerificationScreen(phoneNumber)));
      }
    } catch (e) {}

    // isLoading = false;
    // notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    // isLoading = true;
    // notifyListeners();
    Map<String, dynamic> body = {
      "email": email,
    };
    try {} catch (e) {}
    // isLoading = false;
    // notifyListeners();
  }

  Future<void> confirmPhoneNumber(
      String phoneNumbeer, String otp, bool isReset) async {
    // isLoading = true;
    // notifyListeners();
    Map<String, String> body = {
      "username": phoneNumbeer,
      "code": otp,
    };
    try {
      // dioClient.sharedPrefs.setToken(response.data['token']);
      if (isReset) {
        // _navigationService
        //     .navigateTo(MaterialPageRoute(builder: (context) => NewPassword()));
      } else {
        // ref.watch(tutorsProvider).goToNextPage();
        try {
          if (await _authenticationService.validateOtp(body)) {
            loadLoggedInStatus();
            _navigationService.goBackTo('/');
          }
        } catch (e) {}
      }
    } catch (e) {
      print(e.toString());
    }
    // isLoading = false;
    // notifyListeners();
  }

  Future<void> changePassword(dynamic data, bool isForgot) async {
    // isLoading = true;
    // notifyListeners();
    try {
      isForgot
          ? _navigationService.navigatorKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => Login()), (route) => false)
          : _navigationService.goBack();
    } catch (e) {}
    // isLoading = false;
    // notifyListeners();
  }

  Future<void> logout() async {
    await _authenticationService.logout();
    loadLoggedInStatus();
  }

  Stream<bool> authStateChanges() {
    return Stream.value(isLoggedIn);
  }

  set userType(userType) {
    _userType = userType;
  }
}

enum UserType { driver, client }

extension UserTypeExtension on UserType {
  String toShortString() {
    return toString().split('.').last;
  }
}

final authenticationProvider = ChangeNotifierProvider<AuthenticationController>(
  (ref) => AuthenticationController(
    AuthenticationService(
      ref.read(dioClientProvider),
    ),
    ref.read(navigationProvider),
  ),
);
