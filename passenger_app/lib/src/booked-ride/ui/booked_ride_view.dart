import 'package:common/ui/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passenger_app/src/booked-ride/booked_ride_controller.dart';
import 'package:passenger_app/src/booking-request/booking_request_controller.dart';
import 'package:passenger_app/src/booking-request/ui/place_picker.dart';
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
      bottomSheet: bookingRequestController.destinations.isEmpty
          ? null
          : BottomSheet(
              enableDrag: false,
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: bookingRequestController.destinations.isEmpty
                      ? loadingIndicator
                      : PageView(
                          controller: pageController,
                          children: [
                            setupLocation(context),
                            if (bookingRequestController.bookingRequest != null)
                              completeOrder(context),
                            waitingForDriver(context)
                          ],
                        ),
                );
              },
            ),
      extendBodyBehindAppBar: true,
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
                                bookingRequestController.destinations.isEmpty
                                    ? MediaQuery.of(context).size.height
                                    : MediaQuery.of(context).size.height * 0.6),
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

          if (bookedRideController.completeRide != null) rideComplete(context)
          // showLocationBottomSheet(mapController, context)
        ],
      ),
    );
  }

  Widget setupLocation(BuildContext context) {
    final bookingRequestController = ref.watch(bookingRequestProvider);
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),
            const Card(
              child: ListTile(
                title: Text("My Location"),
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            ...bookingRequestController.destinations.map(((e) => Card(
                    child: ListTile(
                  title: Text(e.item1),
                )))),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: (myLocation != null &&
                        bookingRequestController.destinations.isNotEmpty &&
                        !bookingRequestController.isLoading)
                    ? () async {
                        await bookingRequestController.calculateDistance(
                          myLocation!,
                          bookingRequestController.destinations.first.item2,
                        );
                        pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInCubic);
                      }
                    : null,
                child: (bookingRequestController.isLoading)
                    ? CircularProgressIndicator.adaptive()
                    : const Text("Next"),
              ),
            ),
            TextButton(
                onPressed: () => bookingRequestController.clearDestinations(),
                child: Text("Cancel")),
          ],
        ),
      ),
    );
  }

  Widget completeOrder(BuildContext context) {
    final mapController = ref.watch(mapProvider);
    final bookingRequestController = ref.watch(bookingRequestProvider);
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),
            Text("Select a car"),
            const SizedBox(
              height: 15.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ...bookingRequestController.bookingRequest!.price
                    .map(((package) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            visualDensity: VisualDensity.comfortable,
                            label: Column(
                              children: [
                                Text(package.packageName),
                                Text("${package.price.toStringAsFixed(0)} ETB"),
                              ],
                            ),
                            onSelected: (val) {},
                            selected: false,
                          ),
                        )))
              ],
            ),
            Text(
              "${bookingRequestController.bookingRequest!.distance.toStringAsFixed(0)} meters",
              style: Theme.of(context).textTheme.headline6,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                  onPressed: (myLocation != null &&
                          bookingRequestController.destinations.isNotEmpty &&
                          !bookingRequestController.isLoading)
                      ? () {
                          // ref.read(bookingRequestProvider).bookTrip(
                          //     mapController.polylines.keys.first.value,
                          //     "regular");
                          // pageController.nextPage(
                          //     duration: Duration(milliseconds: 500),
                          //     curve: Curves.easeInCubic);
                        }
                      : null,
                  child: bookingRequestController.isLoading
                      ? CircularProgressIndicator.adaptive()
                      : const Text("Order now")),
            ),
            TextButton(
                onPressed: () {
                  // mapController.clearPolylines();
                  // pageController.previousPage(
                  //     duration: Duration(milliseconds: 500),
                  //     curve: Curves.easeInCubic);
                },
                child: Text("Back")),
          ],
        ),
      ),
    );
  }

  Widget waitingForDriver(BuildContext context) {
    final mapController = ref.watch(mapProvider);
    final bookedRideController = ref.watch(bookedRideProvider);
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
            bookedRideController.ongoingRide == null
                ? Column(
                    children: const [
                      Center(child: Text("Waiting for a driver")),
                      SizedBox(
                        height: 15.0,
                      ),
                      Center(child: CircularProgressIndicator.adaptive()),
                    ],
                  )
                : Column(
                    children: [
                      Center(child: Text("Your driver is on the way.")),
                      SizedBox(
                        height: 15.0,
                      ),
                      Card(
                          child: ListTile(
                              title: Text(bookedRideController
                                  .ongoingRide!.licensePlate!))),
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
              children: [
                Center(child: Text("You have reached your destination")),
                SizedBox(
                  height: 15.0,
                ),
                Center(child: CircularProgressIndicator.adaptive()),
                Center(
                    child: Text(
                        "Your bill is ${bookedRideController.completeRide!.price} ETB.")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
