import 'package:driver_app/src/booking-request/booking_request_view.dart';
import 'package:driver_app/src/services/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:driver_app/src/map/map_controller.dart';
import 'package:driver_app/src/map/map_view.dart';
import 'package:driver_app/src/services/location_service.dart';

class GoTab extends ConsumerStatefulWidget {
  const GoTab({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<GoTab> {
  String? currentAddress;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      myLocation = await ref.read(locationProvider).getMyLocation();
    });
  }

  LatLng? myLocation;

  String? _placeDistance;

  final _destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final locationController = ref.watch(locationProvider);
    final mapController = ref.watch(mapProvider);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Text(mapController.circles.isEmpty ? "Go" : "Stop"),
          backgroundColor: mapController.circles.isEmpty
              ? Theme.of(context).colorScheme.primary
              : Colors.red,
          onPressed: () {
            //TODO
            mapController.toggleCircle();
          }),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Builder(builder: (context) {
              if (locationController.serviceEnabled == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator.adaptive(),
                    ],
                  ),
                );
              } else if (locationController.serviceEnabled!) {
                return CustomScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight: mapController.destinations.isEmpty
                                  ? MediaQuery.of(context).size.height
                                  : MediaQuery.of(context).size.height * 0.6),
                          child: MapView(
                              myLocation: locationController.myLocation,
                              polylines: mapController.polylines,
                              markers: mapController.markers),
                        ),
                      ),
                    ]);
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Location is disabled."),
                      TextButton(
                        onPressed: () async {
                          await Geolocator.openAppSettings();
                          await Geolocator.openLocationSettings();
                          setState(() {});
                        },
                        child: const Text("Request permission"),
                      ),
                      TextButton(
                        onPressed: () async {
                          locationController.getMyLocation();
                        },
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
