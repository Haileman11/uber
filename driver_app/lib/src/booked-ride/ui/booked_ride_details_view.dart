import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class TripDetailsView extends StatelessWidget {
  const TripDetailsView({Key? key}) : super(key: key);

  static const routeName = '/booked-rides/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Ride Details'),
      ),
      body: const Center(
        child: Text('More Information Here'),
      ),
    );
  }
}
