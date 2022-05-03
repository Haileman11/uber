import 'package:common/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'trip_item.dart';
import 'trip_details_view.dart';

/// Displays a list of SampleItems.
class TripListView extends StatelessWidget {
  const TripListView({
    Key? key,
    this.items = const [Trip(1), Trip(2), Trip(3)],
  }) : super(key: key);

  static const routeName = '/';

  final List<Trip> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Trips'),
        // elevation: 0.0,
        // backgroundColor: Colors.transparent,
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
              title: Text('SampleItem ${item.id}'),
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
