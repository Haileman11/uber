import 'package:driver_app/src/booked-ride/ui/ongoing_ride_view.dart';
import 'package:driver_app/src/map/map_service.dart';
import 'package:driver_app/src/map/map_view.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:driver_app/src/services/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'booking_request_controller.dart';

class BookingRequestView extends ConsumerStatefulWidget {
  const BookingRequestView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<BookingRequestView> createState() => _BookingRequestViewState();
}

class _BookingRequestViewState extends ConsumerState<BookingRequestView> {
  @override
  Widget build(BuildContext context) {
    final locationController = ref.watch(locationProvider);
    final bookingRequestController = ref.watch(bookingRequestProvider);

    return Scaffold(
      bottomSheet: bookingRequestWidget(bookingRequestController),
      body: Stack(children: [
        CustomScrollView(physics: NeverScrollableScrollPhysics(), slivers: [
          SliverToBoxAdapter(
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: bookingRequestController.destinations.isEmpty
                      ? MediaQuery.of(context).size.height
                      : MediaQuery.of(context).size.height * 0.6),
              child: MapView(
                  setController: (GoogleMapController controller) {
                    bookingRequestController.controller = controller;
                    MapService.updateCameraToPositions(
                        bookingRequestController.bookingRequest!.northeastbound,
                        bookingRequestController.bookingRequest!.southwestbound,
                        controller);
                  },
                  myLocation: locationController.myLocation,
                  polylines: bookingRequestController.polylines,
                  markers: bookingRequestController.markers),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget bookingRequestWidget(
      BookingRequestController bookingRequestController) {
    return BottomSheet(
        enableDrag: false,
        onClosing: () {},
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${bookingRequestController.bookingRequest!.price}",
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
                              "${bookingRequestController.bookingRequest!.distance} m",
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
                    initialValue:
                        bookingRequestController.bookingRequest!.startaddress,
                    decoration: InputDecoration(
                      labelText: "From",
                    ),
                    focusNode: AlwaysDisabledFocusNode(),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    initialValue:
                        bookingRequestController.bookingRequest!.endaddress,
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
                              await bookingRequestController
                                  .acceptBookingRequest(false);
                              Navigator.of(context).pop();
                            },
                            child: Text("Decline")),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                if (await bookingRequestController
                                    .acceptBookingRequest(true)) ;
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => OngoingRideView()),
                                );
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

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
