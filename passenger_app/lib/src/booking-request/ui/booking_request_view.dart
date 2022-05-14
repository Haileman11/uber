import 'package:common/ui/loadingIndicator.dart';
import 'package:common/ui/show_snackbar.dart';
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
import 'package:tuple/tuple.dart';

class BookingRequestView extends ConsumerStatefulWidget {
  const BookingRequestView({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<BookingRequestView> {
  String? currentAddress;

  var pageController = PageController();
  int selectedIndex = 0;
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
    final mapController = ref.watch(mapProvider);
    final bookingRequestController = ref.watch(bookingRequestProvider);
    final bookedRideController = ref.watch(bookedRideProvider);

    return Scaffold(
      bottomSheet: BottomSheet(
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
                      if (bookingRequestController.bookingRequest != null)
                        completeOrder(context),
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
                              bookingRequestController.controller = controller;
                              MapService.updateCameraToPositions(
                                  bookingRequestController
                                      .bookingRequest!.northeastbound,
                                  bookingRequestController
                                      .bookingRequest!.southwestbound,
                                  controller);
                            },
                            myLocation: locationController.myLocation,
                            polylines: bookingRequestController.polylines,
                            markers: bookingRequestController.markers),
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

  void placePickerHandler(
      MapController mapController, LocationService locationController) async {
    Tuple2<String, LatLng>? selectedLocation = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => PlacePicker()));
    if (selectedLocation != null) {
      ref.read(bookingRequestProvider).addDestination(
            selectedLocation,
          );

      MapService.updateCameraToPositions(locationController.myLocation,
          selectedLocation.item2, ref.read(bookingRequestProvider).controller);
    }
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
            Text(
              "Select Ride",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 150.0,
              child: ListView.builder(
                itemCount:
                    bookingRequestController.bookingRequest!.price.length,
                padding: const EdgeInsets.all(16.0),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) {
                  var package =
                      bookingRequestController.bookingRequest!.price[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      )),
                      avatarBorder: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      label: Column(
                        children: [
                          SizedBox(
                              width: 100,
                              child: Image.asset(
                                'assets/images/${package.packageName}.png',
                                height: 50,
                                fit: BoxFit.cover,
                              )),
                          Text(package.packageName),
                          Text("${package.price.toStringAsFixed(0)} ETB"),
                        ],
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selectedIndex = index;
                          }
                          print(selectedIndex);
                        });
                      },
                      selected: selectedIndex == index,
                    ),
                  );
                },
              ),
            ),
            // Text(
            //   "${bookingRequestController.bookingRequest!.distance.toStringAsFixed(0)} meters",
            //   style: Theme.of(context).textTheme.headline6,
            // ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                  onPressed: (myLocation != null &&
                          bookingRequestController.destinations.isNotEmpty &&
                          !bookingRequestController.isLoading)
                      ? () {
                          ref.read(bookingRequestProvider).bookTrip(
                              bookingRequestController
                                  .polylines.keys.first.value,
                              bookingRequestController.bookingRequest!
                                  .price[selectedIndex].packageName);

                          Navigator.of(context).pop();
                          showSnackBar(
                              context, "Successfully requested ride.", false);
                        }
                      : null,
                  child: bookingRequestController.isLoading
                      ? CircularProgressIndicator.adaptive()
                      : const Text("Request ride")),
            ),
          ],
        ),
      ),
    );
  }
}
