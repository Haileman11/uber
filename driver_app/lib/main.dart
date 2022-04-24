import 'package:common/shared_preferences_service.dart';
import 'package:driver_app/src/app.dart';
import 'package:driver_app/src/services/top_level_providers.dart';
import 'package:driver_app/src/settings/settings_controller.dart';
import 'package:driver_app/src/settings/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(overrides: [
    sharedPreferencesServiceProvider.overrideWithValue(
      SharedPreferencesService(sharedPreferences),
    ),
    settingsProvider.overrideWithValue(settingsController)
  ], child: const MyApp()));
}
