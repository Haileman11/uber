import 'package:common/ui/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passenger_app/src/booking-request/booking_request_controller.dart';
import 'package:passenger_app/src/map/map_service.dart';

import 'package:passenger_app/src/map/map_view.dart';
import 'package:passenger_app/src/services/booking_data.dart';
import 'package:passenger_app/src/services/location_service.dart';

class BookingRequestView extends StatefulWidget {
  const BookingRequestView({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<BookingRequestView> {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);

    return Scaffold(
      bottomSheet: BottomSheet(
        enableDrag: false,
        onClosing: () {},
        builder: (context) {
          return Container(
              padding: const EdgeInsets.all(8.0),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: waitingForDriver(context));
        },
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Consumer(builder: (context, ref, child) {
            final locationController = ref.watch(locationProvider);

            final bookingRequestController = ref.watch(bookingRequestProvider);
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
                              bookingRequestController.controller = controller;
                              MapService.updateCameraToPositions(
                                  bookingRequestController.activeBooking!
                                      .bookingRequest.route.northeastbound,
                                  bookingRequestController.activeBooking!
                                      .bookingRequest.route.southwestbound,
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

  Widget waitingForDriver(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final bookingRequest =
          ref.read(bookingRequestProvider).activeBooking!.bookingRequest;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Waiting for a driver"),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: CircularProgressIndicator.adaptive()),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              if (await ref
                  .read(bookingRequestProvider)
                  .cancelBookingRequest()) {
                ref.read(bookingDataProvider).getBookingData();
              }
            },
            child: Text("Cancel"),
          ),
          Card(
            child: ListTile(
              dense: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 8,
                ),
              ),
              horizontalTitleGap: 4,
              title:
                  Text("From", style: Theme.of(context).textTheme.bodyMedium),
              subtitle: Text(bookingRequest.route.startaddress,
                  style: Theme.of(context).textTheme.bodyText1),
            ),
          ),
          Card(
            child: ListTile(
              dense: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 8,
                ),
              ),
              horizontalTitleGap: 4,
              title: Text("To", style: Theme.of(context).textTheme.bodyMedium),
              subtitle: Text(bookingRequest.route.endaddress,
                  style: Theme.of(context).textTheme.bodyText1),
            ),
          ),
        ],
      );
    });
  }
}
