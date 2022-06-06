import 'package:common/ui/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/booked-ride/booked_ride_controller.dart';
import 'package:passenger_app/src/booked-ride/ui/review.dart';
import 'package:passenger_app/src/booking-request/booking_request_controller.dart';
import 'package:passenger_app/src/booking-request/ui/place_picker.dart';
import 'package:passenger_app/src/home/go.dart';
import 'package:passenger_app/src/map/map_controller.dart';
import 'package:passenger_app/src/map/map_service.dart';

import 'package:passenger_app/src/map/map_view.dart';
import 'package:passenger_app/src/services/location_service.dart';

class BookedRideView extends ConsumerStatefulWidget {
  const BookedRideView({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<BookedRideView> {
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
    final bookedRideController = ref.watch(bookedRideProvider);

    return Scaffold(
      bottomSheet: bookedRideController.activeBooking!.bookedRide!.status ==
              RideStatus.complete
          ? null
          : BottomSheet(
              enableDrag: false,
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: waitingForDriver(context),
                );
              },
            ),
      extendBodyBehindAppBar: true,
      body: (bookedRideController.activeBooking!.bookedRide!.status ==
              RideStatus.complete)
          ? rideComplete(context)
          : Stack(
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
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.6),
                              child: MapView(
                                  setController:
                                      (GoogleMapController controller) {
                                    bookedRideController.controller =
                                        controller;
                                    MapService.updateCameraToPositions(
                                        bookedRideController
                                            .activeBooking!
                                            .bookingRequest
                                            .route
                                            .northeastbound,
                                        bookedRideController
                                            .activeBooking!
                                            .bookingRequest
                                            .route
                                            .southwestbound,
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

  Widget waitingForDriver(BuildContext context) {
    final mapController = ref.watch(mapProvider);
    final bookedRideController = ref.watch(bookedRideProvider);
    final booking = ref.watch(bookedRideProvider).activeBooking;
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        radius: 40.0,
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            NetworkImage("https://picsum.photos/200/300"),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "${booking!.bookedRide!.driverInfo.firstName} ${booking.bookedRide!.driverInfo.firstName}",
                                  style: Theme.of(context).textTheme.headline6,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "${booking.bookedRide!.driverInfo.userName}",
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "${booking.bookedRide!.driverInfo.licensePlate}",
                                ),
                              ),
                            ],
                          ),
                          RatingBar.builder(
                            initialRating: 4.0,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            ignoreGestures: true,
                            unratedColor: Theme.of(context).backgroundColor,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            tapOnlyMode: true,
                            itemSize: 20,
                            onRatingUpdate: (rating) {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Center(child: Text("Your driver is on the way.")),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Chip(
                          label:
                              Text(booking.bookedRide!.status!.toShortString()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            bookedRideController.cancelRide();
                          },
                          child: Text("Cancel Ride"),
                        ),
                      ),
                    ]),

                // TextFormField(
                //   decoration: InputDecoration(
                //     labelText: "From",
                //   ),
                //   focusNode: AlwaysDisabledFocusNode(),
                //   initialValue: bookedRideController
                //             .ongoingRide!. ,
                // ),
                // const SizedBox(
                //   height: 15.0,
                // ),
                // TextFormField(
                //   focusNode: AlwaysDisabledFocusNode(),
                //   decoration: InputDecoration(
                //     labelText: "To",
                //   ),
                //   controller: _destinationController,
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget rideComplete(BuildContext context) {
    final mapController = ref.watch(mapProvider);
    final bookedRideController = ref.watch(bookedRideProvider);
    return Container(
      padding: const EdgeInsets.all(8.0),
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
                    child: Text(
                  "You have reached your destination",
                  style: Theme.of(context).textTheme.headline6,
                )),
                SizedBox(
                  height: 15.0,
                ),
                Center(
                    child: Text(
                        "Your bill is ${bookedRideController.activeBooking!.bookedRide!.price} ETB.",
                        style: Theme.of(context).textTheme.headline6)),
                ReviewView(bookedRideController.activeBooking!)
              ],
            )
          ],
        ),
      ),
    );
  }
}
