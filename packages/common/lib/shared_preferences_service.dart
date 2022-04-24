import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService with ChangeNotifier {
  SharedPreferences sharedPreferences;
  SharedPreferencesService(this.sharedPreferences);

  void setWalkThroughShown(bool shown) async {
    sharedPreferences.setBool('walk_through_shown', shown);
  }

  Future<bool> isWalkThroughShown() async {
    return sharedPreferences.getBool('walk_through_shown')!;
  }

  String getLanguage() {
    return sharedPreferences.getString('language') ?? "English";
  }

  Future<bool> setLanguage(String lang) {
    return sharedPreferences.setString('language', lang);
  }

  // bool get isLoggedIn {
  //   return sharedPreferences.getString('token') != null &&
  //       sharedPreferences.getString('token') != '';
  // }

  Future<void> setToken(String token) async {
    sharedPreferences.setString('token', token);
  }

  String? getToken() {
    return sharedPreferences.getString('token');
  }

  Future<void> logOut() async {
    await sharedPreferences.remove('token');
    await sharedPreferences.remove('id');
  }

  int? getId() {
    return sharedPreferences.getInt('id');
  }

  void setId(int id) {
    sharedPreferences.setInt('id', id);
  }
}

final sharedPreferencesServiceProvider =
    Provider<SharedPreferencesService>((ref) {
  return SharedPreferencesService(ref.read(sharedPreferencesInstance).maybeWhen(
        data: (value) => value,
        orElse: () => throw UnimplementedError(),
      ));
});

final sharedPreferencesInstance = FutureProvider<SharedPreferences>(
    (_) async => await SharedPreferences.getInstance());
