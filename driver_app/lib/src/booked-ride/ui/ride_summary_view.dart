import 'package:common/ui/loadingIndicator.dart';
import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:driver_app/src/booked-ride/ui/ongoing_ride_view.dart';
import 'package:driver_app/src/booking-request/booking_request_view.dart';
import 'package:driver_app/src/map/map_service.dart';
import 'package:driver_app/src/map/map_view.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:driver_app/src/services/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideSummaryView extends ConsumerStatefulWidget {
  const RideSummaryView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<RideSummaryView> createState() => _BookingRequestViewState();
}

class _BookingRequestViewState extends ConsumerState<RideSummaryView> {
  @override
  Widget build(BuildContext context) {
    final bookedRideController = ref.watch(bookedRideProvider);
    final locationController = ref.watch(locationProvider);
    return Scaffold(
      bottomSheet: completeRideWidget(bookedRideController, locationController),
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
          // if (bookingRequestController.bookedRide != null)
          //   Positioned(
          //     left: 0,
          //     bottom: 0,
          //     right: 0,
          //     child: Column(
          //       children: [
          //         ElevatedButton(
          //             onPressed: () {
          //               !locationController.isStreaming
          //                   ? bookedRideController.startTrackingTrip()
          //                   : bookedRideController.completeTrip();
          //             },
          //             child: Text(!locationController.isStreaming
          //                 ? "Start trip"
          //                 : "Complete")),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),

            Container(
              padding: const EdgeInsets.all(8.0),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 10.0,
                    ),
                    Column(
                      children: [
                        Center(
                            child: Text("You have reached your destination")),
                        SizedBox(
                          height: 15.0,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: Text("Price"),
                title: Text(bookedRideController.completeRide!.price
                        .toStringAsFixed(0) +
                    " ETB"),
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            // ...mapController.destinations.map(((e) => Card(
            //         child: ListTile(
            //       title: Text(e.item1),
            //     )))),
            Card(
              child: ListTile(
                leading: Text("Distance"),
                title: Text(bookedRideController.completeRide!.distance
                        .toStringAsFixed(0) +
                    " meters"),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          // if (
                          //   await bookedRideController
                          //     .confirmPayment(true)) {
                          // }
                          Navigator.of(context).pop();
                        },
                        child: const Text("Confirm Payment")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  completeRideWidget(BookedRideController bookedRideController,
      LocationService locationController) {
    var completeRide = bookedRideController.bookedRide;
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
                        "${completeRide!.price}",
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
                        "${completeRide.distance} m",
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
              initialValue: completeRide.startaddress,
              decoration: InputDecoration(
                labelText: "From",
              ),
              focusNode: AlwaysDisabledFocusNode(),
            ),
            const SizedBox(
              height: 15.0,
            ),
            TextFormField(
              initialValue: completeRide.endaddress,
              focusNode: AlwaysDisabledFocusNode(),
              decoration: InputDecoration(
                labelText: "To",
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                  onPressed: () async {
                    // if (
                    //   await bookedRideController
                    //     .confirmPayment(true)) {
                    // }
                    Navigator.of(context).pop();
                  },
                  child: const Text("Confirm Payment")),
            ),
          ],
        ),
      ),
    );
  }
}
