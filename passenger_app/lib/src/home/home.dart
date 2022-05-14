import 'package:common/ui/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/booked-ride/ui/booked_ride_view.dart';
import 'package:passenger_app/src/complete-ride/complete_ride_details_view.dart';
import 'package:passenger_app/src/home/go.dart';
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
    ref.listen<Map?>(ongoingRideJsonProvider, (previous, current) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => BookedRideView()));
    });
    ref.listen<Map?>(completeRideJsonProvider, (previous, current) {
      BookedRide completeRide = BookedRide.fromJson(current);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CompleteRideDetailsView(completeRide)));
    });
    return Scaffold(drawer: AppDrawer(), body: GoTab());
  }
}
