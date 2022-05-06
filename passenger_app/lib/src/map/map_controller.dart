import 'package:common/dio_client.dart';
import 'package:common/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_service.dart';

class MapController with ChangeNotifier {
  GlobalKey mapKey = GlobalKey(debugLabel: "googlemap");
  MapController(this._mapService, this.ref) {
    Future.sync(() async {
      _darkMapStyle = await _mapService.loadDarkMapStyles();
      _lightMapStyle = await _mapService.loadLightMapStyles();
    });
  }
  final MapService _mapService;
  late GoogleMapController controller;
  ChangeNotifierProviderRef<MapController> ref;

  late String _darkMapStyle;
  late String _lightMapStyle;

  void setMapStyle(GoogleMapController myController, ThemeMode theme) {
    switch (theme) {
      case ThemeMode.system:
        final theme = WidgetsBinding.instance!.window.platformBrightness;
        if (theme == Brightness.dark) {
          myController.setMapStyle(_darkMapStyle);
        } else {
          myController.setMapStyle(_lightMapStyle);
        }
        break;
      case ThemeMode.light:
        myController.setMapStyle(_lightMapStyle);
        break;
      case ThemeMode.dark:
        myController.setMapStyle(_darkMapStyle);
        break;
    }
  }

  void addMapStyleListner(GoogleMapController myController) {
    ref.listen(settingsProvider,
        (SettingsController? previous, SettingsController next) {
      ThemeMode theme = next.themeMode;
      setMapStyle(myController, theme);
    });
  }
}

final mapProvider = ChangeNotifierProvider(((ref) {
  return MapController(MapService(ref.read(dioClientProvider)), ref);
}));
