import 'package:common/ui/loadingIndicator.dart';
import 'package:common/ui/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booked-ride/ui/booked_ride_view.dart';
import 'package:passenger_app/src/booking-request/ui/booking_request_view.dart';
import 'package:passenger_app/src/home/go.dart';
import 'package:passenger_app/src/map/map_service.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:passenger_app/src/services/place_service.dart';
import 'package:passenger_app/src/services/top_level_providers.dart';

import 'app_drawer.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final bookingState = ref.watch(bookingStateChangesProvider);

    return Scaffold(
      drawer: AppDrawer(),
      body: bookingState.when(
        data: (booking) => booking == null
            ? FutureBuilder<String>(
                future: ref.read(locationProvider).getMyLocation().then(
                      (value) => MapService.getAddress(value),
                    ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return loadingIndicator;
                  }
                  String? currentAddress = snapshot.data;
                  LatLng myLocation = ref.read(locationProvider).myLocation;

                  return GoTab(origin: Place(currentAddress!, myLocation));
                })
            : booking.bookedRide != null
                ? BookedRideView()
                : BookingRequestView(),
        error: (e, stackTrace) => Container(
          child: Text(e.toString()),
        ),
        loading: () => CircularProgressIndicator(),
      ),
    );
  }
}
