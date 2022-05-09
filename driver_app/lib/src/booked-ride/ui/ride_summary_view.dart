import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:driver_app/src/booked-ride/ui/ongoing_ride_view.dart';
import 'package:driver_app/src/map/map_view.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:driver_app/src/services/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RideSummaryView extends ConsumerStatefulWidget {
  const RideSummaryView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<RideSummaryView> createState() => _BookingRequestViewState();
}

class _BookingRequestViewState extends ConsumerState<RideSummaryView> {
  @override
  Widget build(BuildContext context) {
    final bookedRideController = ref.watch(bookedRideProvider);
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),

            Container(
              padding: const EdgeInsets.all(8.0),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
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
                        Center(
                            child: Text("You have reached your destination")),
                        SizedBox(
                          height: 15.0,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: Text("Price"),
                title: Text(bookedRideController.completeRide!.price
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
                title: Text(bookedRideController.completeRide!.distance
                        .toStringAsFixed(0) +
                    " meters"),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
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
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
