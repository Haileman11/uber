import 'package:driver_app/src/map/map_controller.dart';
import 'package:driver_app/src/map/map_view.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_request_controller.dart';

class BookingRequestView extends ConsumerStatefulWidget {
  const BookingRequestView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<BookingRequestView> createState() => _BookingRequestViewState();
}

class _BookingRequestViewState extends ConsumerState<BookingRequestView> {
  late final ThemeData _theme;
  late final locationController;
  late final mapController;
  late final bookedRideController;
  late final bookingRequestController;
  @override
  void initState() {
    _theme = Theme.of(context);
    locationController = ref.watch(locationProvider);
    mapController = ref.watch(mapProvider);
    bookingRequestController = ref.watch(bookingRequestProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet:
          bookingRequestWidget(mapController, bookingRequestController),
      body: Stack(children: [
        CustomScrollView(physics: NeverScrollableScrollPhysics(), slivers: [
          SliverToBoxAdapter(
            child: Container(
                constraints: BoxConstraints(
                    maxHeight: mapController.destinations.isEmpty
                        ? MediaQuery.of(context).size.height
                        : MediaQuery.of(context).size.height * 0.6),
                child: MapView(
                    myLocation: locationController.myLocation,
                    polylines: mapController.polylines,
                    markers: mapController.markers)),
          ),
        ]),
      ]),
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
