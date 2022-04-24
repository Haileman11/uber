import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:common/dio_client.dart';
import 'package:flutter/material.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class AuthenticationService {
  /// Loads the User's preferred ThemeMode from local or remote storage.

  final loginUrl = "Authentcation/login";
  final registerUrl = "Authentcation/register";
  final forgotPasswordUrl = "Authentcation/forgot-password";
  final resetPasswordUrl = "Authentcation/reset-password";
  final changePasswordUrl = "Authentcation/change-password";
  final validateOtpUrl = "Authentcation/verify-otp";

  late final DioClient _dioClient;
  AuthenticationService(this._dioClient);
  bool isLoggedIn() =>
      _dioClient.sharedPrefs.getToken() != null &&
      _dioClient.sharedPrefs.getToken() != '';

  /// Persists the user's preferred ThemeMode to local or remote storage.

  Future<bool> login(Map<String, String> formData) async {
    Response response;
    try {
      response =
          await _dioClient.dio.post(loginUrl, data: json.encode(formData));
      await _dioClient.sharedPrefs.setToken(response.data['token']);
      // ref.read(tutorsProvider).goToNextPage(shouldPop: shouldPop);
      return true;
    } on DioError catch (e) {
      print(e);
      return false;
    }
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
  }

  Future<void> logout() async {
    await _dioClient.sharedPrefs.logOut();
  }

  Future<bool> register(Map<String, String> formData) async {
    Response response;
    try {
      response =
          await _dioClient.dio.post(registerUrl, data: json.encode(formData));
      return true;
      print(response.data);
    } on DioError catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> forgotPassword(Map<String, String> formData) async {
    Response response;
    try {
      response = await _dioClient.dio
          .post(resetPasswordUrl, data: json.encode(formData));
    } on DioError catch (e) {
      print(e);
    }
  }

  Future<void> resetPassword(Map<String, String> formData) async {
    Response response;
    try {
      response = await _dioClient.dio
          .post(resetPasswordUrl, data: json.encode(formData));
    } on DioError catch (e) {
      print(e);
    }
  }

  Future<void> changePassword(Map<String, String> formData) async {
    Response response;
    try {
      response = await _dioClient.dio.post(
        changePasswordUrl,
        data: formData,
        options: Options(
          headers: {"requiresToken": true},
        ),
      );
    } on DioError catch (e) {
      print(e);
    }
  }

  Future<bool> validateOtp(Map<String, String> formData) async {
    Response response;
    try {
      response = await _dioClient.dio
          .post(validateOtpUrl, data: json.encode(formData));
      await _dioClient.sharedPrefs.setToken(response.data['token']);
      return true;
    } on DioError catch (e) {
      print(e);
      return false;
    }
  }
}
