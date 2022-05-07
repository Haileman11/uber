import 'package:common/authentication/authentication_controller.dart';
import 'package:common/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile.dart';
import 'profile_service.dart';

class ProfileController with ChangeNotifier {
  Profile? profile;

  final ProfileService _profileService;

  AuthenticationController authenticationController;
  ProfileController(this._profileService, this.authenticationController) {}
  getUserProfile() async {
    var profileData = await _profileService.getUserProfile();
    if (profileData != null) {
      profile = Profile.fromJson(profileData);
    } else {
      authenticationController.logout();
    }
    notifyListeners();
  }
}

final profileProvider = ChangeNotifierProvider(((ref) => ProfileController(
    ProfileService(ref.read(dioClientProvider)),
    ref.read(authenticationProvider))));
