import 'package:driver_app/src/booking-request/booking_request_view.dart';
import 'package:driver_app/src/services/booking_data.dart';
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
  }

  LatLng? myLocation;

  String? _placeDistance;

  final _destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final locationController = ref.watch(locationProvider);
    final mapController = ref.watch(mapProvider);
    final bookingController = ref.watch(bookingDataProvider);

    return Scaffold(
      bottomSheet: Container(
        padding: const EdgeInsets.all(8.0),
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                bookingController.activityStatus
                    ? "You're Online"
                    : "You're Offline",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "78.0%",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "Acceptance",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "4.75",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "Rating",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "5.0%",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "Cancellation",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Text(bookingController.activityStatus ? "Stop" : "Go"),
          backgroundColor: bookingController.activityStatus
              ? Colors.red
              : Theme.of(context).colorScheme.primary,
          onPressed: () {
            //TODO
            bookingController.toggleActivityStatus(myLocation!);
            mapController.toggleCircle(bookingController.activityStatus);
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
                return Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.70),
                  child: MapView(
                      myLocation: locationController.myLocation,
                      polylines: mapController.polylines,
                      markers: mapController.markers),
                );
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
            IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu))
          ],
        ),
      ),
    );
  }
}
