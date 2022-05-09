import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'booked_ride_details_view.dart';

/// Displays a list of SampleItems.
class CompleteRideListView extends ConsumerStatefulWidget {
  const CompleteRideListView({
    Key? key,
  }) : super(key: key);

  static const routeName = '/booked-rides';

  @override
  ConsumerState<CompleteRideListView> createState() => _TripListViewState();
}

class _TripListViewState extends ConsumerState<CompleteRideListView> {
  @override
  Widget build(BuildContext context) {
    final bookedRideController = ref.watch(bookedRideProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Rides'),
        // elevation: 0.0,
        // backgroundColor: Colors.transparent,
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: bookedRideController.bookedRides == null
          ? Center(
              child: Text("Error loading booked rides"),
            )
          : ListView.builder(
              // Providing a restorationId allows the ListView to restore the
              // scroll position when a user leaves and returns to the app after it
              // has been killed while running in the background.
              restorationId: 'sampleItemListView',
              itemCount: bookedRideController.bookedRides!.length,
              itemBuilder: (BuildContext context, int index) {
                final bookedRide = bookedRideController.bookedRides![index];

                return ListTile(
                    title: Text('${bookedRide.distance}'),
                    leading: const CircleAvatar(
                        // Display the Flutter Logo image asset.

                        ),
                    onTap: () {
                      // Navigate to the details page. If the user leaves and returns to
                      // the app after it has been killed while running in the
                      // background, the navigation stack is restored.
                      Navigator.restorablePushNamed(
                        context,
                        TripDetailsView.routeName,
                      );
                    });
              },
            ),
    );
  }
}
