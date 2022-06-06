import 'package:common/ui/loadingIndicator.dart';
import 'package:driver_app/src/booked-ride/booked_ride.dart';
import 'package:driver_app/src/booking-request/booking_request_view.dart';
import 'package:driver_app/src/services/booking_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:driver_app/src/map/map_service.dart';

import 'package:driver_app/src/map/map_view.dart';
import 'package:driver_app/src/services/location_service.dart';

class BookedRideView extends ConsumerStatefulWidget {
  const BookedRideView({Key? key}) : super(key: key);

  @override
  _BookedRideState createState() => _BookedRideState();
}

class _BookedRideState extends ConsumerState<BookedRideView> {
  String? currentAddress;

  var pageController = PageController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (ref.read(bookedRideProvider).activeBooking!.bookedRide!.status ==
          RideStatus.ongoing) ref.read(bookedRideProvider).startTrackingTrip();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final locationController = ref.watch(locationProvider);

    final bookedRideController = ref.watch(bookedRideProvider);

    return Scaffold(
      bottomSheet: bookedRideController.activeBooking!.bookedRide!.status ==
              RideStatus.pending
          ? awaitingPassengerWidget()
          : bookedRideController.activeBooking!.bookedRide!.status ==
                  RideStatus.complete
              ? completeRideWidget()
              : ongoingRideWidget(),
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
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.6),
                        child: MapView(
                            setController: (GoogleMapController controller) {
                              bookedRideController.controller = controller;
                              MapService.updateCameraToPositions(
                                  bookedRideController.activeBooking!
                                      .bookingRequest.route.northeastbound,
                                  bookedRideController.activeBooking!
                                      .bookingRequest.route.southwestbound,
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

  Widget ongoingRideWidget() {
    var ongoingRide = ref.read(bookingDataProvider).activeBooking!.bookedRide;
    final bookedRideController = ref.read(bookedRideProvider);
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
                        "${ongoingRide.tripPolyline!.distance} m",
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
                        "${ongoingRide.tripPolyline!.duration} min",
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
              initialValue: ongoingRide.tripPolyline!.startaddress,
              decoration: InputDecoration(
                labelText: "From",
              ),
              focusNode: AlwaysDisabledFocusNode(),
            ),
            const SizedBox(
              height: 15.0,
            ),
            TextFormField(
              initialValue: ongoingRide.tripPolyline!.endaddress,
              focusNode: AlwaysDisabledFocusNode(),
              decoration: InputDecoration(
                labelText: "To",
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                        onPressed: () {
                          bookedRideController.completeTrip();
                        },
                        child: Text("Complete")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget awaitingPassengerWidget() {
    var booking = ref.read(bookingDataProvider).activeBooking!;
    final bookedRideController = ref.read(bookedRideProvider);
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        NetworkImage("https://picsum.photos/200/300"),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "${booking.bookedRide!.passengerInfo.firstName} ${booking.bookedRide!.passengerInfo.firstName}",
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
                              "${booking.bookedRide!.passengerInfo.userName}",
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
                  trailing:
                      IconButton(onPressed: () {}, icon: Icon(Icons.call)),
                ),
              ],
            ),
            const SizedBox(
              height: 15.0,
            ),
            TextFormField(
              initialValue: booking.bookingRequest.route.startaddress,
              decoration: InputDecoration(
                labelText: "From",
              ),
              focusNode: AlwaysDisabledFocusNode(),
            ),
            const SizedBox(
              height: 15.0,
            ),
            TextFormField(
              initialValue: booking.bookingRequest.route.endaddress,
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
                          bookedRideController.startTrip();
                        },
                        child: Text("Start trip")),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  completeRideWidget() {
    var completeRide = ref.read(bookingDataProvider).activeBooking!.bookedRide;
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
                        "${completeRide.tripPolyline!.distance} m",
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
                        "${completeRide.tripPolyline!.duration} min",
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
              initialValue: completeRide.tripPolyline!.startaddress,
              decoration: InputDecoration(
                labelText: "From",
              ),
              focusNode: AlwaysDisabledFocusNode(),
            ),
            const SizedBox(
              height: 15.0,
            ),
            TextFormField(
              initialValue: completeRide.tripPolyline!.endaddress,
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
