import 'dart:async';

import 'package:common/map/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends ConsumerStatefulWidget {
  final LatLng myLocation;
  Function()? onCameraIdle;
  Function(CameraPosition cameraPosition)? onCameraMove;
  Map<PolylineId, Polyline>? polylines;

  Completer<GoogleMapController>? controller;

  MapView({
    Key? key,
    required this.myLocation,
    this.controller,
    this.onCameraMove,
    this.onCameraIdle,
    this.polylines,
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
  void didChangePlatformBrightness() {
    setState(() {
      ref.read(mapProvider).setMapStyle(ref.read(mapProvider).controller);
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

    return ref.watch(markersStreamProvider).when(
        data: (List<Marker> data) => GoogleMap(
              polylines: widget.polylines != null
                  ? Set<Polyline>.of(widget.polylines!.values)
                  : Set<Polyline>.of(polylines.values),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: data.toSet(),
              onMapCreated: (GoogleMapController controller) async {
                if (widget.controller == null) {
                  mapController.controller = controller;
                  ref.read(mapProvider).setMapStyle(mapController.controller);
                } else {
                  widget.controller!.complete(controller);
                  ref
                      .read(mapProvider)
                      .setMapStyle(await widget.controller!.future);
                }
              },
              initialCameraPosition: CameraPosition(
                target: myLocation,
                // LatLng(9.02484323873786, 38.78085709626648),
                zoom: 16.0,
              ),
              onCameraIdle: widget.onCameraIdle,
              onCameraMove: widget.onCameraMove,
            ),
        error: (Object error, StackTrace? stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Error loading markers"),
                ],
              ),
            ),
        loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator.adaptive(),
                ],
              ),
            ));
  }
}
