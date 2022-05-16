import 'package:common/ui/loadingIndicator.dart';
import 'package:driver_app/src/booked-ride/booked_ride.dart';
import 'package:driver_app/src/booked-ride/ui/ride_summary_view.dart';
import 'package:driver_app/src/booking-request/booking_request_view.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
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
      bottomSheet: ongoingRideWidget(bookedRideController, locationController),
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
                              MapService.updateCameraToPositions(
                                  bookedRideController
                                      .bookedRide!.northeastbound,
                                  bookedRideController
                                      .bookedRide!.southwestbound,
                                  controller);
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
        ],
      ),
    );
  }

  Widget ongoingRideWidget(BookedRideController bookedRideController,
      LocationService locationService) {
    var ongoingRide = bookedRideController.bookedRide;
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "${ongoingRide!.price}",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "Price",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "${ongoingRide.distance} m",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "Distance",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "30 min",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "Duration",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextFormField(
              initialValue: ongoingRide.startaddress,
              decoration: InputDecoration(
                labelText: "From",
              ),
              focusNode: AlwaysDisabledFocusNode(),
            ),
            const SizedBox(
              height: 15.0,
            ),
            TextFormField(
              initialValue: ongoingRide.endaddress,
              focusNode: AlwaysDisabledFocusNode(),
              decoration: InputDecoration(
                labelText: "To",
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                      onPressed: () async {
                        await bookedRideController.cancelRide();
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel")),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                        onPressed: () {
                          !locationService.isStreaming
                              ? bookedRideController.startTrackingTrip()
                              : bookedRideController.completeTrip();
                        },
                        child: Text(!locationService.isStreaming
                            ? "Start trip"
                            : "Complete")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
