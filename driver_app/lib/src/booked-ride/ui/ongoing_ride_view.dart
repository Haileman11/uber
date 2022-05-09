import 'package:common/ui/loadingIndicator.dart';
import 'package:driver_app/src/booked-ride/booked_ride.dart';
import 'package:driver_app/src/booked-ride/ui/ride_summary_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:driver_app/src/booking-request/booking_request_controller.dart';
import 'package:driver_app/src/map/map_controller.dart';
import 'package:driver_app/src/map/map_service.dart';

import 'package:driver_app/src/map/map_view.dart';
import 'package:driver_app/src/services/location_service.dart';

class OngoingRideView extends ConsumerStatefulWidget {
  const OngoingRideView({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<OngoingRideView> {
  String? currentAddress;

  var pageController = PageController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      myLocation = await ref.read(locationProvider).getMyLocation();
    });
  }

  LatLng? myLocation;

  final _destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final locationController = ref.watch(locationProvider);

    final bookingRequestController = ref.watch(bookingRequestProvider);
    final bookedRideController = ref.watch(bookedRideProvider);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Builder(builder: (context) {
            if (locationController.serviceEnabled == null) {
              return loadingIndicator;
            } else if (locationController.serviceEnabled!) {
              return CustomScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height),
                        child: MapView(
                            setController: (GoogleMapController controller) {
                              bookedRideController.controller = controller;
                            },
                            myLocation: locationController.myLocation,
                            polylines: bookedRideController.polylines,
                            markers: bookedRideController.markers),
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
                        if (await Geolocator.openAppSettings()) {
                          if (await Geolocator.openLocationSettings()) {
                            locationController.getMyLocation();
                          }
                        }
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
          if (bookingRequestController.bookedRide != null)
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        !locationController.isStreaming
                            ? bookedRideController.startTrackingTrip()
                            : bookedRideController.completeTrip();
                      },
                      child: Text(!locationController.isStreaming
                          ? "Start trip"
                          : "Complete")),
                ],
              ),
            ),
          if (bookingRequestController.bookedRide != null)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {},
                        child: CircleAvatar(
                          radius: 25.0,
                          backgroundImage:
                              NetworkImage("https://picsum.photos/200/300"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
