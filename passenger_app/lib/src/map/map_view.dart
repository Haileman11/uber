import 'dart:async';
import 'package:common/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/map/map_controller.dart';

class MapView extends ConsumerStatefulWidget {
  final LatLng myLocation;
  Function()? onCameraIdle;
  Function(CameraPosition cameraPosition)? onCameraMove;
  Map<PolylineId, Polyline>? polylines;

  List<Marker>? markers;

  bool isPlacePicker;

  MapView({
    Key? key,
    required this.myLocation,
    this.onCameraMove,
    this.onCameraIdle,
    this.polylines,
    this.markers,
    this.isPlacePicker = false,
  }) : super(key: key);

  @override
  MapState createState() => MapState();
}

class MapState extends ConsumerState<MapView> with WidgetsBindingObserver {
  var polylines = <PolylineId, Polyline>{};
  List<Marker> _markers = [];
  late LatLng myLocation;
  @override
  void initState() {
    super.initState();
    myLocation = widget.myLocation;
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() async {
    setState(() {
      ref.read(mapProvider).setMapStyle(ref.read(mapProvider).controller,
          ref.read(settingsProvider).themeMode);
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    MapController mapController = ref.watch(mapProvider);

    return GoogleMap(
      polylines: widget.polylines != null
          ? Set<Polyline>.of(widget.polylines!.values)
          : Set<Polyline>.of(polylines.values),
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      markers:
          widget.markers != null ? widget.markers!.toSet() : _markers.toSet(),
      onMapCreated: (GoogleMapController controller) async {
        if (!widget.isPlacePicker) {
          mapController.controller = controller;
          ref.read(mapProvider).addMapStyleListner(controller);
        } else {
          ref
              .read(mapProvider)
              .setMapStyle(controller, ref.read(settingsProvider).themeMode);
        }
      },
      initialCameraPosition: CameraPosition(
        target: myLocation,
        // LatLng(9.02484323873786, 38.78085709626648),
        zoom: 16.0,
      ),
      onCameraIdle: widget.onCameraIdle,
      onCameraMove: widget.onCameraMove,
    );
  }
}
