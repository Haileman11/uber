import 'package:common/ui/keep_alive.dart';
import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:driver_app/src/booked-ride/ui/booked_ride_list_view.dart';
import 'package:driver_app/src/booking-request/booking_request_view.dart';
import 'package:driver_app/src/booked-ride/ui/ride_summary_view.dart';
import 'package:driver_app/src/home/app_drawer.dart';
import 'package:driver_app/src/home/go.dart';
import 'package:driver_app/src/map/map_controller.dart';
import 'package:driver_app/src/profile/profile_view.dart';
import 'package:driver_app/src/services/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  var gotTab = GoTab();
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    ref.listen<Map?>(bookingRequestJsonProvider, (previous, current) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => BookingRequestView()));
    });
    ref.listen<BookedRideController>(bookedRideProvider, (previous, current) {
      if (current.completeRide != null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => RideSummaryView()));
      }
    });

    return Scaffold(drawer: AppDrawer(), body: gotTab);
  }
}
