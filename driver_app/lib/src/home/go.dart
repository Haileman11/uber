import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:driver_app/src/booking-request/booking_request_controller.dart';
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
    final bookedRideController = ref.watch(bookedRideProvider);
    final bookingRequestController = ref.watch(bookingRequestProvider);

    return Scaffold(
      bottomSheet: bookingRequestController.bookingRequest == null
          ? null
          : bookingRequestWidget(mapController, bookingRequestController),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: bookingRequestController.bookingRequest != null
          ? null
          : FloatingActionButton(
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
                          setState(() {});
                        },
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                );
              }
            }),
            if (bookedRideController.bookedRide != null)
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
            if (bookedRideController.bookedRide != null)
              Positioned(
                left: 0,
                top: 0,
                right: 0,
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
          ],
        ),
      ),
    );
  }

  Widget bookingRequestWidget(MapController mapController,
      BookingRequestController bookingRequestController) {
    return BottomSheet(
        enableDrag: false,
        onClosing: () {
          mapController.clearDestinations();
        },
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    height: 10.0,
                  ),
                  Card(
                    child: ListTile(
                      leading: Text("Price"),
                      title: Text(bookingRequestController.bookingRequest!.price
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
                      title: Text(bookingRequestController
                              .bookingRequest!.distance
                              .toStringAsFixed(0) +
                          " meters"),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            onPressed: () async {
                              await bookingRequestController
                                  .acceptBookingRequest(false);
                              mapController.clearDestinations();
                            },
                            child: Text("Decline")),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                await bookingRequestController
                                    .acceptBookingRequest(true);
                              },
                              child: const Text("Accept")),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
