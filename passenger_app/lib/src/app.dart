import 'package:common/services/navigator_service.dart';
import 'package:common/settings/settings_controller.dart';
import 'package:common/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/services/notification_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booking-request/ui/place_picker.dart';
import 'package:passenger_app/src/splash_screen.dart';

import 'complete-ride/complete_ride_details_view.dart';
import 'map/map_controller.dart';

/// The Widget that configures your application.
class MyApp extends ConsumerWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    final mapController = ref.watch(mapProvider);

    return MaterialApp(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',

      // Provide the generated AppLocalizations to the MaterialApp. This
      // allows descendant Widgets to display the correct translations
      // depending on the user's locale.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],

      // Use AppLocalizations to configure the correct application title
      // depending on the user's locale.
      //
      // The appTitle is defined in .arb files found in the localization
      // directory.
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,

      // Define a light and dark color theme. Then, read the user's
      // preferred ThemeMode (light, dark, or system default) from the
      // SettingsController to display the correct theme.
      theme: ThemeData(
        // primaryColor: Color.fromARGB(255, 255, 166, 0),
        // primaryColorDark: Colors.yellow[800],
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        // colorScheme: ColorScheme.fromSwatch()
        //     .copyWith(secondary: Colors.black, primary: Colors.yellow[800])
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ref.watch(settingsProvider).themeMode,
      navigatorKey: ref.watch(navigationProvider).navigatorKey,
      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case SettingsView.routeName:
                return const SettingsView();
              // case CompleteRideDetailsView.routeName:
              //   return const CompleteRideDetailsView(routeSettings.arguments);
              // case SampleItemListView.routeName:
              //   return Container();
              case PlacePicker.routeName:
                return PlacePicker();
              default:
                return FutureBuilder(
                    future: NotificationService().init(ref),
                    builder: (context, snapshot) {
                      return SplashScreen();
                    });
            }
          },
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
